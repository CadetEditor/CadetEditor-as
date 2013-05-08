// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DBox2D.ui.controlBars
{
	import flash.events.Event;
	
	import core.ui.components.CheckBox;
	import core.ui.components.HBox;
	import core.ui.util.CoreDeserializer;
	
	public class GeometryToolControlBar extends HBox
	{
		public var rigidBodyCheckbox	:CheckBox;
		public var fixedCheckBox		:CheckBox;
		public var mouseDragCheckbox	:CheckBox;
		//public var densityInput			:NumericStepper;
		//public var frictionInput		:NumericStepper;
		//public var restitutionInput		:NumericStepper;
		
		public function GeometryToolControlBar()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
			<HBox width="100%" height="100%" verticalAlign="centre">
				
				<CheckBox id="rigidBodyCheckbox" label="Rigid Body" />
				<CheckBox id="fixedCheckBox" label="Fixed"/>
				<CheckBox id="mouseDragCheckbox" label="Mouse Drag"/>
				<!--	
				<Label text="Density:"/>
				<NumericStepper id="densityInput" stepSize="0.01" min="0.01" max="100" value="1" width="60"/>
				
				<Label text="Friction:"/>
				<NumericStepper id="frictionInput" stepSize="0.01" min="0.01" max="100" value="0.8" width="60"/>
				
				<Label text="Restitution:"/>
				<NumericStepper id="restitutionInput" stepSize="0.01" min="0.01" max="100" value="0.5" width="60"/>
				-->
			</HBox>;
				
			CoreDeserializer.deserialize(xml,this);
			
			rigidBodyCheckbox.addEventListener(Event.CHANGE, changeHandler);
			validateInput();
		}
		
		private function changeHandler( event:Event ):void
		{
			validateInput();
		}
		
		private function validateInput():void
		{
			fixedCheckBox.enabled = rigidBodyCheckbox.selected;
			mouseDragCheckbox.enabled = rigidBodyCheckbox.selected;
			//densityInput.enabled = rigidBodyCheckbox.selected;
			//frictionInput.enabled = rigidBodyCheckbox.selected;
			//restitutionInput.enabled = rigidBodyCheckbox.selected;
		}
	}
}