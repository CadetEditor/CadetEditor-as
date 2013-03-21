// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.commandHandlers
{
	import core.app.core.commandHandlers.ICommandHandler;
	import core.app.resources.CommandHandlerFactory;
	import core.app.validators.ContextValidator;
	
	import core.editor.CoreEditor;
	
	import cadetEditor.entities.CadetEditorCommands;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor.controllers.ICadetEditorContextController;
	
	import cadetEditor2DS.operations.ZoomExtentsOperation;

	public class ZoomExtentsCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.ZOOM_EXTENTS, ZoomExtentsCommandHandler );
			factory.validators.push( new ContextValidator( CoreEditor.contextManager, ICadetEditorContext2D ) );
			return factory;
		}
		
		public function ZoomExtentsCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext2D = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext2D);
			var operation:ZoomExtentsOperation = new ZoomExtentsOperation( context.view2D );
			operation.execute();
		}
	}
}