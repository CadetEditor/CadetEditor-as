// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DStarling.ui.overlays
{
	
	import cadetEditor2D.managers.SnapInfo;
	import cadetEditor2D.managers.SnapManager2D;
	import cadetEditor2D.ui.overlays.ICadetEditorOverlay2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flox.ui.components.UIComponent;
	
	/**
	 * This overlap draws a little X over the snap point nearest the mouse. 
	 * @author Jonathan Pace
	 * 
	 */	
	public class SnapOverlay extends UIComponent implements ICadetEditorOverlay2D
	{
		private static const CROSS_SIZE		:int = 5;
		
		private var _view			:ICadetEditorView2D;
		private var snapManager		:SnapManager2D;
		
		public function SnapOverlay( snapManager:SnapManager2D )
		{
			blendMode = BlendMode.DIFFERENCE;
			this.snapManager = snapManager;
		}
		
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			invalidate();
		}
		
		override protected function validate():void
		{
			graphics.clear();
			
			if ( !snapManager ) return;
			if ( !view.renderer ) return;
			
			var worldMouse:Point = ICadetEditorView2D(view).worldMouse;
			
			//TODO: Possibly shouldn't cop out here due to Starling...
			if (!worldMouse) return;
			
			var snapInfo:SnapInfo = snapManager.snapPoint(worldMouse);
			var pt:Point = snapInfo.snapPoint;
			if ( pt.x == worldMouse.x && pt.y == worldMouse.y ) return;
			
			pt = view.renderer.worldToViewport(pt);
			
			graphics.lineStyle(1, 0xFFFFFF);
			
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

	}
}