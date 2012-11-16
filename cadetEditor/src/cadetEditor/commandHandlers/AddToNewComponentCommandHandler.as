// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import flash.events.MouseEvent;
	
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.ui.panels.AddComponentPanel;
	
	import flox.editor.FloxEditor;
	import flox.editor.utils.FloxEditorUtil;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.RemoveItemOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.util.StringUtil;
	import flox.app.validators.ContextSelectionValidator;


	/**
	 * This CommandHandler takes any selected IComponents, removes them from the scene, then re-adds them as children of a new ComponentContainer
	 * (which the user can give a name to in a pop-up panel). This container is then added to the scene.
	 * @author Jonathan
	 * 
	 */	
	public class AddToNewComponentCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.ADD_TO_NEW_COMPONENT, AddToNewComponentCommandHandler );
			factory.validators.push( new ContextSelectionValidator( FloxEditor.contextManager, ICadetEditorContext, true, IComponent ) );
			return factory;
		}
		
		public function AddToNewComponentCommandHandler() {}
		
		private var context		:ICadetEditorContext;
		private var components	:Array;
		
		private var panel		:AddComponentPanel;
		
		public function execute(parameters:Object):void
		{
			context = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			components = FloxEditorUtil.getCurrentSelection(ICadetEditorContext, IComponent);
			
			openPanel();
		}
		
		private function clickOkHandler( event:MouseEvent ):void
		{
			var newComponent:ComponentContainer = new ComponentContainer();
			//newComponent.name = StringUtil.trim(panel.nameField.text);
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Add to new Component";
			
			for each ( var component:IComponent in components )
			{
				operation.addOperation( new RemoveItemOperation( component, component.parentComponent.children ) );
				operation.addOperation( new AddItemOperation( component, newComponent.children ) );
			}
			operation.addOperation( new AddItemOperation( newComponent, context.scene.children ) );
			context.operationManager.addOperation(operation);
			
			closePanel();
		}
		
		private function clickCancelHandler( event:MouseEvent ):void
		{
			closePanel();
		}
		
		private function openPanel():void
		{
			panel = new AddComponentPanel();
			FloxEditor.viewManager.addPopUp(panel);
			
			panel.label = "Add To New Component";
			
			panel.okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
		}
		
		private function closePanel():void
		{
			panel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			FloxEditor.viewManager.removePopUp(panel);
		}
	}
}