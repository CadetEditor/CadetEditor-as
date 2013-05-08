// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.ui.overlays
{
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import core.ui.components.IUIComponent;
	
	public interface ICadetEditorOverlay2D extends IUIComponent
	{
		function set view( value:ICadetEditorView2D ):void;
		function get view():ICadetEditorView2D;
	}
}