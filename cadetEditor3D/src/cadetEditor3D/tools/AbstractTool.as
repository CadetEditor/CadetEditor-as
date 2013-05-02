// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.Away3D;
	
	import cadet3D.components.renderers.Renderer3D;
	
	import cadetEditor.tools.ITool;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.events.RendererChangeEvent;
	import cadetEditor3D.ui.views.CadetEditorView3D;
	
	import core.appEx.core.contexts.IContext;

	public class AbstractTool implements ITool
	{
		protected var enabled	:Boolean = false;
		protected var context	:CadetEditorContext3D;
		protected var view		:CadetEditorView3D;
		protected var renderer	:Renderer3D;
		
		public function AbstractTool()
		{
			
		}
		
		public function init(c:IContext):void
		{
			context = CadetEditorContext3D(c);
			view = context.view3D;
		}
		
		public function dispose():void
		{
			disable();
			if ( renderer )performDisable();
			renderer = null;
			context.removeEventListener(RendererChangeEvent.RENDERER_CHANGE, rendererChangeHandler);
			context = null
			view = null;
		}
		
		public function enable():void
		{
			if ( enabled ) return;
			enabled = true;
			context.addEventListener(RendererChangeEvent.RENDERER_CHANGE, rendererChangeHandler);
			renderer = context.renderer;
			if ( renderer )
			{
				performEnable();
			}
		}
		
		public function disable():void
		{
			if ( !enabled ) return;
			enabled = false;
			
			performDisable();
			renderer = null;
		}
		
		protected function performEnable():void
		{
			
		}
		
		protected function performDisable():void
		{
			
		}
		
		private function rendererChangeHandler( event:RendererChangeEvent ):void
		{
			// It is implicit that this tool is enabled if it is receiving this
			// event.
			if ( renderer )
			{
				performDisable();
			}
			
			renderer = context.renderer;
			if ( renderer )
			{
				performEnable();
			}
		}
	}
}