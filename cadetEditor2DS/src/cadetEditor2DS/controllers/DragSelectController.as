// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

// The box that appears when dragging a rectangular selection area on the background 
// with the selection tool
package cadetEditor2DS.controllers
{
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.IRenderable;
	import cadet2D.overlays.Overlay;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.controllers.IDragSelectionController;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import core.app.core.contexts.ISelectionContext;
	import core.app.operations.ChangePropertyOperation;
	import core.app.util.ArrayUtil;
	import core.app.util.VectorUtil;
	import core.data.ArrayCollection;
	
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class DragSelectController implements IDragSelectionController
	{
		protected var _dragging				:Boolean = false;
		protected var context				:ICadetEditorContext2D;
		protected var view					:ICadetEditorView2D;
		protected var dragStart				:Point;
		protected var overlay				:Overlay;
		
		private var _renderer				:Renderer2D;
		
		public function DragSelectController(context:ICadetEditorContext2D)
		{
			this.context = context;
			
			overlay = new Overlay();
			view = context.view2D;
		}
		
		public function dispose():void
		{
			if (_dragging)
			{
				endDrag(false);
			}
			
			//view.removeOverlay(overlay);
			if (_renderer)	_renderer.removeOverlay(overlay);
			
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
			
			//view.addOverlay(overlay);
			_renderer = Renderer2D(context.view2D.renderer);
			
			if (_renderer) {
				_renderer.addOverlay(overlay);
				_renderer.viewport.stage.addEventListener( TouchEvent.TOUCH, touchEventHandler );
			}
			
//			CoreEditor.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
//			CoreEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
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
			
			var skins:Vector.<IComponent> = ComponentUtil.getChildrenOfType( context.scene, IRenderable, true );
			const L:int = skins.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var skin:IRenderable = IRenderable(skins[i]);
				
				var hitTestRect:Boolean = false;
				
				//TODO: Find Starling equivalent for hitTestRect()
				var bounds:Rectangle = skin.displayObject.getBounds(Renderer2D(view.renderer).viewport);
				//var bounds:Rectangle = skin.displayObjectContainer.bounds;
				hitTestRect = dragRect.containsRect(bounds);			
				
				if ( hitTestRect ) {
					containedSkins.push( skin );
				}
			}
			
			var componentsToSelect:Vector.<IComponentContainer> = ComponentUtil.getComponentContainers( containedSkins );
			var selection:ArrayCollection = ISelectionContext(context).selection;
		
			if (appendToSelection) 
			{
				var selectComponents:Vector.<IComponentContainer> = new Vector.<IComponentContainer>();
				selectComponents = Vector.<IComponentContainer>(VectorUtil.arrayToVector(selection.source, selectComponents));
				componentsToSelect = componentsToSelect.concat(selectComponents);
				//componentsToSelect = componentsToSelect.concat(selection.source);
			}
			
			if ( ArrayUtil.compare( VectorUtil.toArray(componentsToSelect), selection.source ) == false ) 
			{
				var changeSelectionOperation:ChangePropertyOperation = new ChangePropertyOperation(selection, "source", VectorUtil.toArray(componentsToSelect));
				changeSelectionOperation.label = "Change Selection";
				context.operationManager.addOperation(changeSelectionOperation);
			}
			overlay.graphics.clear();
			
			_renderer.viewport.stage.removeEventListener( TouchEvent.TOUCH, touchEventHandler );
//			CoreEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
//			CoreEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
		}
		
		private function touchEventHandler( event:TouchEvent ):void
		{
			var dispObj:DisplayObject = DisplayObject(_renderer.viewport.stage);
			var touches:Vector.<Touch> = event.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				if ( touch.phase == TouchPhase.MOVED ) {
					updateDragPosition();
					break;
				} else if ( touch.phase == TouchPhase.ENDED ) {
					endDrag(event.shiftKey);
				}
			}			
		}
		
/*		private function mouseMoveHandler(event:MouseEvent):void
		{
			updateDragPosition();
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			endDrag(event.shiftKey);
		}*/
		
		protected function updateDragPosition():void
		{
			var width:Number = view.viewportMouse.x - dragStart.x;
			var height:Number = view.viewportMouse.y - dragStart.y;
			
			overlay.graphics.clear();
			overlay.graphics.lineStyle(1, 0xFFFFFF, 1);
			overlay.graphics.drawRect(dragStart.x, dragStart.y, width, height);
		}

		public function get dragging():Boolean { return _dragging; }
	}
}