// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.entities 
{
	import cadetEditor.commandHandlers.ToggleCadetEditorPropertyCommandHandler;
	import cadetEditor.contexts.ICadetEditorContext;
	import core.editor.CoreEditor;
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.appEx.resources.CommandHandlerFactory;
	import core.appEx.validators.ContextValidator;
	
	/**
	 * A specialised CommandHandlerFactory for creating instances of ToggleCadetEditorPropertyCommandHandler.
	 * This factory stores a 'property' variable which it then passes to any instance it creates.
	 * @author Jon
	 */
	public class ToggleCadetEditorPropertyCommandHandlerFactory extends CommandHandlerFactory
	{
		private var property		:String;
		
		public function ToggleCadetEditorPropertyCommandHandlerFactory( command:String, property:String )
		{
			super(command, ToggleCadetEditorPropertyCommandHandler, validators);
			validators.push( new ContextValidator( CoreEditor.contextManager, ICadetEditorContext ) );
			
			this.property = property;
		}
		
		override public function getInstance():Object
		{
			var instance:ToggleCadetEditorPropertyCommandHandler = new ToggleCadetEditorPropertyCommandHandler();
			instance.property = property;
			return instance;
		}
	}
}