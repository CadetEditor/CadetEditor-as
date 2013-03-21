// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadet.entities.ComponentFactory;
	import cadetEditor.ui.panels.AddComponentPanel;
	
	import core.app.CoreApp;
	import core.app.core.commandHandlers.ICommandHandler;
	import core.app.operations.AddItemOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.app.resources.CommandHandlerFactory;
	import core.app.resources.IResource;
	import core.app.validators.ContextValidator;
	import core.data.ArrayCollection;
	import core.editor.CoreEditor;
	import core.ui.components.Button;
	
	/**
	 * All of the AddItemOperations created by this CommandHandler are stored in it's UndoableOperation.
	 * This allows clickCancelHandler() to simply call gotoPreviousOperation() to remove all added items.
	 * 
	 * @author Jonathan
	 * 
	 */	
	public class AddComponentCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory =  new CommandHandlerFactory( CadetEditorCommands.ADD_COMPONENT, AddComponentCommandHandler );
			factory.validators.push( new ContextValidator( CoreEditor.contextManager, ICadetEditorContext, false ) );
			return factory;
		}
		
		private var cadetEditorContext	:ICadetEditorContext;
		private var componentFactories	:Vector.<IResource>;
		private var panel				:AddComponentPanel;
		private var containers			:Array;
		private var operation			:UndoableCompoundOperation;
		
		public function AddComponentCommandHandler() {}
		
		
		public function execute(parameters:Object):void
		{
			cadetEditorContext = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			componentFactories = CoreApp.resourceManager.getResourcesOfType( ComponentFactory );
			
			operation = new UndoableCompoundOperation();
			operation.label = "Add Component(s)";
			
			cadetEditorContext.operationManager.addOperation(operation);
			
			// Create the panel and add it as a pop-up
			panel = new AddComponentPanel();
			CoreEditor.viewManager.addPopUp(panel);
			panel.okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
			panel.tree.dataProvider = cadetEditorContext.scene;
			panel.tree.validateNow();
			
			var selection:Array = cadetEditorContext.selection.source.slice();
			if ( selection.length == 0 )
			{
				panel.tree.setItemOpened( cadetEditorContext.scene, true );
				panel.tree.selectedItem = cadetEditorContext.scene;
			}
			else
			{
				for each ( var item:IComponent in selection )
				{
					panel.tree.openToItem(item)
				}
				panel.tree.selectedItems = selection;
				panel.tree.scrollToItem(selection[0]);
			}
			
			panel.tree.addEventListener(Event.CHANGE, onTreeChange);
			panel.tree.setItemOpened( cadetEditorContext.scene, true );
			
			
			// Build a list of categories by looping through all ComponentFactories and checking each 'category' proeprty
			var categoryTable:Object = {};
			var buttonBarDataProvider:Array = [];
			buttonBarDataProvider.push( { label:"All" } );
			for ( var i:int = 0; i < componentFactories.length; i++ )
			{
				var factory:ComponentFactory = ComponentFactory(componentFactories[i]);
				if ( factory.category == null ) continue;
				
				if ( categoryTable[factory.category] == null )
				{
					categoryTable[factory.category] = true;
					buttonBarDataProvider.push( { label:factory.category } );
				}
			}
			
			while ( panel.buttonBar.numChildren > 0 )
			{
				panel.buttonBar.removeChildAt(0);
			}
			for ( i = 0; i < buttonBarDataProvider.length; i++ )
			{
				var data:Object = buttonBarDataProvider[i];
				var btn:Button = new Button();
				btn.label = data.label;
				//btn.icon = data.icon;
				btn.userData = data;
				btn.percentWidth = btn.percentHeight = 100;
				panel.buttonBar.addChild(btn);
			}
			panel.buttonBar.selectedIndex = 0;
			
			panel.buttonBar.addEventListener(Event.CHANGE, onChangeButtonBar);
			panel.addBtn.addEventListener(MouseEvent.CLICK, onClickAdd);
			
			panel.list.addEventListener(MouseEvent.DOUBLE_CLICK, onClickAdd);
			populateList();
		}
		
		private function onChangeButtonBar( event:Event ):void
		{
			populateList();
		}
		
		private function onTreeChange( event:Event ):void
		{
			populateList();
		}
		
		private function populateList():void
		{
			// Grab a list of the selected components in the tree control
			var selectedComponents:Array = panel.tree.selectedItems;
			
			// Now convert these selected components into their associated containers.
			// What this means is, if a Component (not a container) is selected, this CommandHandler will assume you wish to
			// add new components as siblings. So it will act as though you had selected the Component's parent, not the 
			// component itself.
			containers = [];
			for each ( var component:IComponent in selectedComponents )
			{
				if ( component is IComponentContainer )
				{
					containers.push(component);
					continue;
				}
				// Don't add a duplicated (which could happen if more than one sibling has been selected).
				if ( containers.indexOf( component.parentComponent ) == -1 )
				{
					containers.push(component.parentComponent);
				}
			}
			
			// Nothing selected, clear the list and exit.
			if ( containers.length == 0 )
			{
				panel.list.dataProvider = new ArrayCollection();
				return;
			}
			
			// Populate the list with components based on the currently selected category.
			
			var selectedCategory:String = Button(panel.buttonBar.getChildAt(panel.buttonBar.selectedIndex)).userData.label;
			var dataProvider:ArrayCollection = new ArrayCollection();
				
			for each ( var factory:ComponentFactory in componentFactories )
			{
				if ( selectedCategory != "All" && factory.category != selectedCategory ) continue;
				
				// Ignore factories that have a compatibleContextType specified, and the current context doesn't match
				if ( factory.compatibleContextType && cadetEditorContext is factory.compatibleContextType == false )
				{
					continue;
				}
				
				if ( factory.visible == false )
				{
					continue;
				}
				
				// Create the data provider item.
				var item:Object = { label:factory.getLabel(), factory:factory, enabled:true, icon:factory.icon };
				
				// Items always appear in the list regardless of whether they are compatible with the selected ComponentContainers.
				// However, those that are incompatible appear disabled.
				for each ( var container:IComponentContainer in containers )
				{
					if ( factory.validate( container ) == false )
					{
						item.enabled = false;
						break;
					}
				}
				
				dataProvider.addItem(item);
			}
			
			
			
			panel.list.dataProvider = dataProvider;
		}
		
		private function onClickAdd( event:MouseEvent ):void
		{
			var selectedItems:Array = panel.tree.selectedItems;
			
			// gotoPreviousOperation() undoes the CommandHandler's operation, removing any added items from the scene.
			// addSelectedComponents() adds AddItemOperations to the CommandHandler's main UndoableOperation
			// gotoNextOperation() executes the CommandHandler's operation again, re-adding all of the items.
			cadetEditorContext.operationManager.gotoPreviousOperation();
			addSelectedComponents();
			cadetEditorContext.operationManager.gotoNextOperation();
			
			panel.tree.selectedItems = selectedItems;
			
			populateList();
		}
		
		private function clickOkHandler( event:MouseEvent ):void
		{
			disposePanel();
		}
		
		private function clickCancelHandler( event:MouseEvent ):void
		{
			cadetEditorContext.operationManager.gotoPreviousOperation();
			disposePanel();
		}
		
		private function disposePanel():void
		{
			panel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			panel.addBtn.removeEventListener(MouseEvent.CLICK, onClickAdd);
			CoreEditor.viewManager.removePopUp(panel);
			panel = null;
		}
		
		private function addSelectedComponents():void
		{
			var selectedItems:Array = panel.list.selectedItems;
			for each ( var item:Object in selectedItems )
			{
				var factory:ComponentFactory = item.factory;
				if ( !factory ) continue;
				for each ( var container:IComponentContainer in containers )
				{
					var newComponent:IComponent = IComponent(factory.getInstance());
					var addItemOperation:AddItemOperation = new AddItemOperation( newComponent, container.children );
					operation.addOperation( addItemOperation );
				}
			}
		}
	}
}