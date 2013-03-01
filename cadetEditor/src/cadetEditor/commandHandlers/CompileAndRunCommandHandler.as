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
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.validators.ContextValidator;
	import flox.editor.FloxEditor;
	import flox.editor.operations.OpenFileOperation;
	
	public class CompileAndRunCommandHandler implements ICommandHandler
	{
		static public function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.BUILD_AND_RUN, CompileAndRunCommandHandler );
			factory.validators.push( new ContextValidator( FloxEditor.contextManager, ICadetEditorContext ) );
			return factory;
		}
		
		private var tempURI			:URI;
		private var editorContext	:ICadetEditorContext;
		
		private var cadetFileExtension:String = ".cdt";
		
		public function CompileAndRunCommandHandler()
		{
			
		}
		
		public function execute( parameters:Object ):void
		{
			editorContext = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			
			var compileOperation:CompileOperation = new CompileOperation( editorContext.scene );
			compileOperation.addEventListener( Event.COMPLETE, compileCompleteHandler );
			FloxEditor.operationManager.addOperation( compileOperation );
		}
		
		private function compileCompleteHandler( event:Event ):void
		{
			var compileOperation:CompileOperation = CompileOperation( event.target );
			
			tempURI = new URI( "memory/" + editorContext.uri.getFilename(true) + cadetFileExtension );
			var serializeAndWriteFileOperation:SerializeAndWriteCadetFileOperation = new SerializeAndWriteCadetFileOperation( compileOperation.getResult(), tempURI, FloxApp.fileSystemProvider, FloxApp.resourceManager );
			serializeAndWriteFileOperation.addEventListener( Event.COMPLETE, completeHandler );
			FloxEditor.operationManager.addOperation( serializeAndWriteFileOperation );
		}
		
		private function completeHandler( event:Event ):void
		{
			var openFileOperation:OpenFileOperation = new OpenFileOperation( tempURI, FloxApp.fileSystemProvider, FloxEditor.settingsManager );
			FloxEditor.operationManager.addOperation( openFileOperation );
		}
	}
}