// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.operations.CompileOperation;
	import cadetEditor.operations.SerializeAndWriteCadetFileOperation;
	
	import flash.events.Event;
	
	import flox.app.FloxApp;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.entities.URI;
	import flox.app.operations.SerializeAndWriteFileOperation;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.validators.ContextValidator;
	import flox.editor.FloxEditor;
	
	public class CompileCommandHandler implements ICommandHandler
	{
		static public function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.BUILD, CompileCommandHandler );
			factory.validators.push( new ContextValidator( FloxEditor.contextManager, ICadetEditorContext ) );
			return factory;
		}
		
		protected var editorContext	:ICadetEditorContext;
		
		private var cadetFileExtension:String = ".cdt";
		
		public function CompileCommandHandler()
		{
			
		}

		public function execute( parameters:Object ):void
		{
			editorContext = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			
			var compileOperation:CompileOperation = new CompileOperation(  editorContext.scene );
			compileOperation.addEventListener( Event.COMPLETE, compileCompleteHandler );
			FloxEditor.operationManager.addOperation( compileOperation );
		}
		
		private function compileCompleteHandler( event:Event ):void
		{
			var compileOperation:CompileOperation = CompileOperation( event.target );
			
			var uri:URI = editorContext.uri.getParentURI();
			uri.path = uri.path + editorContext.uri.getFilename(true) + cadetFileExtension;
			if ( uri.getParentURI().path == "" )
			{
				uri = new URI( "memory/" + uri.path );
			}
			var serializeAndWriteFileOperation:SerializeAndWriteCadetFileOperation = new SerializeAndWriteCadetFileOperation( compileOperation.getResult(), uri, FloxApp.fileSystemProvider, FloxApp.resourceManager );
			serializeAndWriteFileOperation.addEventListener( Event.COMPLETE, completeHandler );
			FloxEditor.operationManager.addOperation( serializeAndWriteFileOperation );
		}
		
		protected function completeHandler( event:Event ):void {}
	}
}