// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.components
{
	import flash.events.Event;
	import core.ui.components.UIComponent;

	public class BitControl extends UIComponent
	{
		private var _dataProvider	:uint;
		
		public function BitControl()
		{
			
		}
		
		override protected function init():void
		{
			/*
			setStyle( "verticalGap", 0 );
			setStyle( "horizontalGap", 0 );
			
			tileWidth = 40;
			tileHeight = 30;
			
			for ( var i:int = 0; i < 32; i++ )
			{
				var btn:Button = new Button();
				btn.label = String(i+1);
				btn.toggle = true;
				btn.width = tileWidth;
				btn.height = tileHeight;
				btn.addEventListener(Event.CHANGE, changeHandler);
				addChild(btn);
			}
			*/
		}
		/*
		private function changeHandler( event:Event ):void
		{
			var btn:Button = Button(event.target);
			var btnIndex:int = getChildIndex(btn);
			
			if ( btn.selected )
			{
				
				_dataProvider = _dataProvider | (1 << btnIndex);
			}
			else
			{
				var mask:uint = uint.MAX_VALUE ^ (1 << btnIndex);
				_dataProvider = _dataProvider & mask;
			}
		}
		
		public function set dataProvider( value:uint ):void
		{
			_dataProvider = value;
			invalidateProperties();
		}
		public function get dataProvider():uint { return _dataProvider; }
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			for ( var i:int = 0; i < numChildren; i++ )
			{
				var btn:Button = Button( getChildAt(i) );
				var bit:uint = 1 << i;
				btn.selected = (bit & _dataProvider) != 0;
			}
		}
		*/
	}
}