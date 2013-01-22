// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

//Draws a little X over the snap point nearest the mouse.
package cadetEditor2DS.ui.overlays
{
	import cadet.events.RendererEvent;
	
	import cadet2D.overlays.Overlay;
	import cadet2D.components.renderers.Renderer2D;
	
	import cadetEditor2D.managers.SnapInfo;
	import cadetEditor2D.managers.SnapManager2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.geom.Point;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class SnapOverlay extends Overlay
	{
		private static const CROSS_SIZE		:int = 5;
		
		private var _view			:ICadetEditorView2D;
		private var snapManager		:SnapManager2D;
		
		private var _renderer		:Renderer2D;
		
		public function SnapOverlay( snapManager:SnapManager2D )
		{
			//blendMode = BlendMode.DIFFERENCE;
			this.snapManager = snapManager;
		}
		
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if ( isInvalid("*") )	validateNow();
		}
		
		override protected function validate():void
		{
			graphics.clear();
			
			if ( !snapManager ) return;
			if ( !_renderer ) return;
			
			var viewportMouse:Point = new Point(_renderer.mouseX, _renderer.mouseY);
			//var worldMouse:Point = _renderer.viewportToWorld( new Point(  _renderer.mouseX, _renderer.mouseY ) );
			
			//trace("SnapOverlay renderer x "+_renderer.mouseX+" y "+_renderer.mouseY);
			//trace("SnapOverlay viewportMouse x "+viewportMouse.x+" y "+viewportMouse.y);
			
			//TODO: Possibly shouldn't cop out here due to Starling...
			if (!viewportMouse) return;
			
			var snapInfo:SnapInfo = snapManager.snapPoint(viewportMouse);
			var pt:Point = snapInfo.snapPoint;
			
			//trace("SnapOverlay snapPoint x "+pt.x+" y "+pt.y+" OVERLAY x "+x+" y "+y);
			
			if ( pt.x == viewportMouse.x && pt.y == viewportMouse.y ) return;
			
			//pt = _renderer.worldToViewport(pt);
			
			//pt = _renderer.viewport.localToGlobal(pt);
			pt = globalToLocal(pt);
			
			graphics.lineStyle(1, 0xFFFFFF);
			
			//trace("SnapOverlay type "+snapInfo.snapPoint+" pt x "+pt.x+" y "+pt.y);
			
			switch ( snapInfo.snapType )
			{
				case SnapInfo.GRID :
					graphics.moveTo( pt.x, pt.y - CROSS_SIZE );
					graphics.lineTo( pt.x, pt.y + CROSS_SIZE );
					graphics.moveTo( pt.x + CROSS_SIZE, pt.y );
					graphics.lineTo( pt.x - CROSS_SIZE, pt.y );
					break;
				case SnapInfo.VERTEX :
					graphics.moveTo( pt.x - CROSS_SIZE, pt.y - CROSS_SIZE );
					graphics.lineTo( pt.x + CROSS_SIZE, pt.y + CROSS_SIZE );
					graphics.moveTo( pt.x + CROSS_SIZE, pt.y - CROSS_SIZE );
					graphics.lineTo( pt.x - CROSS_SIZE, pt.y + CROSS_SIZE );
					break;
				case SnapInfo.CENTER_POINT : 
					graphics.moveTo( pt.x - CROSS_SIZE, pt.y - CROSS_SIZE );
					graphics.lineTo( pt.x + CROSS_SIZE, pt.y + CROSS_SIZE );
					graphics.moveTo( pt.x + CROSS_SIZE, pt.y - CROSS_SIZE );
					graphics.lineTo( pt.x - CROSS_SIZE, pt.y + CROSS_SIZE );
					graphics.drawCircle( pt.x, pt.y, CROSS_SIZE );
					break;
				default :
					graphics.moveTo( pt.x - CROSS_SIZE, pt.y - CROSS_SIZE );
					graphics.lineTo( pt.x + CROSS_SIZE, pt.y + CROSS_SIZE );
					graphics.moveTo( pt.x + CROSS_SIZE, pt.y - CROSS_SIZE );
					graphics.lineTo( pt.x - CROSS_SIZE, pt.y + CROSS_SIZE );
					break;
			}
			
		}
		
		public function get renderer():Renderer2D
		{
			return _renderer;
		}
		public function set renderer( value:Renderer2D ):void
		{
			if ( _renderer ) {
				_renderer.viewport.stage.removeEventListener(TouchEvent.TOUCH, onTouchHandler);
			}
			_renderer = value;
			
			if (!value) return;
			
			if ( _renderer && _renderer.viewport ) {
				_renderer.viewport.stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			} else {
				_renderer.addEventListener(RendererEvent.INITIALISED, rendererInitialised);
			}
		}
		
		private function rendererInitialised( event:RendererEvent ):void
		{
			_renderer.viewport.stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
		}
		
		private function onTouchHandler( event:TouchEvent ):void
		{
			var dispObj:DisplayObject = DisplayObject(_renderer.viewport.stage);
			var touches:Vector.<Touch> = event.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				if ( touch.phase == TouchPhase.HOVER ) {
					invalidate("*");
					break;
				}
			}
		}
		
//		private function mouseMoveHandler( event:MouseEvent ):void
//		{
//			invalidate();
//		}
/*
		public function get view():ICadetEditorView2D
		{
			return _view;
		}

		public function set view(value:ICadetEditorView2D):void
		{
			if ( _view )
			{
				_view.container.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			_view = value;
			if ( _view )
			{
				_view.container.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
		}
*/
	}
}