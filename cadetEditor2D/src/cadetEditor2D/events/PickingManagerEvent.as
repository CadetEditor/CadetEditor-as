// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.events
{
	import cadet2D.components.skins.ISkin2D;
	
	import flash.events.MouseEvent;
	
	
	public class PickingManagerEvent extends MouseEvent
	{
		static public const MOUSE_DOWN_BACKGROUND		:String = "mouseDownBackground";
		static public const MOUSE_UP_BACKGROUND			:String = "mouseUpBackground";
		static public const CLICK_BACKGROUND			:String = "clickBackground";
		static public const DOUBLE_CLICK_BACKGROUND		:String = "doubleClickBackground";
		static public const MOUSE_DOWN_SKINS			:String = "mouseDownSkins";
		static public const MOUSE_UP_SKINS				:String = "mouseUpSkins";
		static public const CLICK_SKINS					:String = "clickSkins";
		static public const DOUBLE_CLICK_SKINS			:String = "doubleClickSkins";
		static public const ROLL_OVER_SKIN				:String = "rollOverSkin";
		static public const ROLL_OUT_SKIN				:String = "rollOutSkin";
		static public const MOUSE_UP_STAGE				:String = "mouseUpStage";
		static public const MOUSE_MOVE_CONTAINER		:String = "mouseMoveContainer";
		static public const MOUSE_DOWN_CONTAINER		:String = "mouseDownContainer";
		static public const MOUSE_UP_CONTAINER			:String = "mouseUpContainer";
		static public const CLICK_CONTAINER				:String = "clickContainer";
		static public const DOUBLE_CLICK_CONTAINER		:String = "doubleClickContainer";
		static public const ROLL_OVER_CONTAINER			:String = "rollOverContainer";
		static public const ROLL_OUT_CONTAINER			:String = "rollOutContainer";
		
		
		private var _skinsUnderMouse	:Array;
		private var _skin				:ISkin2D;
		
		public function PickingManagerEvent(type:String, skinsUnderMouse:Array = null, skin:ISkin2D = null, localX:Number = 0, localY:Number = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false )
		{
			super(type, false, false, localX, localY, null, ctrlKey, altKey, shiftKey, buttonDown );
			_skinsUnderMouse = skinsUnderMouse;
			_skin = skin;
		}
		
		public function get skin():ISkin2D { return _skin; }
		public function get skinsUnderMouse():Array { return _skinsUnderMouse; }
	}
}