// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.operations
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import cadet.core.IComponentContainer;
	
	import cadet2D.components.skins.IRenderable;
	
	import cadetEditor.assets.CadetEditorCursors;
	import cadetEditor.ui.panels.PickComponentPanel;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.events.PickingManagerEvent;
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.data.ArrayCollection;
	import core.editor.CoreEditor;
	import core.ui.events.ListEvent;
	import core.ui.managers.CursorManager;

	public class PickComponentsOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var context			:ICadetEditorContext2D;
		private var numComponents	:int;
		public var filter			:Function;
		private var panel			:PickComponentPanel;
		
		private var executing	:Boolean = false;
		private var _panelOpen 	:Boolean = false;
		
		private var result		:Array;
		private var clickLoc	:Point;		// Stores the location of the click in world container co-ordinates.
				
		public function PickComponentsOperation( context:ICadetEditorContext2D, numComponents:int = 1 )//, filter:Function = null)
		{
			this.context = context;
			this.numComponents = numComponents;
			//this.filter = filter;
		}
		
		public function execute():void
		{
			if ( executing ) return;
			executing = true;
			
			context.pickingManager.addEventListener(PickingManagerEvent.CLICK_SKINS, clickSkinsHandler);
			context.pickingManager.addEventListener(PickingManagerEvent.ROLL_OVER_SKIN, rollOverSkinHandler);
			context.pickingManager.addEventListener(PickingManagerEvent.ROLL_OUT_SKIN, rollOutSkinHandler);
			CoreEditor.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		public function cancel():void
		{
			if ( !executing ) return;
			executing = false;
			
			filter = null;
			
			disableCursor();
			
			context.pickingManager.removeEventListener(PickingManagerEvent.CLICK_SKINS, clickSkinsHandler);
			context.pickingManager.removeEventListener(PickingManagerEvent.ROLL_OVER_SKIN, rollOverSkinHandler);
			context.pickingManager.removeEventListener(PickingManagerEvent.ROLL_OUT_SKIN, rollOutSkinHandler);
			CoreEditor.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function dispose():void
		{
			closePanel();
			cancel();
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.ESCAPE )
			{
				result = null;
				clickLoc = null;
				//cancel();
				dispose();
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		private function clickSkinsHandler( event:PickingManagerEvent ):void
		{
			var validComponents:Array = getValidComponents(event.skinsUnderMouse);
			if ( validComponents.length == 0 ) return;
			
			clickLoc = context.snapManager.snapPoint(context.view2D.worldMouse).snapPoint; 
			
			if ( validComponents.length < numComponents ) return;
			
			if ( validComponents.length == numComponents )
			{
				result = validComponents;
				dispose();
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			
			openPanel(validComponents);
		}
		
		private function rollOverSkinHandler( event:PickingManagerEvent ):void
		{
			var validComponents:Array = getValidComponents(event.skinsUnderMouse);
			
			if ( validComponents.length < numComponents )
			{
				disableCursor();
			}
			else
			{
				enableCursor();
			}
		}
		
		private function rollOutSkinHandler( event:PickingManagerEvent ):void
		{
			var validComponents:Array = getValidComponents(event.skinsUnderMouse);
			
			if ( validComponents.length < numComponents )
			{
				disableCursor();
			}
			else
			{
				enableCursor();
			}
		}
		
		private function enableCursor():void
		{
			CursorManager.setCursor( CadetEditorCursors.Precision );
		}
		
		private function disableCursor():void
		{
			CursorManager.setCursor(null);
		}
		
		private function getValidComponents(skins:Array):Array
		{
			var validComponents:Array = [];
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var skin:IRenderable = skins[i];
				validComponents.push( skin.parentComponent );
			}
			
			if ( filter != null )
			{
				validComponents = validComponents.filter(filter);
			}
			return validComponents;
		}
		
		private function openPanel(components:Array):void
		{
			if ( panel ) return;
			
			_panelOpen = true;
			
			panel = new PickComponentPanel();
			CoreEditor.viewManager.addPopUp( panel );
			
			panel.x = CoreEditor.stage.mouseX + 30;
			panel.y = CoreEditor.stage.mouseY - 60;
			
			var padding:uint = 10;
			if ( panel.x + panel.width >= CoreEditor.stage.stageWidth ) 
			{
				panel.x = CoreEditor.stage.stageWidth - panel.width - padding;
			}
			if ( panel.y + panel.height >= CoreEditor.stage.stageHeight ) 
			{
				panel.y = CoreEditor.stage.stageHeight - panel.height - padding;
			}	
			
			panel.okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
			
			panel.numComponents = numComponents;
			panel.list.allowMultipleSelection = numComponents > 1;
			panel.list.dataProvider = new ArrayCollection(components);
			panel.list.addEventListener( ListEvent.ITEM_ROLL_OVER, rollOverItemHandler );
			
			disableCursor();
		}
		
		private function rollOverItemHandler( event:ListEvent ):void
		{
			context.highlightManager.unhighlightAllComponents();
			context.highlightManager.highlightComponent( IComponentContainer(event.item) );
		}
		
		private function closePanel():void
		{
			if ( !panel ) return;
			
			_panelOpen = false;
			
			panel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			panel.list.removeEventListener( ListEvent.ITEM_ROLL_OVER, rollOverItemHandler );
			
			CoreEditor.viewManager.removePopUp(panel);
			
			context.highlightManager.unhighlightAllComponents();
			
			panel = null;
		}
		
		private function clickOkHandler( event:MouseEvent ):void
		{
			result = panel.list.selectedItems;
			dispose();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function clickCancelHandler( event:MouseEvent ):void
		{
			result = null;
			clickLoc = null;
			closePanel();
		}
		
		public function getResult():Array
		{
			return result;
		}
		public function getClickLoc():Point { return clickLoc.clone(); }
		
		public function get panelOpen():Boolean
		{
			return _panelOpen;
		}
		
		public function get label():String
		{
			return "Pick Object(s)";
		}
	}
}