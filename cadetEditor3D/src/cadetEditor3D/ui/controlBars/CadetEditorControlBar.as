// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.ui.controlBars
{
	import core.ui.components.HBox;
	import core.ui.util.CoreDeserializer;
	
	public class CadetEditorControlBar extends HBox
	{
//		public var zoomControl		:HSlider;
//		public var zoomAmountLabel	:Label;
//		public var gridSizeControl	:NumericStepper;
//		public var gridToggle		:Button;
//		public var snapToggle		:Button;
		
		public function CadetEditorControlBar()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML =
				<HBox verticalAlign="centre" height="40" width="100%">
					<VRule height="100%"/>
				</HBox>
			
			CoreDeserializer.deserialize(xml, this);
			
//			gridToggle.icon = CadetEditorIcons.Grid;
//			snapToggle.icon = CadetEditorIcons.Snap;
		}
	}
}