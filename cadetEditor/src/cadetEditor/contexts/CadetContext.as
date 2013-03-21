// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import cadet.core.IRenderer;
	import cadet.util.ComponentUtil;
	
	import cadetEditor.ui.views.CadetView;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import core.app.events.OperationManagerEvent;
	
	public class CadetContext extends AbstractCadetEditorContext implements ICadetEditorContext//ICadetContext
	{
		private var _view		:CadetView;
		//private var firstEnable	:Boolean = true;
		
		public function CadetContext()
		{
			_view = new CadetView();
		}
		
		override public function get view():DisplayObject
		{
			return _view;
		}
		
		override public function save():void
		{
			// Intentionally blank
		}
		
		override public function dispose():void
		{
			disable();
			super.dispose();
		}
		
		public function enable():void
		{
			// Automatically start playing the scene when this editor is first launched
//			if ( firstEnable)
//			{
//				firstEnable = false;
				_view.toggleBtnBar.selectedIndex = 2;
				play();
//			}
			_view.toggleBtnBar.addEventListener(Event.CHANGE, changeControlBarHandler);
			
			enableRenderer();
		}
		
		public function disable():void
		{
			pause();
			_view.toggleBtnBar.removeEventListener(Event.CHANGE, changeControlBarHandler);
			_view.toggleBtnBar.selectedIndex = 1;
			
			disableRenderer();
		}
		
		private function enableRenderer():void
		{
			if (!_view.renderer) return;
			
			_view.renderer.enable(DisplayObjectContainer(_view.getContent()));
		}
		
		private function disableRenderer():void
		{
			if (!_view.renderer) return;
			
			_view.renderer.disable(DisplayObjectContainer(_view.getContent()));
		}
		
		private function changeControlBarHandler( event:Event ):void
		{
			switch (_view.toggleBtnBar.selectedIndex)
			{
				case 0 :
					rewind();
					break;
				case 1 :
					pause();
					break;
				case 2 :
					play();
					break;
			}
		}
		
		private function play():void
		{
			_view.addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function pause():void
		{
			_view.removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function rewind():void
		{
			pause();
			_view.toggleBtnBar.selectedIndex = 1;
			load();
		}
		
		override protected function initScene():void
		{
			var renderer:IRenderer = ComponentUtil.getChildOfType( _scene, IRenderer, true ) as IRenderer;
			_view.renderer = renderer;
			play();
		}
		
		override protected function operationManagerChangedHandler( event:OperationManagerEvent ):void
		{
			// Intentionally blank
		}
			
		protected function enterFrameHandler( event:Event ):void
		{
			if ( !_scene ) return;
			_scene.step();
		}
	}
}