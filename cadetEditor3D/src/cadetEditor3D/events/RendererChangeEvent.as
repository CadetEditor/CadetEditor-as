// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.events
{
	import cadet.core.IRenderer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class RendererChangeEvent extends Event
	{
		public static const RENDERER_CHANGE		:String = "rendererChange";
		
		private var _oldRenderer	:IRenderer;
		private var _newRenderer	:IRenderer;
		
		public function RendererChangeEvent( type:String, oldRenderer:IRenderer, newRenderer:IRenderer, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
			_oldRenderer = oldRenderer;
			_newRenderer = newRenderer;
		}
		
		override public function clone():Event
		{
			return new RendererChangeEvent( RendererChangeEvent.RENDERER_CHANGE, _oldRenderer, _newRenderer, bubbles, cancelable );
		}
		
		
		public function get oldRenderer():IRenderer
		{
			return _oldRenderer;
		}

		public function get newRenderer():IRenderer
		{
			return _newRenderer;
		}
	}
}