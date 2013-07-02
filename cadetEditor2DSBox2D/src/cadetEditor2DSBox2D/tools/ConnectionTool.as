// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DSBox2D.tools
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.core.Entity;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ConnectionSkin;
	import cadet2D.components.skins.IRenderable;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	import cadet2D.overlays.Overlay;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.operations.PickComponentsOperation;
	
	import cadetEditor2DS.tools.CadetEditorTool2D;
	
	import core.app.operations.AddItemOperation;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.operations.AddDependencyOperation;
	
	public class ConnectionTool extends CadetEditorTool2D
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, ConnectionTool, "Connection Tool", CadetEditorIcons.Joint );
		}
		
		private var transformA		:Transform2D;
		private var transformB		:Transform2D;
		private var offsetA			:Vertex;
		private var offsetB			:Vertex;
		
		private var overlay			:Overlay;
		
		//protected var controlBar	:ConnectionToolControlBar;
		
		private var pickComponentOperation	:PickComponentsOperation;
		
		public function ConnectionTool()
		{
			overlay = new Overlay();
			//overlay.blendMode = BlendMode.DIFFERENCE;
			
//			if ( !controlBar )
//			{
//				controlBar = new ConnectionToolControlBar();
//			}
		}
		
		override public function enable():void
		{
			//_view.addOverlay(overlay);
			var renderer2D:Renderer2D = Renderer2D(view.renderer);
			if ( renderer2D ) {
				renderer2D.addOverlay(overlay);
			}
			
//			if ( !controlBar.parent )
//			{
//				context.view2D.controlBar.addChild(controlBar);
//			}
			
			if ( !pickComponentOperation )
			{
				pickComponentOperation = new PickComponentsOperation(context);
				pickComponentOperation.execute();
				pickComponentOperation.addEventListener(Event.COMPLETE, pickCompleteHandler);
			}
			
			statusBarText = "Click the first geometry to connect from."; 
			
			super.enable();
		}
		
		override public function disable():void
		{
//			if ( controlBar.parent )
//			{
//				context.view2D.controlBar.removeChild(controlBar);
//			}
			
			// ToolManager tries to disable "selectedTool" when a modal PopUp is opened.
			// ConnectionTool relies on remaining enabled as it needs its pickComponentOperation and graphics overlay
			// to not be cleared, hence "if panelOpen, return".
			if ( pickComponentOperation && pickComponentOperation.panelOpen ) return;
			
			if ( pickComponentOperation )
			{
				pickComponentOperation.cancel();
				pickComponentOperation = null;
			}
			
			//_view.removeOverlay(overlay);
			var renderer2D:Renderer2D = Renderer2D(view.renderer);
			if ( renderer2D ) {
				renderer2D.removeOverlay(overlay);
			}
			
			overlay.graphics.clear();
			
			transformA = null;
			transformB = null;
			
			statusBarText = "";
			
			super.disable();
		}
		
		private function pickCompleteHandler( event:Event ):void
		{
			var renderer:Renderer2D = Renderer2D(context.view2D.renderer);
		//	pickComponentOperation = PickComponentsOperation(event.target); // not sure why this is null otherwise?
			var result:Array = pickComponentOperation.getResult();
			if (result) {
				var pickedComponent:IComponentContainer = result[0];
			}
			
			if ( pickedComponent == null )
			{
				disable();
				enable();
				return;
			}

			var skin:IRenderable = ComponentUtil.getChildOfType(pickedComponent, IRenderable);
			var transform:Transform2D = ComponentUtil.getChildOfType(pickedComponent, Transform2D);
			if ( !transformA )
			{
				transformA = transform;
				
				var pt:Point = pickComponentOperation.getClickLoc();
				// Convert the clicked location from world coordinates to coordinates local to the picked skin
				pt = renderer.worldToViewport(pt);
				
				pt = renderer.viewport.localToGlobal(pt);
				
				pt = AbstractSkin2D(skin).displayObject.globalToLocal(pt);
				offsetA = new Vertex( pt.x, pt.y );
				
				pickComponentOperation.filter = function notComponentA(element:*, index:int, arr:Array):Boolean
				{
					return (element != pickedComponent);
				};
				
				pickComponentOperation.execute();
				statusBarText = "Click the second geometry to connect to."; 
				return;
			}
			
			if ( transform == transformA ) return;
			
			transformB = transform;
			pt = pickComponentOperation.getClickLoc();
			pt = renderer.worldToViewport(pt);
			
			//pt = context.view2D.viewport.localToGlobal(pt);
			pt = renderer.viewport.localToGlobal(pt);
			
			pt = AbstractSkin2D(skin).displayObject.globalToLocal(pt);
			
			offsetB = new Vertex( pt.x, pt.y );
			
			createConnection();
		}
				
		override protected function onMouseMoveContainer( event:PickingManagerEvent ):void
		{
			overlay.graphics.clear();
			
			if ( transformA )
			{
				var pt:Point = transformA.matrix.transformPoint( offsetA.toPoint() );
				pt = context.view2D.renderer.worldToViewport(pt);
				
				overlay.graphics.lineStyle( 4, 0xFFFFFF );
				overlay.graphics.moveTo( pt.x, pt.y );
				
				
				var snappedMousePos:Point = getSnappedWorldMouse();
				snappedMousePos = context.view2D.renderer.worldToViewport(snappedMousePos);
				overlay.graphics.lineTo( snappedMousePos.x, snappedMousePos.y );
			}
		}
		
		protected function createConnection():void
		{
			var entity:Entity = new Entity();
			entity.name = ComponentUtil.getUniqueName( getName(), context.scene );
			
			var connection:Connection = new Connection();
			connection.transformA = transformA;
			connection.transformB = transformB;
			connection.localPosA = offsetA;
			connection.localPosB = offsetB;
			entity.children.addItem(connection);
			
//			var transform:Transform2D = new Transform2D();
//			entity.children.addItem(transform);
			
			entity.children.addItem( new ConnectionSkin() );
			
			var compoundOperation:UndoableCompoundOperation = new UndoableCompoundOperation();
			compoundOperation.addOperation( new AddItemOperation( entity, context.scene.children ) );
			compoundOperation.addOperation( new AddDependencyOperation( entity, transformA, context.scene.dependencyManager ) );
			compoundOperation.addOperation( new AddDependencyOperation( entity, transformB, context.scene.dependencyManager ) );
			compoundOperation.addOperation( new ChangePropertyOperation( context.selection, "source", [ entity ] ) );
			
			context.operationManager.addOperation( compoundOperation );
			
			disable();
			enable();
			
			statusBarText = "Click the first geometry to create another connection."; 
			
		}
		
		protected function getName():String { return "Connection"; }
	}
}