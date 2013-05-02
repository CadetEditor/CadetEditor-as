// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.operations.CompileOperation;
	import cadetEditor.operations.SerializeAndWriteCadetFileOperation;
	
	import flash.events.Event;
	
	import core.app.CoreApp;
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.app.entities.URI;
	import core.appEx.resources.CommandHandlerFactory;
	import core.appEx.validators.ContextValidator;
	import core.editor.CoreEditor;
	import core.editor.operations.OpenFileOperation;
	
	public class CompileAndRunCommandHandler implements ICommandHandler
	{
		static public function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.BUILD_AND_RUN, CompileAndRunCommandHandler );
			factory.validators.push( new ContextValidator( CoreEditor.contextManager, ICadetEditorContext ) );
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
			editorContext = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			
			var compileOperation:CompileOperation = new CompileOperation( editorContext.scene );
			compileOperation.addEventListener( Event.COMPLETE, compileCompleteHandler );
			CoreEditor.operationManager.addOperation( compileOperation );
		}
		
		private function compileCompleteHandler( event:Event ):void
		{
			var compileOperation:CompileOperation = CompileOperation( event.target );
			
			tempURI = new URI( "memory/" + editorContext.uri.getFilename(true) + cadetFileExtension );
			var serializeAndWriteFileOperation:SerializeAndWriteCadetFileOperation = new SerializeAndWriteCadetFileOperation( compileOperation.getResult(), tempURI, CoreApp.fileSystemProvider, CoreApp.resourceManager );
			serializeAndWriteFileOperation.addEventListener( Event.COMPLETE, completeHandler );
			CoreEditor.operationManager.addOperation( serializeAndWriteFileOperation );
		}
		
		private function completeHandler( event:Event ):void
		{
			var openFileOperation:OpenFileOperation = new OpenFileOperation( tempURI, CoreApp.fileSystemProvider, CoreEditor.settingsManager );
			CoreEditor.operationManager.addOperation( openFileOperation );
		}
	}
}