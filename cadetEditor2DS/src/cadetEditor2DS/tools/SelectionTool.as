// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.tools
{
	import flash.events.Event;
	
	import cadet.core.IComponent;
	
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.IRenderable;
	import cadet2D.util.SkinsUtil;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.tools.ITool;
	import cadetEditor.util.DragDetector;
	
	import cadetEditor2D.controllers.DragItemsController;
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.util.SelectionUtil;
	
	import cadetEditor2DS.controllers.DragSelectController;
	
	import core.app.core.contexts.IContext;
	import core.app.operations.ChangePropertyOperation;
	import core.app.util.ArrayUtil;
	import core.app.util.IntrospectionUtil;
	import core.editor.CoreEditor;
	
	public class SelectionTool extends CadetEditorTool2D implements ITool
	{
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, SelectionTool, "Selection Tool", CadetEditorIcons.SelectionTool );
		}
		
		// State
		protected var ignoreNextMouseUp				:Boolean = false;
		protected var ignoreDragDetect				:Boolean = false;
		protected var allowMultipleSelection		:Boolean = true;
		protected var allowDrag						:Boolean = true;
		protected var allowDragSelect				:Boolean = true;
		
		private var shiftKeyDown					:Boolean = false;
		private var pressedSkin						:IRenderable;
		
		// Controllers
		private var dragItemsController				:DragItemsController;
		private var dragSelectController			:DragSelectController;
		
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
			
			dragItemsController = new DragItemsController( this.context, this );
			dragSelectController = new DragSelectController( this.context );
		}
			
		override public function dispose():void
		{
			dragItemsController.dispose()
			dragItemsController = null
			dragSelectController.dispose()
			dragSelectController = null
			pressedSkin = null
			
			super.dispose()
		}
		
		
		/**
		 * Begin drag select behaviour when clicking on nothing. 
		 * @param event
		 */		
		override protected function onMouseDownBackground(event:PickingManagerEvent):void
		{
			if ( allowDragSelect == false ) return;
			var dragDetector:DragDetector = new DragDetector(CoreEditor.stage)
			dragDetector.addEventListener(DragDetector.BEGIN_DRAG, dragSelectDetectedHandler)
			shiftKeyDown = event.shiftKey
		}
		
		protected function dragSelectDetectedHandler(event:Event):void
		{
			if ( ignoreDragDetect )
			{
				ignoreDragDetect = false
				return;
			}
			dragSelectController.beginDrag();
		}
		
		/**
		 * Clicking on a clear area of the background is symbolic for clearing the selection. 
		 * @param event
		 */		
		override protected function onClickBackground(event:PickingManagerEvent):void
		{
			if (ignoreNextMouseUp) 
			{
				ignoreNextMouseUp = false;
				return;
			}
			if (dragSelectController.dragging) return;
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
		override protected function onMouseDownSkins( event:PickingManagerEvent ):void
		{
			if ( !allowDrag ) return;
			shiftKeyDown = event.shiftKey;
			
			// Depth sort skins
			event.skinsUnderMouse.sort(SkinsUtil.sortSkinsById);
			event.skinsUnderMouse.reverse();
			
			var skin:IRenderable = event.skinsUnderMouse[0];
			var dragDetector:DragDetector = new DragDetector( view.container );
			pressedSkin = skin;
			dragDetector.addEventListener( DragDetector.BEGIN_DRAG, dragDetectedHandler );
		}
		
		
		override protected function onMouseMoveContainer(event:PickingManagerEvent) : void
		{
			previouslyClickedComponent = null;
		}
		
		/**
		 * The user started dragging the item pressed on above. We use the dragItemsController to
		 * take care of the dragging items behaviour. 
		 * @param event
		 */		
		protected function dragDetectedHandler(event:Event):void
		{
			// Automatically select the dragged item
			var pressedComponent:IComponent = pressedSkin.parentComponent;
			// If the skin doesn't have a transform2D sibling, don't think of it in terms of a nested skin & transform
			// inside a parent component. Instead, move the skin on it's own using its x and y properties.
			if (!pressedSkin.transform2D) {
				pressedComponent = pressedSkin;
			}
			
			if ( !pressedComponent ) return;
			if ( context.selection.contains( pressedComponent ) == false ) 
			{
				handleSelection( pressedComponent, shiftKeyDown, false );
			}
			// When the drag ends, the user will likely release the mouse over the same item, resulting in a
			// 'click' event. Clicking an item is usually interpreted as selecting it, which is not what we want
			// after a drag select. This flag causes the click event to be ignored.
			ignoreNextMouseUp = true
			
			var skins:Array = SelectionUtil.getSkinsFromComponents( context.selection.source );
			
			skins = skins.filter( 
			function( item:*, index:int, array:Array ):Boolean 
			{ 
				var value:String = IntrospectionUtil.getMetadataByNameAndKey(item, "CadetEditor", "transformable");
				if ( value == "false" ) return false;
				return true;
			} );
			
			if ( skins.length > 0 )
			{
				dragItemsController.beginDrag( skins );
			}			
		}
		
		
		/**
		 * Clicking an actor results in selecting the actor.
		 * @param item
		 * @param event
		 */
		private var previouslyClickedComponent:IComponent;//Container;
		override protected function onClickSkins( event:PickingManagerEvent ):void
		{	
			if (ignoreNextMouseUp) 
			{
				ignoreNextMouseUp = false;
				return;
			}
			
			// Depth sort skins
			event.skinsUnderMouse.sort(SkinsUtil.sortSkinsById);
			event.skinsUnderMouse.reverse();
			
		//	var components:Vector.<IComponentContainer> = ComponentUtil.getComponentContainers( event.skinsUnderMouse );
			var components:Vector.<IComponent> = getSelectedComponents( event.skinsUnderMouse );
			
			if ( previouslyClickedComponent == null || components.indexOf(previouslyClickedComponent) == -1 || components.length == 1)
			{
				handleSelection(components[0], event.shiftKey)
				previouslyClickedComponent = components[0];
				return
			}
			
			var index:int = components.indexOf(previouslyClickedComponent);
			index = index == components.length-1 ? 0 : index+1;
			
			var component:IComponent = components[index];
			handleSelection(component, event.shiftKey)
			
			var alreadySelected:Boolean = context.selection.contains( previouslyClickedComponent );
			if ( alreadySelected )
			{
				handleSelection( previouslyClickedComponent, true );
			}
			
			previouslyClickedComponent = component;
		}
		
		static public function getSelectedComponents( components:Array ):Vector.<IComponent>
		{
			var selected:Vector.<IComponent> = new Vector.<IComponent>();
			for ( var i:int = 0; i < components.length; i++ )
			{
				var component:IComponent = IComponent( components[i] );
				
				if ( component is AbstractSkin2D ) {
					var skin:AbstractSkin2D = AbstractSkin2D(component);
					if ( skin.transform2D ) {
						selected.push( component.parentComponent );
					} else {
						selected.push(component);
					}
				}
			}
			return selected;
		}
		
		/**
		 * This function takes care of the toggling the selection on an item, and updating the current selection. 
		 * @param item
		 * @param shiftSelect
		 * @param allowDeselect
		 */		
		protected function handleSelection( component:IComponent, shiftSelect:Boolean = false, allowDeselect:Boolean = true ):void
		{
			var alreadySelected:Boolean = SelectionUtil.doesArrayContainComponentAnscestor( context.selection.source, component );
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