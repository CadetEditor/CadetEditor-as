// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.ui.controlBars
{
	import flash.events.Event;
	
	import flox.ui.components.CheckBox;
	import flox.ui.components.DropDownMenu;
	import flox.ui.components.HBox;
	import flox.core.data.ArrayCollection;
	import flox.ui.util.FloxDeserializer;
	
	public class ConnectionToolControlBar extends HBox
	{
		public var createJointCheckBox	:CheckBox;
		public var jointTypeList		:DropDownMenu;
		
		public function ConnectionToolControlBar()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
			<HBox width="100%" height="100%" verticalAlign="centre">
				
				<CheckBox id="createJointCheckBox" label="Create Joint:" />
				<Label text="Type:"/>
				<DropDownMenu id="jointTypeList"/>
				
			</HBox>
				
			FloxDeserializer.deserialize(xml,this);
			
			jointTypeList.dataProvider = new ArrayCollection( ["Distance", "Spring", "Prismatic"] );
			createJointCheckBox.addEventListener(Event.CHANGE, changeCheckBoxHandler);
			validateInput();
		}
		
		private function changeCheckBoxHandler( event:Event ):void
		{
			validateInput();
		}
		
		private function validateInput():void
		{
			jointTypeList.enabled = createJointCheckBox.selected;
		}
	}
}