// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers 
{
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToggleCadetEditorPropertyCommandHandlerFactory;
	import core.editor.CoreEditor;
	import core.appEx.core.commandHandlers.ICommandHandler;
	
	public class ToggleCadetEditorPropertyCommandHandler implements ICommandHandler
	{
		public var property		:String;
		
		public function ToggleCadetEditorPropertyCommandHandler() 
		{
			
		}
		
		public function execute( parameters:Object ):void
		{
			var context:ICadetEditorContext = CoreEditor.contextManager.getLatestContextOfType( ICadetEditorContext );
			context.scene.userData[property] = !context.scene.userData[property];
		}
	}
}