// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.tools
{
	import cadetEditor.tools.ITool;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.geom.Point;
	
	import flox.app.core.contexts.IContext;
	
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
			disable()
			_context = null;
		}
		
		public function enable():void
		{
			_context.pickingManager.addEventListener(PickingManagerEvent.CLICK_BACKGROUND, onClickBackground);
			//_context.pickingManager.addEventListener(PickingManagerEvent.CLICK_CONTAINER, onClickContainer);
			_context.pickingManager.addEventListener(PickingManagerEvent.CLICK_SKINS, onClickSkins);
			//_context.pickingManager.addEventListener(PickingManagerEvent.DOUBLE_CLICK_CONTAINER, onDoubleClickContainer);
			//_context.pickingManager.addEventListener(PickingManagerEvent.DOUBLE_CLICK_SKINS, onDoubleClickSkins);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_DOWN_BACKGROUND, onMouseDownBackground);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_DOWN_CONTAINER, onMouseDownContainer);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_DOWN_SKINS, onMouseDownSkins);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_MOVE_CONTAINER, onMouseMoveContainer);
			//_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_UP_BACKGROUND, onMouseUpBackground);
			//_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_UP_CONTAINER, onMouseUpContainer);
			//_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_UP_SKINS, onMouseUpSkins);
			_context.pickingManager.addEventListener(PickingManagerEvent.MOUSE_UP_STAGE, onMouseUpStage);
			//_context.pickingManager.addEventListener(PickingManagerEvent.ROLL_OUT_SKIN, onRollOutSkin);
			//_context.pickingManager.addEventListener(PickingManagerEvent.ROLL_OVER_SKIN, onRollOverSkin);
		}
		
		public function disable():void
		{
			_context.snapManager.clearIgnore();
			_context.snapManager.setAdditionalSnapPoints(null);
			_context.snapManager.setVerticesToIgnore(null);
			
			_context.pickingManager.removeEventListener(PickingManagerEvent.CLICK_BACKGROUND, onClickBackground);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.CLICK_CONTAINER, onClickContainer);
			_context.pickingManager.removeEventListener(PickingManagerEvent.CLICK_SKINS, onClickSkins);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.DOUBLE_CLICK_CONTAINER, onDoubleClickContainer);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.DOUBLE_CLICK_SKINS, onDoubleClickSkins);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_DOWN_BACKGROUND, onMouseDownBackground);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_DOWN_CONTAINER, onMouseDownContainer);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_DOWN_SKINS, onMouseDownSkins);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_MOVE_CONTAINER, onMouseMoveContainer);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_UP_BACKGROUND, onMouseUpBackground);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_UP_CONTAINER, onMouseUpContainer);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_UP_SKINS, onMouseUpSkins);
			_context.pickingManager.removeEventListener(PickingManagerEvent.MOUSE_UP_STAGE, onMouseUpStage);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.ROLL_OUT_SKIN, onRollOutSkin);
			//_context.pickingManager.removeEventListener(PickingManagerEvent.ROLL_OVER_SKIN, onRollOverSkin);
		}
		
		protected function onClickBackground( event:PickingManagerEvent ):void {}
		//protected function onClickContainer( event:PickingManagerEvent ):void {}
		protected function onClickSkins( event:PickingManagerEvent ):void {}
		//protected function onDoubleClickContainer( event:PickingManagerEvent ):void {}
		//protected function onDoubleClickSkins( event:PickingManagerEvent ):void {}
		protected function onMouseDownBackground( event:PickingManagerEvent ):void {}
		protected function onMouseDownContainer( event:PickingManagerEvent ):void {}
		protected function onMouseDownSkins( event:PickingManagerEvent ):void {}
		protected function onMouseMoveContainer( event:PickingManagerEvent ):void {}
		//protected function onMouseUpBackground( event:PickingManagerEvent ):void {}
		//protected function onMouseUpContainer( event:PickingManagerEvent ):void {}
		//protected function onMouseUpSkins( event:PickingManagerEvent ):void {}
		protected function onMouseUpStage( event:PickingManagerEvent ):void {}
		//protected function onRollOutSkin( event:PickingManagerEvent ):void {}
		//protected function onRollOverSkin( event:PickingManagerEvent ):void {}
		
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






