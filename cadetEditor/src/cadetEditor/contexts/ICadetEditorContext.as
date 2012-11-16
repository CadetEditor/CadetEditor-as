// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import flox.editor.contexts.IEditorContext;
	import flox.app.core.contexts.IInspectableContext;
	import flox.app.core.contexts.IOperationManagerContext;
	
	public interface ICadetEditorContext extends IEditorContext,
											IInspectableContext, 
											IOperationManagerContext,
											ICadetContext
	{
		
	}
}