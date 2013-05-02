// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import cadet.core.IComponentContainer;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor2D.operations.CenterOriginsOperation;
	
	import core.editor.CoreEditor;
	import core.editor.utils.CoreEditorUtil;
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.appEx.resources.CommandHandlerFactory;
	import core.appEx.validators.ContextSelectionValidator;

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
			factory.validators.push( new ContextSelectionValidator( CoreEditor.contextManager, ICadetEditorContext, true, IComponentContainer ) );
			return factory;
		}
		
		public function CenterOriginCentroidCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			var components:Array = CoreEditorUtil.getCurrentSelection( ICadetEditorContext, IComponentContainer );
			
			var operation:CenterOriginsOperation = new CenterOriginsOperation( components, true );
			context.operationManager.addOperation(operation);
		}
	}
}