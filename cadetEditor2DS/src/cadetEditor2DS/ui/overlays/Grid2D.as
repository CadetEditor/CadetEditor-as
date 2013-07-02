// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.ui.overlays
{
	import cadet2D.overlays.Overlay;
	
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import starling.core.RenderSupport;

	public class Grid2D extends Overlay
	{	
		private var _view	:ICadetEditorView2D;
		
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
			
			visible = view.showGrid;
			
			var _width:Number = view.viewportWidth;
			var _height:Number = view.viewportHeight;
			
			graphics.clear();
			
			if ( visible )
			{
				var size:Number = view.gridSize * view.zoom;
				size = size <= 0 ? 1 : size;
				var left:Number = view.panX*view.zoom - _width*0.5;
				var top:Number = view.panY*view.zoom - _height*0.5;
				var x:Number = (size-(left % size)) - size;
				var y:Number = (size-(top % size)) - size;
				
				while ( x < _width )
				{
					var worldX:int = - x - (view.panX*view.zoom) + _width*0.5;
					graphics.lineStyle(1, 0xFFFFFF, worldX == 0 ? 0.3 : 0.1);
					graphics.moveTo(x,0);
					graphics.lineTo(x,_height);
					
					x += size;
				}
				while ( y < _height )
				{
					var worldY:int = - y - (view.panY*view.zoom) + _height*0.5;
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