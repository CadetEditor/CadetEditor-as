package cadetEditor2DS.contexts
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.IRenderer2D;
	
	import cadetEditor.contexts.AbstractCadetEditorContext;
	import cadetEditor.contexts.ICadetEditorContext;
	
	import cadetEditor2DS.ui.views.CadetView2D;
	
	import core.appEx.events.OperationManagerEvent;
	
	public class CadetContext2D extends AbstractCadetEditorContext implements ICadetEditorContext
	{
		private var _view		:CadetView2D;
		
		public function CadetContext2D()
		{
			_view = new CadetView2D();
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
			
			_view.renderer.enable(_view.getContent().stage);
		}
		
		private function disableRenderer():void
		{
			if (!_view.renderer) return;
			
			_view.renderer.disable();
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
			var renderer:IRenderer2D = ComponentUtil.getChildOfType( _scene, IRenderer2D, true ) as IRenderer2D;
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