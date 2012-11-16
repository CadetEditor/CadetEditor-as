// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.panels
{
	import flash.events.Event;
	
	import flox.ui.components.Button;
	import flox.ui.components.CheckBox;
	import flox.ui.components.Label;
	import flox.ui.components.List;
	import cadetEditor.ui.components.OutlineTree;
	import flox.ui.components.Panel;
	import flox.ui.components.RadioButtonGroup;
	import flox.ui.components.TextArea;
	import flox.ui.components.TextInput;
	import flox.ui.util.FloxDeserializer;
	
	import flox.editor.FloxEditor;
	import flox.app.util.StringUtil;
	import flox.app.util.Validation;
	
	public class ComponentPropertiesPanel extends Panel
	{
		public var exportTemplateIDField	:TextInput;
		public var templateIDField			:TextArea;
		public var browseBtn				:Button;
		public var feedbackLabel			:Label;
		public var exportToggle				:CheckBox;
		public var importToggle				:CheckBox;
		public var okBtn					:Button;
		public var cancelBtn				:Button;
		
		public function ComponentPropertiesPanel()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				
				<Panel width="490" height="180" label="Properties" showCloseButton="false" >
				
					<Container width="100%" height="100%">
					
						<Label text="Export Template ID:" textAlign="right" width="100" x="30" y="3"/>
						<TextInput id="exportTemplateIDField" x="140" width="230"/>
						
						<Label text="Import Template ID:" y="32" textAlign="right" width="100" x="30"/>
						<TextArea id="templateIDField" x="140" y="30" width="230"/>
						<Button y="30" label="Browse" id="browseBtn" x="380" width="80" />
						
						<Label id="feedbackLabel" fontColor="0xFF0000" y="100"/>
						
						<CheckBox x="138" y="60" label="Export as template" id="exportToggle"/>
						<CheckBox x="138" y="80" label="Import from template" id="importToggle"/>
					
					</Container>
				
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