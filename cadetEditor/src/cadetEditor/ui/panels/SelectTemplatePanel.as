// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.panels
{
	import flash.events.Event;
	
	import core.ui.components.Button;
	import core.editor.ui.components.FileSystemTree;
	import core.ui.components.List;
	import core.ui.components.Panel;
	import core.ui.data.DefaultDataDescriptor;
	import core.ui.util.CoreDeserializer;
	
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
				
				</Panel>;
			
			CoreDeserializer.deserialize( xml, this, ["bones.ui.components"] );
			
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