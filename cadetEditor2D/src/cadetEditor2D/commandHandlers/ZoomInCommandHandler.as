// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.validators.ContextValidator;
	
	import flox.editor.FloxEditor;
	
	import cadetEditor.entities.CadetEditorCommands;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor.controllers.ICadetEditorContextController;
	
	public class ZoomInCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.ZOOM_IN, ZoomInCommandHandler );
			factory.validators.push( new ContextValidator( FloxEditor.contextManager, ICadetEditorContext2D ) );
			return factory;
		}
		
		public function ZoomInCommandHandler() {}
		
		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext2D = FloxEditor.contextManager.getLatestContextOfType( ICadetEditorContext2D );
			context.view2D.zoom += 0.1;
		}
	}
}