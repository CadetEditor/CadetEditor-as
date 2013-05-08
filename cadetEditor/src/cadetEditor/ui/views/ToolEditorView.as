// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.views
{
	import flash.geom.Rectangle;
	
	import core.ui.components.Button;
	import core.ui.components.Container;
	import core.ui.components.RadioButtonGroup;
	import core.ui.layouts.VerticalLayout;

	public class ToolEditorView extends Container implements IToolEditorView
	{
		// Display
		public var _toolBar			:RadioButtonGroup;
		
		public function ToolEditorView()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			focusEnabled = true;
			_toolBar = new RadioButtonGroup();
			_toolBar.layout = new VerticalLayout(-1);
			_toolBar.width = 28;
			addRawChild( _toolBar );
			super.getChildrenLayoutArea();
		}
		
		override protected function validate():void
		{
			super.validate();
			_toolBar.height = _height;
		}
		
		override protected function getChildrenLayoutArea():Rectangle
		{
			var rect:Rectangle = super.getChildrenLayoutArea();
			rect.x += _toolBar.width;
			rect.width -= toolBar.width;
			return rect;
		}
		
		public function addToolButton( icon:Class, toolTip:String = null ):void
		{
			var button:Button = new Button();
			button.width = button.height = _toolBar.width;
			button.toolTip = toolTip;
			button.icon = icon;
			_toolBar.addChild( button );
		}
		
		public function get toolBar():RadioButtonGroup { return _toolBar; }
	}
}