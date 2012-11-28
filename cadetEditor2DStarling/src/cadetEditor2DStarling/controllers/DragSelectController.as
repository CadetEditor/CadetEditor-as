// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

// The box that appears when dragging as square on the background with the selection tool
package cadetEditor2DStarling.controllers
{
	
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D;
	
	import cadetEditor.contexts.ICadetEditorContext;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.controllers.IDragSelectionController;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	import cadetEditor2D.util.BitmapHitTest;
	import cadetEditor2D.util.BitmapHitTestStarling;
	import cadetEditor2D.util.FlashStarlingInteropUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flox.app.core.contexts.ISelectionContext;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.util.ArrayUtil;
	import flox.app.util.VectorUtil;
	import flox.core.data.ArrayCollection;
	import flox.editor.FloxEditor;
	
	import starling.display.DisplayObject;
	
	public class DragSelectController implements IDragSelectionController
	{
		protected var _dragging				:Boolean = false;
		protected var context				:ICadetEditorContext2D;
		protected var view					:ICadetEditorView2D;
		protected var dragStart				:Point;
		protected var overlay				:Sprite;
		
		public function DragSelectController(context:ICadetEditorContext2D)
		{
			this.context = context;
			
			overlay = new Sprite();
			view = context.view2D;
			view.addOverlay(overlay);
		}
		
		public function dispose():void
		{
			if (_dragging)
			{
				endDrag(false);
			}
			view.removeOverlay(overlay);
			overlay = null;
			context = null;
		}
		
		public function beginDrag():void
		{
			if (_dragging) 
			{
				endDrag(false);
			}
			_dragging = true;
			
			dragStart = view.viewportMouse;
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		public function endDrag(appendToSelection:Boolean):void
		{
			_dragging = false
			
			var mouseX:Number = view.viewportMouse.x;
			var mouseY:Number = view.viewportMouse.y;
			var left:Number = dragStart.x < mouseX ? dragStart.x : mouseX;
			var right:Number = dragStart.x > mouseX ? dragStart.x : mouseX;
			var top:Number = dragStart.y < mouseY ? dragStart.y : mouseY;
			var bottom:Number = dragStart.y > mouseY ? dragStart.y : mouseY;

			var dragRect:Rectangle = new Rectangle(left, top, right - left, bottom - top);
			var containedSkins:Array = [];
			
			var skins:Vector.<IComponent> = ComponentUtil.getChildrenOfType( context.scene, ISkin2D, true );
			const L:int = skins.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var skin:AbstractSkin2D = AbstractSkin2D(skins[i]);
				
				//TODO: Deprecate Flash2D and tidy up
				var displayObject:starling.display.DisplayObject = skin.displayObjectContainer;
				
				var hitTestRect:Boolean = false;

				var viewportStarling:starling.display.Sprite = FlashStarlingInteropUtil.getRendererViewportStarling(view.renderer);
				//TODO: Find Starling equivalent for hitTestRect()
				hitTestRect = dragRect.containsRect(displayObject.bounds);			
				
				if ( hitTestRect )
				{
					containedSkins.push( skin );
				}
			}
			
			var componentsToSelect:Vector.<IComponentContainer> = ComponentUtil.getComponentContainers( containedSkins );
			var selection:ArrayCollection = ISelectionContext(context).selection;
		
			if (appendToSelection) 
			{
				componentsToSelect = componentsToSelect.concat(selection.source);
			}
			
			if ( ArrayUtil.compare( VectorUtil.toArray(componentsToSelect), selection.source ) == false ) 
			{
				var changeSelectionOperation:ChangePropertyOperation = new ChangePropertyOperation(selection, "source", VectorUtil.toArray(componentsToSelect));
				changeSelectionOperation.label = "Change Selection";
				context.operationManager.addOperation(changeSelectionOperation);
			}
			overlay.graphics.clear();
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		
		
		protected function updateDragPosition():void
		{
			var width:Number = view.viewportMouse.x - dragStart.x;
			var height:Number = view.viewportMouse.y - dragStart.y;
			
			overlay.graphics.clear();
			overlay.graphics.lineStyle(1, 0xFFFFFF, 1);
			overlay.graphics.drawRect(dragStart.x, dragStart.y, width, height);
		}
		
		
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			updateDragPosition();
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			endDrag(event.shiftKey);
		}

		public function get dragging():Boolean { return _dragging; }
	}
}