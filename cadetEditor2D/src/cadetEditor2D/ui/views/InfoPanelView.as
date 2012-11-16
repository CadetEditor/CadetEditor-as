// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.ui.views
{
	import flox.ui.components.Container;
	import flox.ui.components.Label;
	import flox.ui.util.FloxDeserializer;
	
	public class InfoPanelView extends Container
	{
		public var screenXLabel	:Label;
		public var worldXLabel	:Label;
		public var screenYLabel	:Label;
		public var worldYLabel	:Label;
		
		public function InfoPanelView()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				<Container width="300" height="120" >
					<Label x="10" y="10" text="Screen X:"/>
					<Label x="121" y="10" text="World X:"/>
					<Label x="121" y="36" text="World Y:"/>
					<Label x="10" y="36" text="Screen Y:"/>
					<Label x="76" y="10" text="45" id="screenXLabel"/>
					<Label x="182" y="10" text="45" id="worldXLabel"/>
					<Label x="76" y="36" text="76" id="screenYLabel"/>
					<Label x="182" y="36" text="76" id="worldYLabel"/>
				</Container>
				
			FloxDeserializer.deserialize(xml,this);
		}
	}
}