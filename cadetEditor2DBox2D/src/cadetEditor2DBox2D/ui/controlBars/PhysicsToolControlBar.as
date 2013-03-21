package cadetEditor2DBox2D.ui.controlBars
{
	import flash.events.Event;
	
	import core.ui.components.CheckBox;
	import core.ui.components.DropDownMenu;
	import core.ui.components.HBox;
	import core.data.ArrayCollection;
	import core.ui.util.FloxDeserializer;
	
	public class PhysicsToolControlBar extends HBox
	{
		// General
		public var rigidBodyCheckbox	:CheckBox;
		public var fixedCheckBox		:CheckBox;
		public var mouseDragCheckbox	:CheckBox;
		// Connection
		public var createJointCheckBox	:CheckBox;
		public var jointTypeList		:DropDownMenu;
		
		public static const JOINT_REVOLUTE	:String = "Revolute";
		public static const JOINT_DISTANCE	:String = "Distance";
		public static const JOINT_SPRING	:String = "Spring";
		public static const JOINT_PRISMATIC	:String = "Prismatic";
		
		
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
					<CheckBox id="fixedCheckBox" label="Fixed"/>
					<CheckBox id="mouseDragCheckbox" label="Mouse Drag"/>
					
					<VRule height="100%"/>
					
					<CheckBox id="createJointCheckBox" label="Joint:" />
					<!--<Label text="Type:"/>-->
					<DropDownMenu id="jointTypeList"/>
				
					<!--	
					<Label text="Density:"/>
					<NumericStepper id="densityInput" stepSize="0.01" min="0.01" max="100" value="1" width="60"/>
					
					<Label text="Friction:"/>
					<NumericStepper id="frictionInput" stepSize="0.01" min="0.01" max="100" value="0.8" width="60"/>
					
					<Label text="Restitution:"/>
					<NumericStepper id="restitutionInput" stepSize="0.01" min="0.01" max="100" value="0.5" width="60"/>
					-->
				</HBox>
			
			FloxDeserializer.deserialize(xml,this);
			
			rigidBodyCheckbox.addEventListener(Event.CHANGE, changeCheckBoxHandler);
			
			jointTypeList.dataProvider = new ArrayCollection( [JOINT_DISTANCE, JOINT_SPRING, JOINT_PRISMATIC] );
			// Revolute
			createJointCheckBox.addEventListener(Event.CHANGE, changeCheckBoxHandler);
			
			validateInput();
		}

		private function changeCheckBoxHandler( event:Event ):void
		{
			validateInput();
		}
		
		private function validateInput():void
		{
			// General
			fixedCheckBox.enabled = rigidBodyCheckbox.selected;
			mouseDragCheckbox.enabled = rigidBodyCheckbox.selected;
			
			// Connection
			jointTypeList.enabled = createJointCheckBox.selected;
		}		
	}
}