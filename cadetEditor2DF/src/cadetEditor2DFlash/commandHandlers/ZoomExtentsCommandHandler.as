// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.commandHandlers
{
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.validators.ContextValidator;
	
	import flox.editor.FloxEditor;
	
	import cadetEditor.entities.CadetEditorCommands;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor.controllers.ICadetEditorContextController;
	
	import cadetEditor2DFlash.operations.ZoomExtentsOperation;

	public class ZoomExtentsCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.ZOOM_EXTENTS, ZoomExtentsCommandHandler );
			factory.validators.push( new ContextValidator( FloxEditor.contextManager, ICadetEditorContext2D ) );
			return factory;
		}
		
		public function ZoomExtentsCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext2D = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext2D);
			var operation:ZoomExtentsOperation = new ZoomExtentsOperation( context.view2D );
			operation.execute();
		}
	}
}