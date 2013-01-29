// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadet.entities.ComponentFactory;
	
	import flash.events.Event;
	
	import flox.app.FloxApp;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.core.serialization.ISerializationPlugin;
	import flox.app.core.serialization.ResourceSerializerPlugin;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.CloneOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.util.IntrospectionUtil;
	import flox.app.validators.CollectionValidator;
	import flox.app.validators.ContextValidator;
	import flox.editor.FloxEditor;
	import flox.editor.entities.Commands;
	import flox.editor.utils.FloxEditorUtil;

	public class PasteComponentsCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( Commands.PASTE, PasteComponentsCommandHandler );
			factory.validators.push( new ContextValidator( FloxEditor.contextManager, ICadetEditorContext ) );
			factory.validators.push( new CollectionValidator( FloxEditor.copyClipboard, IComponent ) );
			return factory;
		}
		
		private var cadetEditorContext	:ICadetEditorContext;
		private var container			:IComponentContainer;
		
		public function PasteComponentsCommandHandler() {}

		public function execute(parameters:Object):void
		{
			// Grab the list of entities from the clipboard
			var components:Array = FloxEditor.copyClipboard.source;
			
			// Now find an IEntityContainer to paste them in. We do this by checking to see if an IEntitiyContainer is currently selected
			// in any context (such as the library or outliner). If we can't find one we simply drop it into the root of the current
			// cadetEditorContext
			cadetEditorContext = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			var selectedComponents:Array = FloxEditorUtil.getCurrentSelection( null, IComponent );
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
				var componentFactory:ComponentFactory = ComponentFactory(FloxApp.resourceManager.getFactoriesForType( type )[0]);
				
				if ( componentFactory.validate(container) == false )
				{
					trace("[PasteComponentsCommandHandler] Component validation failed. Paste aborted.");
					return;
				}
			}
			
			// First we need to clone these entities so further paste operations are possible
			var plugins:Vector.<ISerializationPlugin> = new Vector.<ISerializationPlugin>();
			plugins.push(new ResourceSerializerPlugin( FloxApp.resourceManager ));
			var cloneOperation:CloneOperation = new CloneOperation( components, plugins );
			cloneOperation.addEventListener(Event.COMPLETE, cloneCompleteHandler);
			FloxEditor.operationManager.addOperation(cloneOperation);
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