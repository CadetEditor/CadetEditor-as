// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadet.core.IComponent;
	import cadetEditor.operations.RemoveComponentsOperation;
	
	import cadetEditor.contexts.ICadetContext;
	
	import core.editor.CoreEditor;
	import core.editor.entities.Commands;
	import core.editor.utils.CoreEditorUtil;
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.appEx.core.contexts.IOperationManagerContext;
	import core.appEx.resources.CommandHandlerFactory;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.validators.ContextSelectionValidator;

	public class DeleteComponentsCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( Commands.DELETE, DeleteComponentsCommandHandler );
			factory.validators.push( new ContextSelectionValidator( CoreEditor.contextManager, ICadetContext, true, IComponent ) );
			return factory;
		}
		
		public function DeleteComponentsCommandHandler() {}
		
		public function execute( parameters:Object ):void
		{
			var context:ICadetContext = CoreEditor.contextManager.getLatestContextOfType(ICadetContext);
			var selection:Array = CoreEditorUtil.getCurrentSelection(ICadetContext, IComponent );
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Delete item(s)"
			
			operation.addOperation( new ChangePropertyOperation( context.selection, "source", [] ) );
			operation.addOperation( new RemoveComponentsOperation( selection, context.scene.dependencyManager ) );
			
			if ( context is IOperationManagerContext )
			{
				IOperationManagerContext(context).operationManager.addOperation( operation );
			}
			else
			{
				operation.execute();
			}
		}
	}
}