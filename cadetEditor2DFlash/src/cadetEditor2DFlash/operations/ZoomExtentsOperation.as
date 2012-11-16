// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.operations
{
	import flox.app.core.operations.IUndoableOperation;
	
	import cadet2D.renderPipeline.flash.components.renderers.Renderer2D;
	
	import cadetEditor.controllers.ICadetEditorContextController;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public class ZoomExtentsOperation implements IUndoableOperation
	{
		private var _view			:ICadetEditorView2D;
		
		private var storedPanX		:Number;
		private var storedPanY		:Number;
		private var storedZoom		:Number;
		private var padding			:Number;
		
		public function ZoomExtentsOperation( view:ICadetEditorView2D, padding:Number = 40 )
		{
			_view 			= view;
			
			this.storedPanX = _view.panX;
			this.storedPanY = _view.panY;
			this.storedZoom = _view.zoom;
			this.padding = padding;
		}

		public function execute():void
		{
			// Safety check, ignore operation if no renderer present.
			if ( _view.renderer == null )
			{
				return;
			}
			
			var worldContainer:DisplayObject = Renderer2D(_view.renderer).worldContainer;
			
			var bounds:Rectangle = worldContainer.getBounds(worldContainer);
			bounds.inflate( 20 / _view.zoom, 20/ _view.zoom );
			var ratioA:Number = _view.viewportWidth / bounds.width;
			var ratioB:Number = _view.viewportHeight / bounds.height;
			var ratio:Number = Math.min(ratioA,ratioB);
			
			_view.zoom = ratio;
			_view.panX = (bounds.x + bounds.width*0.5);
			_view.panY = (bounds.y + bounds.height*0.5);
		}
		
		public function undo():void
		{
			_view.zoom = storedZoom;
			_view.panX = storedPanX;
			_view.panY = storedPanY;
		}
		
		public function get label():String
		{
			return "Zoom extents";
		}
		
	}
}