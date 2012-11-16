// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.events
{
	import away3d.containers.View3D;
	import away3d.core.base.IRenderable;
	import away3d.core.base.Object3D;
	import away3d.entities.Entity;
	import away3d.materials.MaterialBase;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	public class DetailedMouse3DEvent extends Event
	{
		public static const MOUSE_OVER 		:String = "mouseOver";
		public static const MOUSE_OUT 		:String = "mouseOut";
		public static const MOUSE_UP 		:String = "mouseUp";
		public static const MOUSE_DOWN 		:String = "mouseDown";
		public static const MOUSE_MOVE 		:String = "mouseMove";
		public static const CLICK 			:String = "click";
		public static const DOUBLE_CLICK 	:String = "doubleClick";
		public static const MOUSE_WHEEL 	:String = "mouseWheel";
		
		
		public var entities	:Vector.<Entity>;
		public var screenX 	:Number;
		public var screenY 	:Number;
		public var view 	:View3D;
		public var ctrlKey 	:Boolean;
		public var altKey 	:Boolean;
		public var shiftKey :Boolean;
		public var delta 	:int;
		
		/**
		 * Create a new MouseEvent3D object.
		 * @param type The type of the MouseEvent3D.
		 */
		public function DetailedMouse3DEvent(type : String)
		{
			super(type, true, true);
		}
		
		/**
		 * Creates a copy of the MouseEvent3D object and sets the value of each property to match that of the original.
		 */
		public override function clone() : Event
		{
			var result :DetailedMouse3DEvent = new DetailedMouse3DEvent(type);
			
			if (isDefaultPrevented())
				result.preventDefault();
			
			result.screenX = screenX;
			result.screenY = screenY;
			result.view = view;
			result.entities = entities;
			result.ctrlKey = ctrlKey;
			result.altKey = altKey;
			result.shiftKey = shiftKey;
			
			return result;
		}
	}
}