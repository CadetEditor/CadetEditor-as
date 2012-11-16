// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.panels
{
	import cadetEditor.ui.components.OutlineTree;
	
	import flash.events.Event;
	
	import flox.ui.components.Button;
	import flox.editor.ui.components.FileSystemTree;
	import flox.ui.components.List;
	import flox.ui.components.Panel;
	import flox.ui.data.DefaultDataDescriptor;
	import flox.ui.layouts.HorizontalLayout;
	import flox.ui.layouts.LayoutAlign;
	import flox.ui.util.FloxDeserializer;
	
	public class SelectTemplatePanel extends Panel
	{
		public var list				:List;
		public var fileSystemTree	:FileSystemTree;
		public var okBtn			:Button;
		public var cancelBtn		:Button;
		
		public function SelectTemplatePanel()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				
				<Panel width="524" height="400" label="Select Template" >
					
					<FileSystemTree id="fileSystemTree" width="100%" height="100%" />
					<List id="list" width="100%" height="100%"/>
					
					<layout>
						<HorizontalLayout/>
					</layout>
				
					<controlBar>
						<Button label="OK" id="okBtn"/>
						<Button label="Cancel" id="cancelBtn"/>
					</controlBar>
				
				</Panel>
			
			FloxDeserializer.deserialize( xml, this, ["bones.ui.components"] );
			
			list.addEventListener(Event.CHANGE, changeListHandler);
			DefaultDataDescriptor(list.dataDescriptor).labelField = "exportTemplateID";
		}
		
		private function changeListHandler( event:Event ):void
		{
			validateInput();
		}
		
		private function validateInput():void
		{
			okBtn.enabled = list.selectedItem != null;
		}
	}
}