// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import flash.events.Event;
	
	import cadet.core.IComponent;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.operations.SelectTemplateOperation;
	
	import flox.editor.FloxEditor;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.operations.AddItemOperation;
	import flox.app.validators.ContextValidator;

	public class ImportTemplateCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.IMPORT_TEMPLATE, ImportTemplateCommandHandler );
			factory.validators.push( new ContextValidator( FloxEditor.contextManager, ICadetEditorContext ) );
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
			var context:ICadetEditorContext = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			
			template.templateID = operation.selectedTemplateID;
			template.exportTemplateID = null;
			context.operationManager.addOperation(new AddItemOperation( template, context.scene.children ));
		}
	}
}