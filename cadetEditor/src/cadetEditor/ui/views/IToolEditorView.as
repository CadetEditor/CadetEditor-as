// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.views
{
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	
	import core.ui.components.RadioButtonGroup;
	
	public interface IToolEditorView extends IEventDispatcher
	{
		function addToolButton( icon:Class, toolTip:String = null ):void
		function get toolBar():RadioButtonGroup
	}
}