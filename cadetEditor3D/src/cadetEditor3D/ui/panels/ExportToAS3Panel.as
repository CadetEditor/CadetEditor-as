// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.ui.panels
{
	import flox.ui.components.Button;
	import flox.ui.components.CheckBox;
	import flox.ui.components.Panel;
	import flox.ui.components.RadioButton;
	import flox.ui.components.RadioButtonGroup;
	import flox.ui.components.TextArea;
	import flox.ui.components.TextInput;
	import flox.ui.util.FloxDeserializer;

	public class ExportToAS3Panel extends Panel
	{
		public var okBtn					:Button;
		public var cancelBtn				:Button;
		public var asBtn					:RadioButton;
		public var jsBtn					:RadioButton;
		public var textArea					:TextArea;
		public var buttonGroup				:RadioButtonGroup;
		public var hoverCamCheckBox			:CheckBox;
		
		public function ExportToAS3Panel()
		{
		}
		
		override protected function init():void
		{
			super.init();
					
			var xml:XML = 
				<Panel
					width="460" 
					height="250" 
					label="Select engine"
					>
				
					<VBox width="100%" height="100%" paddingTop="10" paddingLeft="10" paddingRight="10" id="group">
						<RadioButtonGroup width="100%" height="50" paddingLeft="10" id="buttonGroup">
							<RadioButton label="Away3D (ActionScript)" id="asBtn" />
							<RadioButton y="25" label="three.js (JavaScript)" id="jsBtn" />
						</RadioButtonGroup>
						<VBox width="100%" height="100%" paddingTop="10" paddingLeft="8" paddingBottom="10">
							<CheckBox label="Include Hover Camera" id="hoverCamCheckBox" />
						</VBox>
						<TextArea width="100%" height="100%" id="textArea"></TextArea>
					</VBox>
				
					<controlBar>
						<Button label="OK" id="okBtn"/>
						<Button label="Cancel" id="cancelBtn"/>
					</controlBar>
				
				</Panel>
				
			FloxDeserializer.deserialize( xml, this );
			defaultButton = okBtn;
		}				
	}
}