// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.ui.panels
{
	import core.ui.components.Button;
	import core.ui.components.Panel;
	import core.ui.components.TextArea;
	import core.ui.util.FloxDeserializer;

	public class TextOutputPanel extends Panel
	{
		public var copyBtn					:Button;
		public var cancelBtn				:Button;
		public var textArea					:TextArea;
		
		public function TextOutputPanel()
		{
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				<Panel
					width="460" 
					height="250" 
					label="Output Panel"
					>	
					
					<VBox width="100%" height="100%" paddingTop="10" paddingLeft="10" paddingRight="10" id="group">
						<TextArea width="100%" height="100%" id="textArea"></TextArea>
					</VBox>
					
					<controlBar>
						<Button label="Copy to Clipboard" width="140" id="copyBtn"/>
						<Button label="Close" width="80" id="cancelBtn"/>
					</controlBar>
				</Panel>
			
			FloxDeserializer.deserialize( xml, this );
			defaultButton = copyBtn;
		}					
	}
}