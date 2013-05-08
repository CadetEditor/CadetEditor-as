// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.util
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import core.editor.CoreEditor;
	
	[Event(type="cadetEditor.util.DragDetector", name="beginDrag")];
	public class DragDetector extends EventDispatcher
	{
		static public const BEGIN_DRAG		:String = "beginDrag";
		
		private var displayObject:DisplayObject;
		private var tolerance:Number = 1;
		private var pressPoint:Point;
		
		public function DragDetector( displayObject:DisplayObject, tolerance:Number = 1 )
		{
			this.displayObject = displayObject;
			this.tolerance = tolerance;
			
			displayObject.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			CoreEditor.stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpStageHandler );
			pressPoint = new Point( displayObject.mouseX,displayObject.mouseY );
		}
		
		public function destroy():void
		{
			CoreEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
			displayObject.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			displayObject = null;
			pressPoint = null;
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			var dx:Number = displayObject.mouseX-pressPoint.x;
			var dy:Number = displayObject.mouseY-pressPoint.y;
			if (dx*dx + dy*dy < tolerance*tolerance) return;
			dispatchEvent(new Event(BEGIN_DRAG));
			destroy();
		}
		
		protected function mouseUpStageHandler(event:Event):void
		{
			destroy();
		}

	}
}