// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import flash.events.Event;
	
	import core.app.CoreApp;
	import core.app.core.commandHandlers.ICommandHandler;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.ResourceSerializerPlugin;
	import core.app.core.serialization.Serializer;
	import core.app.operations.CloneOperation;
	import core.app.operations.CompoundOperation;
	import core.app.resources.CommandHandlerFactory;
	import core.app.validators.ContextSelectionValidator;
	import core.editor.CoreEditor;
	import core.editor.entities.Commands;
	import core.editor.utils.CoreEditorUtil;

	public class CopyComponentCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( Commands.COPY, CopyComponentCommandHandler );
			factory.validators.push( new ContextSelectionValidator( CoreEditor.contextManager, null, true, IComponent ) );
			return factory;
		}
		
		public function CopyComponentCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var selection:Array = CoreEditorUtil.getCurrentSelection(null, IComponent );
			
			var clonedSelection:Array = [];
			
			// First we need to filter the selection so we don't end up cloning a parent and it's children more than once.
			for ( var i:int = 0; i < selection.length; i++ )
			{
				var component:IComponent = selection[i];
				
				if ( isComponentChildOf( component, selection ) )
				{
					selection.splice(i,1);
					i--;
				}
			}
			
			
			// Now clone each remaining entity
			var cloneOperations:CompoundOperation = new CompoundOperation();
			var plugins:Vector.<ISerializationPlugin> = new Vector.<ISerializationPlugin>();
			plugins.push(new ResourceSerializerPlugin( CoreApp.resourceManager ));
			for ( i = 0; i < selection.length; i++ )
			{
				component = selection[i];
				var cloneOperation:CloneOperation = new CloneOperation( component, plugins );
				cloneOperations.addOperation(cloneOperation);
			}
			cloneOperations.addEventListener(Event.COMPLETE, cloneCompleteHandler);
			CoreEditor.operationManager.addOperation(cloneOperations);	
		}
		
		private function cloneCompleteHandler( event:Event ):void
		{
			var cloneOperations:CompoundOperation = CompoundOperation( event.target );
			
			var clonedComponents:Array = [];
			for ( var i:int = 0; i < cloneOperations.operations.length; i++ )
			{
				var cloneOperation:CloneOperation = cloneOperations.operations[i];
				var clonedComponent:IComponent = cloneOperation.getResult();
				// We need to null the component's exportTemplateID (if it has one) as we can't have two
				// Component's with the same exportTemplateID
				clonedComponent.exportTemplateID = null;
				clonedComponents.push( clonedComponent );	
			}
			
			CoreEditor.copyClipboard.source = clonedComponents;
		}
		
		private function isComponentChildOf( child:IComponent, components:Array ):Boolean
		{
			for each ( var parentComponent:IComponent in components )
			{
				var container:IComponentContainer = parentComponent as IComponentContainer;
				if ( container == null ) continue;
				if ( child == container ) continue;
				var descendants:Vector.<IComponent> = ComponentUtil.getChildrenOfType( container, IComponentContainer, true );
				if ( descendants.indexOf( child ) != -1 ) return true;
			}
			return false;
		}
	}
}