// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import flash.events.Event;
	
	import cadet.core.IComponent;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.operations.SelectTemplateOperation;
	
	import core.editor.CoreEditor;
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.appEx.resources.CommandHandlerFactory;
	import core.app.operations.AddItemOperation;
	import core.appEx.validators.ContextValidator;

	public class ImportTemplateCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.IMPORT_TEMPLATE, ImportTemplateCommandHandler );
			factory.validators.push( new ContextValidator( CoreEditor.contextManager, ICadetEditorContext ) );
			return factory;
		}
		
		
		public function ImportTemplateCommandHandler() {}
		

		/**
		 * 
		 * @param parameters Accepts the following parameters 'uri'
		 * 
		 */		
		public function execute(parameters:Object):void
		{
			var operation:SelectTemplateOperation = new SelectTemplateOperation( parameters.uri );
			operation.addEventListener(Event.COMPLETE, selectTemplateCompleteHandler);
			operation.execute();
		}
		
		private function selectTemplateCompleteHandler( event:Event ):void
		{
			var operation:SelectTemplateOperation = SelectTemplateOperation(event.target);
			if ( operation.selectedTemplate == null ) return;
			
			var template:IComponent = operation.selectedTemplate;
			var context:ICadetEditorContext = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			
			template.templateID = operation.selectedTemplateID;
			template.exportTemplateID = null;
			context.operationManager.addOperation(new AddItemOperation( template, context.scene.children ));
		}
	}
}