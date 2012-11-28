// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.ui.overlays
{
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	
	import cadetEditor2D.tools.ICadetEditorTool2D;
	import cadetEditor2D.ui.overlays.ICadetEditorOverlay2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.geom.Point;
	
	import flox.ui.components.UIComponent;

	public class PolygonToolOverlay extends UIComponent implements ICadetEditorOverlay2D
	{
		private var _view		:ICadetEditorView2D;
		private var tool		:ICadetEditorTool2D;
		private var _polygon	:PolygonGeometry;
		private var _transform	:Transform2D;
		
		private const CIRCLE_SIZE	:int = 5;
		
		public function PolygonToolOverlay( tool:ICadetEditorTool2D )
		{
			this.tool = tool;
		}
		
		public function set polygon( value:PolygonGeometry ):void
		{
			if ( _polygon )
			{
				_polygon.removeEventListener(InvalidationEvent.INVALIDATE, invalidatePathHandler);
			}
			_polygon = value;
			if ( _polygon )
			{
				_polygon.addEventListener(InvalidationEvent.INVALIDATE, invalidatePathHandler);
			}
			invalidate();
		}
		public function get polygon():PolygonGeometry { return _polygon; }
		
		public function set transform2D( value:Transform2D ):void
		{
			if ( _transform )
			{
				_transform.removeEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			_transform = value;
			if ( _transform )
			{
				_transform.addEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate();
		}
		public function get transform2D():Transform2D { return _transform; }
		
		private function invalidateTransformHandler( event:InvalidationEvent ):void
		{
			invalidate();
		}
		
		private function invalidatePathHandler( event:InvalidationEvent ):void
		{
			invalidate();
		}
		
		override protected function validate():void
		{
			graphics.clear();
			
			if ( !_polygon ) return;
			if ( !_transform ) return;
			
			var L:int = _polygon.vertices.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var vertex:Vertex = _polygon.vertices[i];
				
				var pt:Point = vertex.toPoint();
				pt = _transform.matrix.transformPoint(pt);
				pt = tool.view.renderer.worldToViewport(pt);
				
				graphics.beginFill(0xFFFFFF);
				graphics.drawCircle(pt.x, pt.y,CIRCLE_SIZE);
				graphics.endFill();
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