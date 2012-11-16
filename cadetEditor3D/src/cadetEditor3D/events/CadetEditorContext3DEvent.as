// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.events
{
	import flash.events.Event;
	
	public class CadetEditorContext3DEvent extends Event
	{
		public static const COORDINATE_SPACE_CHANGE	:String = "coordinateSpaceChange";
		
		public function CadetEditorContext3DEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event	
		{
			return new CadetEditorContext3DEvent( type );
		}
	}
}