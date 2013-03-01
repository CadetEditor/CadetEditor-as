// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.ui.views
{
	import cadet3D.components.core.Renderer3D;
	
	import cadetEditor.ui.views.ToolEditorView;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.tools.gizmos.SelectionOverlay;
	
	import flash.geom.Rectangle;

	public class CadetEditorView3D extends ToolEditorView
	{
		private var context				:CadetEditorContext3D
		private var _renderer			:Renderer3D;
		private var selectionOverlay	:SelectionOverlay;
		
		public function CadetEditorView3D( context:CadetEditorContext3D )
		{
			this.context = context;
			selectionOverlay = new SelectionOverlay( context );
		}
		
		public function dispose():void
		{
			renderer = null;
			selectionOverlay.dispose();
			selectionOverlay = null;
		}
		
		override protected function validate():void
		{
			super.validate();
			
			if ( _renderer )
			{
				var layoutArea:Rectangle = getChildrenLayoutArea();
				_renderer.viewportWidth = layoutArea.width;
				_renderer.viewportHeight = layoutArea.height;
			}
		}
		
		public function get renderer():Renderer3D
		{
			return _renderer;
		}
		
		public function set renderer( value:Renderer3D ):void
		{
			if ( _renderer )
			{
				//removeChild(DisplayObject(_renderer.viewport));
				_renderer.disable(this);
			}
			_renderer = value;
			if ( _renderer )
			{
				//addChildAt(DisplayObject(_renderer.viewport),0);
				_renderer.enable(this, 0);
			}
		}
	}
}