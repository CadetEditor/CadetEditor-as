// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers 
{
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToggleCadetEditorPropertyCommandHandlerFactory;
	import flox.editor.FloxEditor;
	import flox.app.core.commandHandlers.ICommandHandler;
	
	public class ToggleCadetEditorPropertyCommandHandler implements ICommandHandler
	{
		public var property		:String;
		
		public function ToggleCadetEditorPropertyCommandHandler() 
		{
			
		}
		
		public function execute( parameters:Object ):void
		{
			var context:ICadetEditorContext = FloxEditor.contextManager.getLatestContextOfType( ICadetEditorContext );
			context.scene.userData[property] = !context.scene.userData[property];
		}
	}
}