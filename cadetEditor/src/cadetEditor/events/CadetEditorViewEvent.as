// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.events
{
	import flash.events.Event;
	
	public class CadetEditorViewEvent extends Event
	{
		public static const RENDERER_CHANGED				:String = "rendererChanged";
		public static const VIEWPORT_CHANGED				:String = "viewportChanged";
		
		public function CadetEditorViewEvent(type:String)
		{
			super(type);
		}
	}
}