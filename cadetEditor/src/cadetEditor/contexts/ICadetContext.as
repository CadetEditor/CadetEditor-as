// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import cadet.core.ICadetScene;
	
	import flox.editor.contexts.IEditorContext;
	import flox.app.core.contexts.ISelectionContext;

	public interface ICadetContext extends ISelectionContext, IEditorContext
	{
		function get scene():ICadetScene
	}
}