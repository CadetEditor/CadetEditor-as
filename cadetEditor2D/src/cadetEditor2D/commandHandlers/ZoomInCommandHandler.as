// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.appEx.resources.CommandHandlerFactory;
	import core.appEx.validators.ContextValidator;
	
	import core.editor.CoreEditor;
	
	import cadetEditor.entities.CadetEditorCommands;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	
	public class ZoomInCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.ZOOM_IN, ZoomInCommandHandler );
			factory.validators.push( new ContextValidator( CoreEditor.contextManager, ICadetEditorContext2D ) );
			return factory;
		}
		
		public function ZoomInCommandHandler() {}
		
		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext2D = CoreEditor.contextManager.getLatestContextOfType( ICadetEditorContext2D );
			context.view2D.zoom += 0.1;
		}
	}
}