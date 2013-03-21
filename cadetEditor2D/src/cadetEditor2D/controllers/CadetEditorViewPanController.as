// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.controllers
{
	import cadetEditor.assets.CadetEditorCursors;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.tools.ITool;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.tools.PanTool;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	import core.ui.managers.CursorManager;
	
	import core.editor.CoreEditor;
	import core.editor.core.CoreEditorEnvironment;
	
	/**
	 * This controller is created within the CadetEditorContext. It's purpose is to augment the context with panning behaviour without
	 * making the context dependant on this class. 
	 * @author Jonathan Pace
	 * 
	 */	
	public class CadetEditorViewPanController
	{
		private var context			:ICadetEditorContext2D;
		private var view			:ICadetEditorView2D;
		private var prevTool		:ITool;
		
		public function CadetEditorViewPanController( context:ICadetEditorContext2D )
		{
			this.context = context;
			view = context.view2D;
			enable();
		}
		
		public function enable() : void
		{
			if ( CoreEditor.environment == CoreEditorEnvironment.AIR )
			{
				view.container.addEventListener("rightMouseDown", rightMouseDownHandler);
			}
			
			view.container.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
		public function disable() : void
		{
			view.container.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			
			if ( Capabilities.playerType == "Desktop" )
			{
				view.container.removeEventListener("rightMouseDown", rightMouseDownHandler);
			}
						
			CursorManager.setCursor( null );
		}
		
		private function rightMouseDownHandler( event:MouseEvent ):void
		{
			prevTool = context.toolManager.selectedTool;
			for each ( var tool:ITool in context.toolManager.tools )
			{
				if ( tool is PanTool )
				{
					context.toolManager.selectedTool = tool;
					PanTool(tool).beginDrag();
				}
			}
			CoreEditor.stage.addEventListener("rightMouseUp", rightMouseUpHandler);
		}
		
		private function rightMouseUpHandler( event:MouseEvent ):void
		{
			if ( context.toolManager.selectedTool is PanTool )
			{
				PanTool(context.toolManager.selectedTool).endDrag();
			}
			CoreEditor.stage.removeEventListener("rightMouseUp", rightMouseUpHandler);
			context.toolManager.selectedTool = prevTool;
		}
		
		protected function mouseWheelHandler( event:MouseEvent ):void
		{
			var direction:int = event.delta < 0 ? -1 : 1;
			view.zoom += 0.25 * direction;
		}
		
		
	}
}