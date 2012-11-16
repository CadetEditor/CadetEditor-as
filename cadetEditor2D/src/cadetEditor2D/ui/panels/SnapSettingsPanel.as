// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.ui.panels
{
	import flash.events.Event;
	
	import flox.ui.components.Button;
	import flox.ui.components.CheckBox;
	import flox.ui.components.List;
	import flox.ui.components.NumericStepper;
	import cadetEditor.ui.components.OutlineTree;
	import flox.ui.components.Panel;
	import flox.ui.components.RadioButtonGroup;
	import flox.ui.util.FloxDeserializer;
	
	import flox.editor.FloxEditor;
	import flox.app.util.StringUtil;
	import flox.app.util.Validation;
	
	public class SnapSettingsPanel extends Panel
	{
		public var okBtn					:Button;
		public var cancelBtn				:Button;
		public var gridSnapToggle			:CheckBox;
		public var vertexSnapToggle			:CheckBox;
		public var centerPointSnapToggle	:CheckBox;
		public var snapRadiusControl		:NumericStepper;
		
		public function SnapSettingsPanel()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				<Panel width="330" height="260" label="Snap Settings" >
					
					<VBox width="100%" height="100%">
						
						<CheckBox id="gridSnapToggle" label="Grid"/>
						<CheckBox id="vertexSnapToggle" label="Vertex"/>
						<CheckBox id="centerPointSnapToggle" label="Center Point" />
						<HBox verticalAlign="center">
							<NumericStepper id="snapRadiusControl" max="999" min="1" stepSize="1"/>
							<Label text="Snap Radius"/>
						</HBox>
						
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