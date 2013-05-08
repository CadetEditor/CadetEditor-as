// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.tools
{	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.tools.ICadetEditorTool2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.geom.Point;
	
	import core.appEx.core.contexts.IContext;
	
	public class CadetEditorTool2D implements ICadetEditorTool2D
	{
		protected var _context		:ICadetEditorContext2D;
		protected var _view			:ICadetEditorView2D;
		
		// Private storage vars for commonly used functions to avoid 'new Point()'.
		private var snappedPos:Point;
		private var mousePos:Point;
		
		protected var isMouseDown		:Boolean = false;
		
		public function CadetEditorTool2D()
		{
			snappedPos = new Point();
			mousePos = new Point();
		}
		
		public function init( context:IContext ):void
		{
			_context = ICadetEditorContext2D( context );
			_view = ICadetEditorContext2D( _context ).view2D;
		}
		
		public function dispose():void
		{
			disable();
			_context = null;
		}
		
		public function enable():void
		{
			_context.pickingManager.addEventListener(PickingManagerEvent.CLICK_BACKGROUND, onClickBackground);
			_context.pickingManager.addEventListener(PickingManagerEvent.CLICK_SKINS, onClickSkins);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_DOWN_BACKGROUND, onMouseDownBackground);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_DOWN_CONTAINER, onMouseDownContainer);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_DOWN_SKINS, onMouseDownSkins);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_MOVE_CONTAINER, onMouseMoveContainer);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_DRAG_CONTAINER, onMouseDragContainer);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_UP_STAGE, onMouseUpStage);
		}
		
		public function disable():void
		{
			_context.snapManager.clearIgnore();
			_context.snapManager.setAdditionalSnapPoints(null);
			_context.snapManager.setVerticesToIgnore(null);
			
			_context.pickingManager.removeEventListener(PickingManagerEvent.CLICK_BACKGROUND, onClickBackground);
			_context.pickingManager.removeEventListener(PickingManagerEvent.CLICK_SKINS, onClickSkins);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_DOWN_BACKGROUND, onMouseDownBackground);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_DOWN_CONTAINER, onMouseDownContainer);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_DOWN_SKINS, onMouseDownSkins);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_MOVE_CONTAINER, onMouseMoveContainer);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_DRAG_CONTAINER, onMouseDragContainer);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_UP_STAGE, onMouseUpStage);
		}
		
		protected function onClickBackground( event:PickingManagerEvent ):void {}
		protected function onClickSkins( event:PickingManagerEvent ):void {}
		protected function onMouseDownBackground( event:PickingManagerEvent ):void {}
		protected function onMouseDownContainer( event:PickingManagerEvent ):void {}
		protected function onMouseDownSkins( event:PickingManagerEvent ):void {}
		protected function onMouseMoveContainer( event:PickingManagerEvent ):void {}
		protected function onMouseDragContainer( event:PickingManagerEvent ):void {}
		protected function onMouseUpStage( event:PickingManagerEvent ):void {}
		
		public function getSnappedWorldMouse():Point 
		{ 
			return _context.snapManager.snapPoint(_view.worldMouse).snapPoint; 
		}
		
		protected function set statusBarText(value:String):void
		{
			if ( !_view ) return;
			if ( !_view.parent ) return;
			//IViewContainer(view.parent).statusBarText = value;
		}
		protected function get statusBarText():String
		{
			if ( !_view ) return "";
			if ( !_view.parent ) return "";
			return "";
			//return IViewContainer(view.parent).statusBarText;
		}
		
		public function get context():ICadetEditorContext2D
		{
			return _context;
		}
		public function set context(value:ICadetEditorContext2D):void
		{
			_context = value;
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






