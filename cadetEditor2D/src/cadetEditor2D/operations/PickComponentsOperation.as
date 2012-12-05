// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.operations
{
	import cadet.core.IComponentContainer;
	
	import cadet2D.components.skins.ISkin2D;
	
	import cadetEditor.assets.CadetEditorCursors;
	import cadetEditor.ui.panels.PickComponentPanel;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.events.PickingManagerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import flox.core.data.ArrayCollection;
	import flox.ui.events.ListEvent;
	import flox.ui.managers.CursorManager;
	
	import flox.editor.FloxEditor;
	import flox.app.core.operations.IAsynchronousOperation;
	import flox.app.util.VectorUtil;

	public class PickComponentsOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var context			:ICadetEditorContext2D;
		private var numComponents	:int;
		public var filter			:Function;
		private var panel			:PickComponentPanel;
		
		private var executing	:Boolean = false;
		
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
			FloxEditor.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
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
			FloxEditor.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
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
				var skin:ISkin2D = skins[i];
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
			panel = new PickComponentPanel();
			FloxEditor.viewManager.addPopUp( panel );
			
			panel.x = FloxEditor.stage.mouseX + 30;
			panel.y = FloxEditor.stage.mouseY - 60;
			
			var padding:uint = 10;
			if ( panel.x + panel.width >= FloxEditor.stage.stageWidth ) 
			{
				panel.x = FloxEditor.stage.stageWidth - panel.width - padding;
			}
			if ( panel.y + panel.height >= FloxEditor.stage.stageHeight ) 
			{
				panel.y = FloxEditor.stage.stageHeight - panel.height - padding;
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
			
			panel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			panel.list.removeEventListener( ListEvent.ITEM_ROLL_OVER, rollOverItemHandler );
			
			FloxEditor.viewManager.removePopUp(panel);
			
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
		
		
		public function get label():String
		{
			return "Pick Object(s)";
		}
	}
}