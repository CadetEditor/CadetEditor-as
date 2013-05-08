// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.panels
{
	import cadetEditor.ui.components.OutlineTree;
	
	import core.ui.components.Button;
	import core.ui.components.List;
	import core.ui.components.Panel;
	import core.ui.components.RadioButtonGroup;
	import core.ui.util.CoreDeserializer;
	
	public class AddComponentPanel extends Panel
	{
		public var tree				:OutlineTree;
		public var list				:List;
		public var okBtn			:Button;
		public var cancelBtn		:Button;
		public var buttonBar		:RadioButtonGroup;
		public var addBtn			:Button;
		
		public function AddComponentPanel()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				<Panel width="800" height="600" label="Add Components" >
					
					<HBox width="100%" height="100%">
						<OutlineTree id="tree" width="300" height="100%" allowDragAndDrop="false"/>
						<VBox width="100%" height="100%">
							<RadioButtonGroup id="buttonBar" width="100%" height="24">
								<layout>
									<HorizontalLayout spacing="-1"/>
								</layout>
							</RadioButtonGroup>
							<List id="list" width="100%" height="100%" allowMultipleSelection="false"/>
							<Button id="addBtn" label="&lt;&lt;" width="100%" /> 
						</VBox>
					</HBox>
					
					<controlBar>
						<Label text="Hint: Double click a Component in the list to add it to the scene." width="100%"/>
						<Button label="OK" id="okBtn"/>
						<Button label="Cancel" id="cancelBtn"/>
					</controlBar>
						
				</Panel>;
			
			CoreDeserializer.deserialize( xml, this, ["cadetEditor.ui.components"] );
			defaultButton = okBtn;
		}
	}
}