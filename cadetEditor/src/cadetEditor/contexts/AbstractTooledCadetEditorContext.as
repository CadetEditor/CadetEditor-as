// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.managers.ToolManager;
	import cadetEditor.ui.views.IToolEditorView;
	
	import flox.app.FloxApp;
	import flox.app.resources.IResource;
	import flox.app.util.IntrospectionUtil;

	public class AbstractTooledCadetEditorContext extends AbstractCadetEditorContext
	{
		// Managers
		protected var _toolManager		:ToolManager;
		
		public function AbstractTooledCadetEditorContext()
		{
			
		}
		
		protected function initTools( view:IToolEditorView ):void
		{
			_toolManager = new ToolManager( this, view );
			// Find and add any Tool resources
			var resources:Vector.<IResource> = FloxApp.resourceManager.getResourcesOfType( ToolFactory );
			for ( var i:int = 0; i < resources.length; i++ )
			{
				var toolFactory:ToolFactory = ToolFactory(resources[i]);
				if ( IntrospectionUtil.isRelatedTo(this, toolFactory.target) == false ) continue;
				_toolManager.addTool( toolFactory );
			}
		}
		
		override public function dispose():void
		{
			_toolManager.dispose();
			_toolManager = null;
			super.dispose();
		}
		
		public function enable():void
		{
			_toolManager.enable();
		}
		
		public function disable():void
		{
			_toolManager.disable();
		}
		
		public function get toolManager():ToolManager
		{
			return _toolManager;
		}
	}
}