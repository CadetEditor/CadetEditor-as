// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.views
{
	import cadet.core.IRenderer;
	import cadet.events.InvalidationEvent;
	
	import cadetEditor.assets.CadetEditorIcons;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import flox.ui.components.Button;
	import flox.ui.components.RadioButtonGroup;
	import flox.ui.components.UIComponent;
	import flox.ui.layouts.HorizontalLayout;
	
	import flox.editor.core.IViewContainer;
	
	public class CadetView extends UIComponent
	{
		// Child elements
		private var container		:UIComponent;
		public  var toggleBtnBar	:RadioButtonGroup;
		private var rewindBtn		:Button;
		private var pauseBtn		:Button;
		private var playBtn			:Button;
		
		// Properties
		private var _renderer		:IRenderer;
		
		public function CadetView()
		{
			
		}
		
		override protected function init():void
		{
			container = new UIComponent();
			addChild(container);
			
			toggleBtnBar = new RadioButtonGroup();
			
			rewindBtn = new Button();
			rewindBtn.icon = CadetEditorIcons.Rewind;
			toggleBtnBar.addChild(rewindBtn);
			
			pauseBtn = new Button();
			pauseBtn.icon = CadetEditorIcons.Pause;
			toggleBtnBar.addChild(pauseBtn);
			
			playBtn = new Button();
			playBtn.icon = CadetEditorIcons.Play;
			toggleBtnBar.addChild(playBtn);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		override protected function validate():void
		{
			if ( _renderer )
			{
				_renderer.viewportWidth = _width;
				_renderer.viewportHeight = _height;
			}
		}
		
		private function addedToStageHandler( event:Event ):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			IViewContainer(parent.parent).actionBar.addChild(toggleBtnBar);
		}
		
		public function set renderer( value:IRenderer ):void
		{
			if ( value is IRenderer )
			{
				if ( _renderer )
				{
					_renderer.removeEventListener(InvalidationEvent.INVALIDATE, invalidateRendererHandler);
					//container.removeChild(_renderer.viewport);
					_renderer.disable(this);//container);
				}
				_renderer = value;
				if ( _renderer )
				{
					_renderer.addEventListener(InvalidationEvent.INVALIDATE, invalidateRendererHandler);
					//container.addChild(_renderer.viewport);
					_renderer.enable(this);//container);
				}
			}
			
			invalidate();
		}
		public function get renderer():IRenderer { return _renderer; }
		
		private function invalidateRendererHandler( event:InvalidationEvent ):void
		{
			invalidate();
		}
		
		public function get viewportWidth():int
		{
			return _width;
		}
		
		public function get viewportHeight():int
		{
			return _height;
		}
	}
}
