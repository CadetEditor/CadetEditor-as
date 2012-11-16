// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.tools
{
	import cadetEditor.assets.CadetEditorCursors;
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.tools.ITool;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor.controllers.ICadetEditorContextController;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import flox.ui.managers.CursorManager;
	
	import flox.editor.FloxEditor;
	import flox.app.core.contexts.IContext;
	
	public class PanTool implements ITool
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext2D, PanTool, "Pan", CadetEditorIcons.Pan, [Keyboard.SPACE], false );
		}
		
		private var context			:ICadetEditorContext2D;
		private var storedPanX		:Number;
		private var storedPanY		:Number;
		private var mouseDownPos	:Point;
		
		public function PanTool()
		{
		}
		
		public function init(context:IContext):void
		{
			this.context = ICadetEditorContext2D(context);
		}
		
		public function dispose():void
		{
			context = null;
		}
		
		public function enable():void
		{
			context.view2D.getContent().addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		public function disable():void
		{
			context.view2D.getContent().removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			endDrag();
		}
		
		public function beginDrag():void
		{
			CursorManager.setCursor( CadetEditorCursors.Hand );
			
			mouseDownPos = new Point( FloxEditor.stage.mouseX, FloxEditor.stage.mouseY );
			storedPanX = context.view2D.panX;
			storedPanY = context.view2D.panY;	
			
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		public function endDrag():void
		{
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			mouseDownPos = null;
			CursorManager.setCursor( null );
		}
		
		
		private function mouseDownHandler(event:MouseEvent) : void
		{
			beginDrag();
		}
		
		private function mouseMoveHandler(event:MouseEvent) : void
		{
			if ( mouseDownPos == null ) return;

			var dx:Number = (event.stageX - mouseDownPos.x) / context.view2D.zoom;
			var dy:Number = (event.stageY - mouseDownPos.y) / context.view2D.zoom;
			context.view2D.panX = storedPanX-dx;
			context.view2D.panY = storedPanY-dy;
		}
		
		private function mouseUpHandler(event:MouseEvent) : void
		{
			endDrag();
		}
	}
}