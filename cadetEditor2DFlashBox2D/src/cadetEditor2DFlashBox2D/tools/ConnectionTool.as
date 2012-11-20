// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlashBox2D.tools
{
	import cadet.core.ComponentContainer;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.core.Entity;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	import cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D;
	import cadet2D.renderPipeline.flash.components.skins.ConnectionSkin;
	import cadet2D.renderPipeline.flash.components.skins.SpringSkin;
	
	import cadet2DBox2D.components.behaviours.DistanceJointBehaviour;
	import cadet2DBox2D.components.behaviours.PrismaticJointBehaviour;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.operations.PickComponentsOperation;
	import cadetEditor2D.tools.CadetEditorTool2D;
	import cadetEditor2D.ui.controlBars.ConnectionToolControlBar;
	import cadetEditor2D.util.FlashStarlingInteropUtil;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import flox.app.operations.AddDependencyOperation;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	
	import starling.display.Sprite;
	
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
		
		private var overlay			:flash.display.Sprite;
		
		//protected var controlBar	:ConnectionToolControlBar;
		
		private var pickComponentOperation	:PickComponentsOperation;
		
		public function ConnectionTool()
		{
			overlay = new flash.display.Sprite();
			overlay.blendMode = BlendMode.DIFFERENCE;
			
//			if ( !controlBar )
//			{
//				controlBar = new ConnectionToolControlBar();
//			}
		}
		
		override public function enable():void
		{
			context.view2D.addOverlay(overlay);
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
			
			if ( pickComponentOperation )
			{
				pickComponentOperation.cancel();
				pickComponentOperation = null;
			}
			
			
			context.view2D.removeOverlay(overlay);
			overlay.graphics.clear();
			
			transformA = null;
			transformB = null;
			
			statusBarText = "";
			
			super.disable();
		}
		
		private function pickCompleteHandler( event:Event ):void
		{
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
			
			//TODO: Deprecate Flash2D and tidy up
			var isFlashOrStarling:uint = FlashStarlingInteropUtil.isRendererFlashOrStarling(view.renderer);
			
			if ( isFlashOrStarling == 0 ) {
				var viewportFlash:flash.display.Sprite = FlashStarlingInteropUtil.getRendererViewportFlash(context.view2D.renderer);
			} else if ( isFlashOrStarling == 1 ) {
				var viewportStarling:starling.display.Sprite = FlashStarlingInteropUtil.getRendererViewportStarling(context.view2D.renderer);
			}
			
			var skin:ISkin2D = ComponentUtil.getChildOfType(pickedComponent, ISkin2D);
			var transform:Transform2D = ComponentUtil.getChildOfType(pickedComponent, Transform2D);
			if ( !transformA )
			{
				transformA = transform;
				
				var pt:Point = pickComponentOperation.getClickLoc();
				// Convert the clicked location from world coordinates to coordinates local to the picked skin
				pt = context.view2D.renderer.worldToViewport(pt);
				
				//pt = context.view2D.viewport.localToGlobal(pt);
				if ( isFlashOrStarling == 0 ) {
					pt = viewportFlash.localToGlobal(pt);
				} else if ( isFlashOrStarling == 1 ) {
					pt = viewportStarling.localToGlobal(pt);
				}
				
				
				pt = AbstractSkin2D(skin).displayObjectContainer.globalToLocal(pt);
				offsetA = new Vertex( pt.x, pt.y );
				
				pickComponentOperation.filter = function notComponentA(element:*, index:int, arr:Array):Boolean
				{
					return (element != pickedComponent);
				}
				pickComponentOperation.execute();
				statusBarText = "Click the second geometry to connect to."; 
				return;
			}
			
			if ( transform == transformA ) return;
			
			transformB = transform;
			pt = pickComponentOperation.getClickLoc();
			pt = context.view2D.renderer.worldToViewport(pt);
			
			//pt = context.view2D.viewport.localToGlobal(pt);
			if ( isFlashOrStarling == 0 ) {
				pt = viewportFlash.localToGlobal(pt);
			} else if ( isFlashOrStarling == 1 ) {
				pt = viewportStarling.localToGlobal(pt);
			}
			
			
			pt = AbstractSkin2D(skin).displayObjectContainer.globalToLocal(pt);
			
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
			
			var transform:Transform2D = new Transform2D();
			entity.children.addItem(transform);
			
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