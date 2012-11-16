// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import cadet.core.IComponentContainer;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor2D.operations.CenterOriginsOperation;
	
	import flox.editor.FloxEditor;
	import flox.editor.utils.FloxEditorUtil;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.validators.ContextSelectionValidator;

	/**
	 * Given a selection of IComponentContainers, this CommandHandler delegates the task of finding any geometry on these, and transforming
	 * them so their origin is centered to match up with the 'center of gravity'.
	 * @author Jonathan
	 * 
	 */	
	public class CenterOriginCentroidCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.CENTER_ORIGIN_CENTROID, CenterOriginCentroidCommandHandler );
			factory.validators.push( new ContextSelectionValidator( FloxEditor.contextManager, ICadetEditorContext, true, IComponentContainer ) );
			return factory;
		}
		
		public function CenterOriginCentroidCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			var components:Array = FloxEditorUtil.getCurrentSelection( ICadetEditorContext, IComponentContainer );
			
			var operation:CenterOriginsOperation = new CenterOriginsOperation( components, true );
			context.operationManager.addOperation(operation);
		}
	}
}