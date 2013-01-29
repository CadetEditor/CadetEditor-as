package platformer.ui.panels
{
	import flash.events.Event;
	
	import flox.app.FloxApp;
	import flox.ui.components.Button;
	import flox.ui.components.Canvas;
	import flox.ui.components.Panel;
	import flox.ui.components.ScrollPane;
	import flox.ui.util.FloxDeserializer;
	
	public class BrushesPanel extends Panel
	{
		private var brushesList:XMLList;
		public var container:ScrollPane;
		
		private var selectedBtn:Button;
		private var _selectedIndex:uint;
		
		public function BrushesPanel(brushes:XMLList)
		{
			this.brushesList = brushes;
			super();
		}
		
		override protected function init():void
		{
			super.init();
			
			var xml:XML = 
				<Panel width="130" height="200">
					<ScrollPane id="container" width="100%" height="100%"/>
				</Panel>
			
			FloxDeserializer.deserialize( xml, this, ["flox.editor.ui.components"] );
		
			var tileSize:uint = 50;
			var xpos:uint = 0;
			var ypos:uint = 0;
			for ( var i:uint = 0; i < brushesList.length(); i ++ )
			{
				var linkage:String = brushesList[i].@path;
				linkage += "0000";
				
				var brushBtn:Button = new Button();
				brushBtn.userData = i;
				brushBtn.addEventListener( Event.CHANGE, selectHandler );
				brushBtn.toggle = true;
				brushBtn.width = tileSize;
				brushBtn.height = tileSize;
				brushBtn.x = xpos;
				brushBtn.y = ypos;
				if (i == 0) brushBtn.selected = true;
				FloxApp.resourceManager.bindResource( linkage+".png", brushBtn, "icon");
				container.addChild(brushBtn);
				
				xpos += tileSize;
				if ( xpos == tileSize * 2 ) {
					xpos = 0;
					ypos += tileSize;
				}
			}
			
			//container.validateNow();
		}
		
		private function selectHandler( event:Event ):void
		{
			if (selectedBtn) { 
				selectedBtn.selected = false;
			}
			
			selectedBtn = Button(event.target);
			_selectedIndex = selectedBtn.userData;
			
			dispatchEvent( event );
		}
		
		public function get selectedIndex():uint
		{
			return _selectedIndex;
		}
	}
}










