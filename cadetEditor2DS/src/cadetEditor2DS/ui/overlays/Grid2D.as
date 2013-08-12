// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.ui.overlays
{
	import cadet2D.overlays.Overlay;
	
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import starling.core.RenderSupport;

	public class Grid2D extends Overlay
	{	
		private var _view			:ICadetEditorView2D;
		/*
		*	_minGridSize is calculated as view.gridSize * view.zoom.
		*	E.g. If minGridSize == 5, lines will not render at below 50 gridSize at 10%, below 10 gridsize at 40%,
		*	or below 5 gridSize at 100% zoom.
		*	0.1 * 50 = 5
		*	0.5 * 10 = 5
		*	1 * 5 = 5
		*/
		private var _minGridSize	:uint = 5;
		
		public function Grid2D()
		{
			//mouseEnabled = false;
			//mouseChildren = false;
			//blendMode = BlendMode.DIFFERENCE;
			
			touchable = false;
		}
		
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if ( isInvalid("*") )	validateNow();
		}
		
		override protected function validate():void
		{
			if ( !_view ) return;
			
			visible = _view.showGrid;
			
			var _width:Number = view.viewportWidth;
			var _height:Number = view.viewportHeight;
			
			var axisAlpha:Number = 0.3;
			var lineAlpha:Number = 0.1;
			
			graphics.clear();
			
			// drawing too many lines in Starling causes slow down
			if ( view.gridSize * view.zoom < _minGridSize ) {
				
				// Draw X axis
				var worldX:int = -(view.panX*view.zoom) + _width*0.5;
				graphics.lineStyle(1, 0xFFFFFF, axisAlpha);
				graphics.moveTo(worldX,0);
				graphics.lineTo(worldX,_height);
				// Draw Y axis
				var worldY:int = -(view.panY*view.zoom) + _height*0.5;
				graphics.lineStyle(1, 0xFFFFFF, axisAlpha);
				graphics.moveTo(0,worldY);
				graphics.lineTo(_width,worldY);
				
				return;
			}
			
			if ( visible ) {
				var size:Number = view.gridSize * view.zoom;
				size = size <= 0 ? 1 : size;
				var left:Number = view.panX*view.zoom - _width*0.5;
				var top:Number = view.panY*view.zoom - _height*0.5;
				var x:Number = (size-(left % size)) - size;
				var y:Number = (size-(top % size)) - size;
				
				while ( x < _width ) {
					worldX = - x - (view.panX*view.zoom) + _width*0.5;
					graphics.lineStyle(1, 0xFFFFFF, worldX == 0 ? axisAlpha : lineAlpha);
					graphics.moveTo(x,0);
					graphics.lineTo(x,_height);
					
					x += size;
				}
				while ( y < _height ) {
					worldY = - y - (view.panY*view.zoom) + _height*0.5;
					graphics.lineStyle(1, 0xFFFFFF, worldY == 0 ? axisAlpha : lineAlpha);
					graphics.moveTo(0,y);
					graphics.lineTo(_width,y);
					
					y += size;
				}
			}
		}

		public function get view():ICadetEditorView2D
		{
			return _view;
		}

		public function set view(value:ICadetEditorView2D):void
		{
			_view = value;
		}
	}
}