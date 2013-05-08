// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.views
{
	import core.ui.components.Button;
	import core.ui.components.Container;
	import core.ui.components.NumberInput;
	import core.ui.util.CoreDeserializer;
	
	public class TransformView extends Container
	{
		public var xField			:NumberInput;
		public var yField			:NumberInput;
		public var widthField		:NumberInput;
		public var heightField		:NumberInput;
		public var rotationField	:NumberInput;
		public var resetBtn			:Button;
		public var rotateCWBtn		:Button;
		public var rotateCCWBtn		:Button;
		
		public function TransformView()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
			<Container width="100%" height="100">
	
				<Label x="10" y="12" text="x:"/>
				<Label x="10" y="42" text="y:"/>
				<Label x="95" y="12" text="width:"/>
				<Label x="95" y="42" text="height:"/>
				<Label x="87" y="72" text="rotation:"/>
			
				<NumberInput x="35" y="10" width="52" id="xField" numDecimalPlaces="0"/>
				<NumberInput x="35" y="40" width="52" id="yField" numDecimalPlaces="0"/>
				<NumberInput x="148" y="10" width="52" id="widthField" numDecimalPlaces="0"/>
				<NumberInput x="148" y="40" width="52" id="heightField" numDecimalPlaces="0"/>
				<NumberInput x="148" y="70" width="52" id="rotationField" numDecimalPlaces="0"/>
				
				<Button x="266" y="9" width="24" height="24" id="resetBtn" toolTip="Reset transform" icon="cadetEditor.ui.icons.CadetBuilderIcons_Transform"/>
				<Button x="266" y="39" width="24" height="24" id="rotateCWBtn" toolTip="Rotate 90 degrees" icon="cadetEditor.ui.icons.CadetBuilderIcons_RotateCW"/>
				<Button x="266" y="69" width="24" height="24" id="rotateCCWBtn" toolTip="Rotate -90 degrees" icon="cadetEditor.ui.icons.CadetBuilderIcons_RotateCCW"/>
				
			</Container>;
				
			CoreDeserializer.deserialize( xml, this );
		}
	}
}