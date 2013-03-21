// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.ui.controlBars
{
	import cadetEditor.assets.CadetEditorIcons;
	
	import core.ui.components.Button;
	import core.ui.components.HBox;
	import core.ui.components.HSlider;
	import core.ui.components.Label;
	import core.ui.components.NumericStepper;
	import core.ui.util.FloxDeserializer;
	
	public class CadetEditorControlBar extends HBox
	{
		public var zoomControl		:HSlider;
		public var zoomAmountLabel	:Label;
		public var gridSizeControl	:NumericStepper;
		public var gridToggle		:Button;
		public var snapToggle		:Button;
		
		public function CadetEditorControlBar()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
		
			var xml:XML =
			<HBox verticalAlign="centre" height="40" width="100%">
	
				<Label text="Zoom:" />
				<HSlider id="zoomControl" min="0.1" max="4" snapInterval="0.1" width="80" />
				<Label id="zoomAmountLabel" width="50" text="0%" />
				<VRule height="100%"/>
				<Label text="Grid:"/>
				<NumericStepper id="gridSizeControl" stepSize="1" min="1" max="100"/>
				<Button id="gridToggle" toggle="true" width="28" height="28" />
				<Button id="snapToggle" toggle="true" width="28" height="28" />
			</HBox>
				
			FloxDeserializer.deserialize(xml, this);
			
			gridToggle.icon = CadetEditorIcons.Grid;
			snapToggle.icon = CadetEditorIcons.Snap;
		}
	}
}