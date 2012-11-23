package cadetEditor3D.events
{
	import away3d.entities.Entity;
	import away3d.events.MouseEvent3D;
	
	import flash.events.Event;
	
	public class MouseEvent3DEx extends MouseEvent3D
	{
		public static const MOUSE_OVER : String = "mouseOver3d";
		public static const MOUSE_OUT : String = "mouseOut3d";
		public static const MOUSE_UP : String = "mouseUp3d";
		public static const MOUSE_DOWN : String = "mouseDown3d";
		public static const MOUSE_MOVE : String = "mouseMove3d";
		//public static const ROLL_OVER : String = "rollOver3d";
		//public static const ROLL_OUT : String = "rollOut3d";
		public static const CLICK : String = "click3d";
		public static const DOUBLE_CLICK : String = "doubleClick3d";
		public static const MOUSE_WHEEL : String = "mouseWheel3d";
		
		public var entities	:Vector.<Entity>;
		
		public function MouseEvent3DEx(type:String)
		{
			super(type);
			
			entities = new Vector.<Entity>();
		}
		
		override public function clone():Event
		{
			var result : MouseEvent3DEx = new MouseEvent3DEx(type);
			
			if (isDefaultPrevented())
				result.preventDefault();
			
			result.screenX = screenX;
			result.screenY = screenY;
			
			result.view = view;
			result.object = object;
			result.renderable = renderable;
			result.material = material;
			result.uv = uv;
			result.localPosition = localPosition;
			result.localNormal = localNormal;
			
			result.ctrlKey = ctrlKey;
			result.shiftKey = shiftKey;
			
			result.entities = entities.slice();
			
			return result;
		}
	}
}