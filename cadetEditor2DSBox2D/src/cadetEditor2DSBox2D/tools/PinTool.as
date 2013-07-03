// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DSBox2D.tools
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Pin;
	import cadet2D.components.core.Entity;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.IRenderable;
	import cadet2D.components.skins.PinSkin;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor2D.operations.PickComponentsOperation;
	
	import cadetEditor2DS.tools.CadetEditorTool2D;
	
	import core.app.operations.AddItemOperation;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.operations.AddDependencyOperation;
	import core.ui.managers.CursorManager;
	
	public class PinTool extends CadetEditorTool2D
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, PinTool, "Pin Tool", CadetEditorIcons.Pin );
		}
		
		private var skinA			:IRenderable;
		private var transformA		:Transform2D;
		private var transformB		:Transform2D;
		private var clickLoc		:Point;
		private var offset			:Point;
		private var pinOffset		:Point;
		
		protected var SkinType		:Class = PinSkin;
		
		private var pickComponentOperation	:PickComponentsOperation;
		
		public function PinTool()
		{
			
		}
		
		override public function enable():void
		{
			if ( !pickComponentOperation )
			{
				pickComponentOperation = new PickComponentsOperation(context, 2);
				pickComponentOperation.execute();
				pickComponentOperation.addEventListener(Event.COMPLETE, pickCompleteHandler);
			}
			
			statusBarText = "Click two overlapping components to pin them together."; 
			
			super.enable();
		}
		
		override public function disable():void
		{			
			if ( pickComponentOperation )
			{
				pickComponentOperation.cancel();
				pickComponentOperation = null;
			}
			
			CursorManager.setCursor(null);
			
			transformA = null;
			transformB = null;
			super.disable()
		}
		
		private function pickCompleteHandler( event:Event ):void
		{
			var pickedComponents:Array = pickComponentOperation.getResult();
			
			if (!pickedComponents) return;
			
			var componentA:IComponentContainer = pickedComponents[0];
			var componentB:IComponentContainer = pickedComponents[1];
			
			skinA = ComponentUtil.getChildOfType(componentA, IRenderable);
			var skinB:IRenderable = ComponentUtil.getChildOfType(componentB, IRenderable);
			
			if ( skinA is AbstractSkin2D ) {
				transformA = AbstractSkin2D(skinA).transform2D;	
			}
			if ( skinB is AbstractSkin2D ) {
				transformB = AbstractSkin2D(skinB).transform2D;	
			}
			
			// Get the position of the top left corner of the clicked component
			clickLoc = pickComponentOperation.getClickLoc();
			
			offset = clickLoc;
			// Get the viewport location of the click within world space
			offset = context.view2D.renderer.worldToViewport(offset);
		
			// Change the point from viewport space to screen space
			offset = Renderer2D(context.view2D.renderer).viewport.localToGlobal(offset);
			
			// Convert the point from global (screen) space to local skin space
			offset = AbstractSkin2D(skinA).displayObject.globalToLocal(offset);
			
			pinOffset = offset;
			
			createPin();
		}
		
		protected function createPin():void
		{
			var entity:Entity = new Entity();
			entity.name = ComponentUtil.getUniqueName( getName(), context.scene );
			
			var pin:Pin = new Pin();
			//pin.skinA = skinA;
			pin.name = entity.name+"_"+pin.name;
			pin.transformA = transformA;
			pin.transformB = transformB;
			pin.localPos = new Vertex(pinOffset.x, pinOffset.y);
			entity.children.addItem(pin);
			
			var transform:Transform2D = new Transform2D();
			transform.name = entity.name+"_"+transform.name;
			transform.x = clickLoc.x;
			transform.y = clickLoc.y;
			entity.children.addItem(transform);
			
			var skin:IRenderable = new PinSkin();
			skin.name = entity.name+"_"+skin.name;
			entity.children.addItem(skin);
			
			//pin.localPos = new Vertex(pinOffset.x, pinOffset.y);
			
			var compoundOperation:UndoableCompoundOperation = new UndoableCompoundOperation();
			compoundOperation.addOperation( new AddItemOperation( entity, context.scene.children ) );
			compoundOperation.addOperation( new AddDependencyOperation( entity, transformA, context.scene.dependencyManager ) );
			compoundOperation.addOperation( new AddDependencyOperation( entity, transformB, context.scene.dependencyManager ) );
			compoundOperation.addOperation( new ChangePropertyOperation( context.selection, "source", [ entity ] ) );
			
			context.operationManager.addOperation( compoundOperation );
			
			transformA = null;
			transformB = null;
			
			pickComponentOperation.execute();
		}
		
		protected function getName():String { return "Pin"; }
	}
}