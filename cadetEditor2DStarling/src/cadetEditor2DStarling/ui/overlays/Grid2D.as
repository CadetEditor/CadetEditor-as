// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DStarling.ui.overlays
{
	import cadetEditor.events.CadetEditorViewEvent;
	
	import cadetEditor2D.ui.overlays.ICadetEditorOverlay2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.display.BlendMode;
	
	import flox.ui.components.UIComponent;

	public class Grid2D extends UIComponent implements ICadetEditorOverlay2D
	{	
		private var _view	:ICadetEditorView2D;
		
		public function Grid2D()
		{
			mouseEnabled = false;
			mouseChildren = false;
			blendMode = BlendMode.DIFFERENCE;
		}
		
		override protected function init():void
		{
			super.init();
			percentWidth = percentHeight = 100;
		}
		
		override protected function validate():void
		{
			if ( !_view ) return;
			
			var view2D:ICadetEditorView2D = ICadetEditorView2D(view);
			
			visible = view.showGrid;
			
			
			graphics.clear();
			
			if ( visible )
			{
				var size:Number = view.gridSize * view2D.zoom;
				size = size <= 0 ? 1 : size;
				var left:Number = view2D.panX*view2D.zoom - _width*0.5;
				var top:Number = view2D.panY*view2D.zoom - _height*0.5;
				var x:Number = (size-(left % size)) - size;
				var y:Number = (size-(top % size)) - size;
				
				while ( x < _width )
				{
					var worldX:int = - x - (view2D.panX*view2D.zoom) + _width*0.5;
					graphics.lineStyle(1, 0xFFFFFF, worldX == 0 ? 0.3 : 0.1);
					graphics.moveTo(x,0);
					graphics.lineTo(x,_height);
					
					x += size;
				}
				while ( y < _height )
				{
					var worldY:int = - y - (view2D.panY*view2D.zoom) + _height*0.5;
					graphics.lineStyle(1, 0xFFFFFF, worldY == 0 ? 0.3 : 0.1);
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