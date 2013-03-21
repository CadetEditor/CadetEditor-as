// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import core.editor.contexts.IEditorContext;
	import core.app.core.contexts.IInspectableContext;
	import core.app.core.contexts.IOperationManagerContext;
	
	public interface ICadetEditorContext extends IEditorContext,
											IInspectableContext, 
											IOperationManagerContext,
											ICadetContext
	{
		
	}
}