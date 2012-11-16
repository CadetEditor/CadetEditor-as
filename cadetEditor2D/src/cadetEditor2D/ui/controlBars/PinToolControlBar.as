// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.ui.controlBars
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import flox.ui.components.CheckBox;
	import flox.ui.components.DropDownMenu;
	import flox.ui.components.HBox;
	import flox.ui.components.NumericStepper;
	import flox.core.data.ArrayCollection;
	import flox.ui.util.FloxDeserializer;
	
	public class PinToolControlBar extends HBox
	{
		public var createJointCheckBox	:CheckBox;
		
		public function PinToolControlBar()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
			<HBox width="100%" height="100%" verticalAlign="centre">
				
				<CheckBox id="createJointCheckBox" label="Create Revolute Joint:"  />
								
			</HBox>
				
			FloxDeserializer.deserialize(xml,this);
		}
	}
}