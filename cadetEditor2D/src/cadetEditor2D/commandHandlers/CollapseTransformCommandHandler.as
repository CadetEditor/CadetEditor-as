// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import cadet.core.IComponentContainer;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor2D.operations.CollapseTransformsOperation;
	
	import core.editor.CoreEditor;
	import core.editor.utils.CoreEditorUtil;
	import core.app.core.commandHandlers.ICommandHandler;
	import core.app.resources.CommandHandlerFactory;
	import core.app.validators.ContextSelectionValidator;

	/**
	 * Given a selection of ComponentContainers, this CommandHandler delegates out the task of collapse any geometry found on these to an operation. 
	 * @author Jonathan
	 * 
	 */	
	public class CollapseTransformCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.COLLAPSE_TRANSFORM, CollapseTransformCommandHandler );
			factory.validators.push( new ContextSelectionValidator( CoreEditor.contextManager, ICadetEditorContext, true, IComponentContainer ) );
			return factory;
		}
		
		public function CollapseTransformCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			var components:Array = CoreEditorUtil.getCurrentSelection( ICadetEditorContext, IComponentContainer );
			
			var operation:CollapseTransformsOperation = new CollapseTransformsOperation( components );
			context.operationManager.addOperation(operation);
		}
	}
}