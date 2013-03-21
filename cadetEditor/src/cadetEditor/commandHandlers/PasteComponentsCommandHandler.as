// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadet.entities.ComponentFactory;
	
	import flash.events.Event;
	
	import core.app.CoreApp;
	import core.app.core.commandHandlers.ICommandHandler;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.ResourceSerializerPlugin;
	import core.app.operations.AddItemOperation;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.CloneOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.app.resources.CommandHandlerFactory;
	import core.app.util.IntrospectionUtil;
	import core.app.validators.CollectionValidator;
	import core.app.validators.ContextValidator;
	import core.editor.CoreEditor;
	import core.editor.entities.Commands;
	import core.editor.utils.CoreEditorUtil;

	public class PasteComponentsCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( Commands.PASTE, PasteComponentsCommandHandler );
			factory.validators.push( new ContextValidator( CoreEditor.contextManager, ICadetEditorContext ) );
			factory.validators.push( new CollectionValidator( CoreEditor.copyClipboard, IComponent ) );
			return factory;
		}
		
		private var cadetEditorContext	:ICadetEditorContext;
		private var container			:IComponentContainer;
		
		public function PasteComponentsCommandHandler() {}

		public function execute(parameters:Object):void
		{
			// Grab the list of entities from the clipboard
			var components:Array = CoreEditor.copyClipboard.source;
			
			// Now find an IEntityContainer to paste them in. We do this by checking to see if an IEntitiyContainer is currently selected
			// in any context (such as the library or outliner). If we can't find one we simply drop it into the root of the current
			// cadetEditorContext
			cadetEditorContext = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			var selectedComponents:Array = CoreEditorUtil.getCurrentSelection( null, IComponent );
			if ( selectedComponents.length > 0 )
			{
				container = selectedComponents[0].parentComponent;
			}
			else
			{
				container = cadetEditorContext.scene;
			}
			
			// For each component we are about to paste, grab its associated ComponentFactory class
			// and check if the place we're about to paste it is allowed by the factory's validate function.
			// To keep things simple, we exit if a single component doesn't pass the test
			for each ( var component:IComponent in components )
			{
				var type:Class = IntrospectionUtil.getType( component );
				var componentFactory:ComponentFactory = ComponentFactory(CoreApp.resourceManager.getFactoriesForType( type )[0]);
				
				if ( componentFactory.validate(container) == false )
				{
					trace("[PasteComponentsCommandHandler] Component validation failed. Paste aborted.");
					return;
				}
			}
			
			// First we need to clone these entities so further paste operations are possible
			var plugins:Vector.<ISerializationPlugin> = new Vector.<ISerializationPlugin>();
			plugins.push(new ResourceSerializerPlugin( CoreApp.resourceManager ));
			var cloneOperation:CloneOperation = new CloneOperation( components, plugins );
			cloneOperation.addEventListener(Event.COMPLETE, cloneCompleteHandler);
			CoreEditor.operationManager.addOperation(cloneOperation);
		}
		
		private function cloneCompleteHandler( event:Event ):void
		{
			var cloneOperation:CloneOperation = CloneOperation( event.target );
			var components:Array = cloneOperation.getResult() as Array;
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Paste Components";
			
			var newSelection:Array = [];
			for ( var i:int = 0; i < components.length; i++ )
			{
				var component:IComponent = components[i];
				newSelection.push(component);
				operation.addOperation( new AddItemOperation( component, container.children ) );
			}
			
			operation.addOperation( new ChangePropertyOperation( cadetEditorContext.selection, "source", newSelection ) );
			cadetEditorContext.operationManager.addOperation(operation);
		}
	}
}