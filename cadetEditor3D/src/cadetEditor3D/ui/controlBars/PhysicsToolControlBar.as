package cadetEditor3D.ui.controlBars
{
	import flash.events.Event;
	
	import core.ui.components.CheckBox;
	import core.ui.components.HBox;
	import core.ui.util.FloxDeserializer;
	
	public class PhysicsToolControlBar extends HBox
	{
		// General
		public var rigidBodyCheckbox	:CheckBox;

		public function PhysicsToolControlBar()
		{
			super();
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				<HBox width="100%" height="100%" verticalAlign="centre">
					<VRule height="100%"/>
					
					<CheckBox id="rigidBodyCheckbox" label="Rigid Body" />
				</HBox>
			
			FloxDeserializer.deserialize(xml,this);
			
			rigidBodyCheckbox.addEventListener(Event.CHANGE, changeCheckBoxHandler);
			
			validateInput();
		}
		
		private function changeCheckBoxHandler( event:Event ):void
		{
			validateInput();
		}
		
		private function validateInput():void
		{
			
		}		
	}
}