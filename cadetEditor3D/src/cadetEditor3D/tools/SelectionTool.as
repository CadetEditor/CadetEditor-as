// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Entity;
	
	import cadet.core.IComponentContainer;
	
	import cadet3D.components.core.Object3DComponent;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.util.DragDetector;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.events.DetailedMouse3DEvent;
	
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	import flox.app.core.contexts.IContext;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.util.ArrayUtil;
	
	public class SelectionTool extends AbstractTool
	{
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, SelectionTool, "Selection Tool [Q]", CadetEditorIcons.SelectionTool, [Keyboard.Q] );
		}
		
		// State
		protected var ignoreNextMouseUp				:Boolean = false;
		protected var allowMultipleSelection		:Boolean = true;
		
		private var shiftKeyDown					:Boolean = false;
		private var pressedEntity					:Entity;
		
		/**
		 * Constructor 
		 * 
		 */		
		public function SelectionTool()
		{
			
		}
		
		override public function init( context:IContext ):void
		{
			super.init( context );
		}
		
		override public function dispose():void
		{
			pressedEntity = null
			
			super.dispose()
		}
		
		override protected function performEnable():void
		{
			context.detailedMouse3DManager.addEventListener(DetailedMouse3DEvent.MOUSE_DOWN, mouseDownHandler);
			context.detailedMouse3DManager.addEventListener(DetailedMouse3DEvent.CLICK, clickHandler);
		}
		
		override protected function performDisable():void
		{
			context.detailedMouse3DManager.removeEventListener(DetailedMouse3DEvent.MOUSE_DOWN, mouseDownHandler);
			context.detailedMouse3DManager.removeEventListener(DetailedMouse3DEvent.CLICK, clickHandler);
		}
		
		
		private function mouseDownHandler(event:DetailedMouse3DEvent):void
		{
			if ( event.entities.length > 0 )
			{
				mouseDownEntitiesHandler( event );
			}
		}
		
		private function clickHandler( event:DetailedMouse3DEvent ):void
		{
			if ( event.entities.length == 0 )
			{
				clickBackgroundHandler( event );
			}
			else
			{
				clickEntitiesHandler(event);
			}
		}
		
		/**
		 * Clicking on a clear area of the background is symbolic for clearing the selection. 
		 * @param event
		 */		
		private function clickBackgroundHandler(event:DetailedMouse3DEvent):void
		{
			if (ignoreNextMouseUp) 
			{
				ignoreNextMouseUp = false;
				return;
			}
			if ( ArrayUtil.compare( [], context.selection.source ) == true ) return;
			var changeSelectionOperation:ChangePropertyOperation = new ChangePropertyOperation( context.selection, "source", [] );
			changeSelectionOperation.label = "Change Selection";
			context.operationManager.addOperation( changeSelectionOperation );
		}
		
		/**
		 * When first pressing the mouse on an item, the user may be about to click it, or they may
		 * be about to click and drag. This function creates a drag detector helper to determine
		 * which situation occurs.
		 * @param item
		 * @param event
		 */		
		private function mouseDownEntitiesHandler( event:DetailedMouse3DEvent ):void
		{
			shiftKeyDown = event.shiftKey;
			
			var entity:Entity = event.entities[0];
			var dragDetector:DragDetector = new DragDetector( view.renderer.view3D );
			pressedEntity = entity;
			dragDetector.addEventListener( DragDetector.BEGIN_DRAG, dragDetectedHandler );
		}
		
		/*
		override protected function onMouseMoveContainer(event:PickingManagerEvent) : void
		{
			previouslyClickedComponent = null;
		}
		*/
		
		/**
		 * The user started dragging the item pressed on above. We use the dragItemsController to
		 * take care of the dragging items behaviour. 
		 * @param event
		 */		
		protected function dragDetectedHandler(event:Event):void
		{
			// Automatically select the dragged item
			var pressedComponent:Object3DComponent = renderer.getComponentForObject3D(pressedEntity);
			
			if ( !pressedComponent ) return;
			if ( context.selection.contains( pressedComponent ) == false ) 
			{
				handleSelection( pressedComponent, shiftKeyDown, false );
			}
			// When the drag ends, the user will likely release the mouse over the same item, resulting in a
			// 'click' event. Clicking an item is usually interpreted as selecting it, which is not what we want
			// after a drag select. This flag causes the click event to be ignored.
			ignoreNextMouseUp = true
			
			/*
			if ( skins.length > 0 )
			{
				dragItemsController.beginDrag( skins );
			}	
			*/
		}
		
		
		/**
		 * Clicking an actor results in selecting the actor.
		 * @param item
		 * @param event
		 */
		private var previouslyClickedComponent:Object3DComponent;
		private function clickEntitiesHandler( event:DetailedMouse3DEvent ):void
		{	
			if (ignoreNextMouseUp) 
			{
				ignoreNextMouseUp = false;
				return;
			}
			
			var components:Vector.<Object3DComponent> = new Vector.<Object3DComponent>();
			for ( var i:int = 0; i < event.entities.length; i++ )
			{
				components.push( renderer.getComponentForObject3D(event.entities[i]) );
			}
			
			if ( previouslyClickedComponent == null || components.indexOf(previouslyClickedComponent) == -1 || components.length == 1)
			{
				handleSelection(components[0], event.shiftKey)
				previouslyClickedComponent = components[0];
				return
			}
			
			var index:int = components.indexOf(previouslyClickedComponent);
			index = index == components.length-1 ? 0 : index+1;
			
			var component:Object3DComponent = components[index];
			handleSelection(component, event.shiftKey)
			
			var alreadySelected:Boolean = context.selection.contains( previouslyClickedComponent );
			if ( alreadySelected && components.indexOf(previouslyClickedComponent) == -1 )
			{
				handleSelection( previouslyClickedComponent, true );
			}
			previouslyClickedComponent = component;
		}
		
		/**
		 * This function takes care of the toggling the selection on an item, and updating the current selection. 
		 * @param item
		 * @param shiftSelect
		 * @param allowDeselect
		 */		
		protected function handleSelection( component:Object3DComponent, shiftSelect:Boolean = false, allowDeselect:Boolean = true ):void
		{
			var alreadySelected:Boolean = context.selection.source.indexOf( component ) != -1;
			
			var newSelection:Array = context.selection.source;
			
			// No shift selection, so only select the item clicked on
			if ( shiftSelect == false )
			{
				// If not already selected, then select it
				if ( !alreadySelected )
				{
					newSelection = [component];
				}
			}
				
				// Otherwise we're modifying an existing selection
			else
			{
				// If already selected, remove it from the current selection
				if ( alreadySelected )
				{
					newSelection.splice( newSelection.indexOf( component ), 1 );
				}
					// Otherwise add it to the current selection
				else
				{
					// Only if multiple selection is allowed however
					if ( allowMultipleSelection )
					{
						newSelection.push( component );
					}
				}
			}
			
			
			if ( ArrayUtil.compare( newSelection, context.selection.source ) == true ) return;
			
			var changeSelectionOperation:ChangePropertyOperation = new ChangePropertyOperation( context.selection, "source", newSelection );
			changeSelectionOperation.label = "Change Selection";
			context.operationManager.addOperation( changeSelectionOperation );
		}
	}
}