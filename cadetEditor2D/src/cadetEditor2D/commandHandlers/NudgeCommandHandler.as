// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.transforms.Transform2D;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	
	import flash.ui.Keyboard;
	
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.appEx.core.contexts.IContext;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.resources.CommandHandlerFactory;
	import core.appEx.validators.ContextSelectionValidator;
	import core.editor.CoreEditor;
	import core.editor.utils.CoreEditorUtil;
	
	public class NudgeCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.NUDGE, NudgeCommandHandler );
			factory.validators.push( new ContextSelectionValidator( CoreEditor.contextManager, ICadetEditorContext, true, IComponentContainer ) );
			return factory;
		}
		
		public function NudgeCommandHandler() {}
		
		public function execute(parameters:Object):void
		{
			//var context:ICadetEditorContext = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			var context:IContext = CoreEditor.contextManager.getCurrentContext();
			if (context is ICadetEditorContext == false) return;
			
			var editorContext:ICadetEditorContext = ICadetEditorContext(context);
			
			var selectedComponents:Array = CoreEditorUtil.getCurrentSelection( ICadetEditorContext, IComponentContainer );
			var selectedComponent:IComponentContainer = selectedComponents[0];
			
			var transform:Transform2D = ComponentUtil.getChildOfType( selectedComponent, Transform2D, false );
			
			if ( transform == null ) return;
			
			var dx:Number = 0;
			var dy:Number = 0;
			var keyCode:uint = CoreEditor.keyBindingManager.getLastKeyPressed();
			
			switch ( keyCode )
			{
				case Keyboard.LEFT :
					dx = -1;
					break;
				case Keyboard.RIGHT :
					dx = 1;
					break;
				case Keyboard.UP :
					dy = -1;
					break;
				case Keyboard.DOWN :
					dy = 1;
					break;
			}
			
			if ( CoreEditor.keyBindingManager.isKeyDown(Keyboard.SHIFT) )
			{
				dx *= 10;
				dy *= 10;
			}
			
			if ( dx == 0 && dy == 0 ) return;
			
			var compoundOperation:UndoableCompoundOperation = new UndoableCompoundOperation();
			compoundOperation.label = "Nudge";			
			
			for ( var i:uint = 0; i < selectedComponents.length; i ++ )
			{
				selectedComponent = selectedComponents[i];
				transform = ComponentUtil.getChildOfType( selectedComponent, Transform2D, false );
				
				if ( transform ) {
					compoundOperation.addOperation( new ChangePropertyOperation( transform, "x", transform.x + dx ) );
					compoundOperation.addOperation( new ChangePropertyOperation( transform, "y", transform.y + dy ) );
				}
			}
			
			editorContext.operationManager.addOperation( compoundOperation );
		}
	}
}