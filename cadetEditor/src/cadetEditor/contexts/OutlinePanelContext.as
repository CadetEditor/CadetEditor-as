// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import cadet.core.ICadetScene;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import cadetEditor.ui.components.OutlineTree;
	import core.data.ArrayCollection;
	import core.events.ArrayCollectionEvent;
	import core.ui.events.DragAndDropEvent;
	
	import core.editor.CoreEditor;
	import core.appEx.core.contexts.IInspectableContext;
	import core.appEx.core.contexts.IOperationManagerContext;
	import core.appEx.core.contexts.IVisualContext;
	import core.appEx.events.ContextValidatorEvent;
	import core.appEx.managers.OperationManager;
	import core.app.operations.AddItemOperation;
	import core.app.operations.RemoveItemOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.validators.ContextValidator;

	public class OutlinePanelContext implements IVisualContext, IInspectableContext, IOperationManagerContext
	{
		private var context					:ICadetContext;
		private var contextValidator		:ContextValidator;
		
		private var _view					:OutlineTree;
		
		private var dataProvider			:ICadetScene;
		
		public function OutlinePanelContext()
		{
			_view = new OutlineTree();
			_view.padding = 0;
			_view.showBorder = false;
			
			contextValidator = new ContextValidator( CoreEditor.contextManager, ICadetContext, false );
			contextValidator.addEventListener( ContextValidatorEvent.CONTEXT_CHANGED, changeHandler );
			
			_view.addEventListener( Event.CHANGE, changeTreeHandler );
			_view.addEventListener(DragAndDropEvent.DRAG_OVER, dragOverHandler);
			_view.addEventListener(DragAndDropEvent.DRAG_DROP, dragDropHandler);
			
			refresh();
		}
		
		public function get view():DisplayObject { return _view; }
		
		public function dispose():void
		{
			_view.dataProvider = null;
			_view.removeEventListener( Event.CHANGE, changeTreeHandler );
			_view.removeEventListener(DragAndDropEvent.DRAG_OVER, dragOverHandler);
			_view.removeEventListener(DragAndDropEvent.DRAG_DROP, dragDropHandler);
			
			contextValidator.removeEventListener( ContextValidatorEvent.CONTEXT_CHANGED, changeHandler );
			contextValidator.dispose();
			contextValidator = null;
			
			if ( context )
			{
				context.selection.removeEventListener( ArrayCollectionEvent.CHANGE, selectionChangedHandler );
				context.removeEventListener( Event.CHANGE, dataChangeHandler );
				context = null;
			}
		}
		
		private function dataChangeHandler( event:Event ):void
		{
			refresh();
		}
		
		private function changeHandler( event:Event ):void
		{
			refresh();
		}
		
		private function refresh():void
		{
			if ( context )
			{
				//TODO: Rob added this due to Starling disableRenderer() issue.
				if (context.selection) {
					context.selection.removeEventListener( ArrayCollectionEvent.CHANGE, selectionChangedHandler );
				}
				context.removeEventListener( Event.CHANGE, dataChangeHandler );
				context = null;
			}
			
			if ( contextValidator.state )
			{
				context = ICadetContext( contextValidator.getContext() );
				context.addEventListener( Event.CHANGE, dataChangeHandler );
				context.selection.addEventListener( ArrayCollectionEvent.CHANGE, selectionChangedHandler );
				
				if ( context.scene == null )
				{
					dataProvider = null;
					_view.dataProvider = dataProvider;
					return;
				}
				
				if ( dataProvider != context.scene )
				{
					dataProvider = context.scene;
					_view.dataProvider = dataProvider;
				}
			}
			else
			{
				dataProvider = null;
				_view.dataProvider = dataProvider;
			}
			
			updateSelection();
		}
		
		private function changeTreeHandler( event:Event ):void
		{
			var selection:Array = [];
			suppressSelectionChangeHandler = true;
			context.selection.source = _view.selectedItems;
			suppressSelectionChangeHandler = false;
		}
		
		private var suppressSelectionChangeHandler:Boolean = false;
		private function selectionChangedHandler( event:ArrayCollectionEvent ):void
		{
			if ( suppressSelectionChangeHandler ) return;
			updateSelection();
		}
		
		private function updateSelection():void
		{
			if ( !context ) return;
			
			if ( context.selection.length == 0 )
			{
				_view.selectedItem = null;
				return;
			}
			
			_view.selectedItems = context.selection.source;
			_view.openToItem(context.selection[0]);
			_view.scrollToItem(context.selection[0]);
		}
		
		public function get selection():ArrayCollection
		{
			if ( !context ) return new ArrayCollection();
			return context.selection;
		}
		
		public function get operationManager():OperationManager
		{
			if ( !context ) return null;
			if ( context is IOperationManagerContext == false ) return null;
			return IOperationManagerContext(context).operationManager;
		}
				
		
		private function dragOverHandler( event:DragAndDropEvent ):void
		{
			
		}
		
		private function dragDropHandler( event:DragAndDropEvent ):void
		{
			if ( context is IOperationManagerContext == false )
			{
				return;
			}
			
			event.preventDefault();
			
			var component:IComponent = IComponent(event.item);
			var container:IComponentContainer = _view.getParent(event.targetCollection) as IComponentContainer;
			if ( container == null )
			{
				container = context.scene;
			}
			if ( component == container ) return;
			
			var dropIndex:int = event.index;
			var sourceCollection:ArrayCollection = component.parentComponent.children;
			var sourceIndex:int = sourceCollection.getItemIndex(component);
			
			if ( sourceCollection == container.children && sourceIndex < dropIndex )
			{
				dropIndex--;
			}
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			if ( component.parentComponent )
			{
				operation.addOperation( new RemoveItemOperation( component, component.parentComponent.children ) );
			}
			operation.addOperation( new AddItemOperation( component, container.children, dropIndex ) );
			IOperationManagerContext(context).operationManager.addOperation(operation);
		}
	}
}