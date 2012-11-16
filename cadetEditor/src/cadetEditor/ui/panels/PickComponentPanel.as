// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.panels
{
	import flash.events.Event;
	
	import flox.ui.components.Button;
	import flox.ui.components.List;
	import cadetEditor.ui.components.OutlineTree;
	import flox.ui.components.Panel;
	import cadetEditor.ui.data.OutlineTreeDataDescriptor;
	import flox.ui.layouts.HorizontalLayout;
	import flox.ui.layouts.LayoutAlign;
	
	public class PickComponentPanel extends Panel
	{
		public var list				:List;
		public var okBtn			:Button;
		public var cancelBtn		:Button;
		private var _numComponents	:int = 1;
		
		public function PickComponentPanel()
		{
			
		}
		
		public function get numComponents():int
		{
			return _numComponents;
		}

		public function set numComponents(value:int):void
		{
			label = "Select "+value+" component";
			if ( value > 1 ) {
				label = "Shift-"+ label + "s";
			}
			
			_numComponents = value;
			invalidate();
		}

		override protected function init():void
		{
			super.init();
			
			list = new List();
			list.percentWidth = list.percentHeight = 100;
			list.dataDescriptor = new OutlineTreeDataDescriptor();
				
			addChild(list);
			okBtn = new Button();
			okBtn.label = "OK";
			controlBar.addChild(okBtn);
			
			cancelBtn = new Button();
			cancelBtn.label = "Cancel";
			controlBar.addChild(cancelBtn);
			
			HorizontalLayout(controlBar.layout).horizontalAlign = LayoutAlign.RIGHT;
			
			list.addEventListener(Event.CHANGE, changeListHandler);
			validateInput();
			
			defaultButton = okBtn;
		}
		
		override protected function validate():void
		{
			super.validate();
			label = "Pick " + _numComponents + " components."
		}
		
		private function changeListHandler( event:Event ):void
		{
			validateInput();
		}
		
		private function validateInput():void
		{
			okBtn.enabled = list.selectedItems.length == _numComponents;
		}
	}
}