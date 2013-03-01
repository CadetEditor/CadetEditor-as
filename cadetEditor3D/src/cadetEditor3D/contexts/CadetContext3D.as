package cadetEditor3D.contexts
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import cadet.util.ComponentUtil;
	
	import cadet3D.components.renderers.IRenderer3D;
	
	import cadetEditor.contexts.AbstractCadetEditorContext;
	import cadetEditor.contexts.ICadetEditorContext;
	
	import cadetEditor3D.ui.views.CadetView3D;
	
	import flox.app.events.OperationManagerEvent;
	
	public class CadetContext3D extends AbstractCadetEditorContext implements ICadetEditorContext
	{
		private var _view		:CadetView3D;
		
		public function CadetContext3D()
		{
			_view = new CadetView3D();
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
			_view.toggleBtnBar.selectedIndex = 2;
			play();
			
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
			var renderer:IRenderer3D = ComponentUtil.getChildOfType( _scene, IRenderer3D, true ) as IRenderer3D;
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

