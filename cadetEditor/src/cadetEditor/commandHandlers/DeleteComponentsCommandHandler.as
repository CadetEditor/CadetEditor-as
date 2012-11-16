// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadet.core.IComponent;
	import cadetEditor.operations.RemoveComponentsOperation;
	
	import cadetEditor.contexts.ICadetContext;
	
	import flox.editor.FloxEditor;
	import flox.editor.entities.Commands;
	import flox.editor.utils.FloxEditorUtil;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.core.contexts.IOperationManagerContext;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.validators.ContextSelectionValidator;

	public class DeleteComponentsCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( Commands.DELETE, DeleteComponentsCommandHandler );
			factory.validators.push( new ContextSelectionValidator( FloxEditor.contextManager, ICadetContext, true, IComponent ) );
			return factory;
		}
		
		public function DeleteComponentsCommandHandler() {}
		
		public function execute( parameters:Object ):void
		{
			var context:ICadetContext = FloxEditor.contextManager.getLatestContextOfType(ICadetContext);
			var selection:Array = FloxEditorUtil.getCurrentSelection(ICadetContext, IComponent );
			
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