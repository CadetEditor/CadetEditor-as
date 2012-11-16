// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.operations
{
	import cadet.core.IComponent;
	
	import flox.app.managers.DependencyManager;
	import flox.app.operations.UndoableCompoundOperation;

	public class RemoveComponentsOperation extends UndoableCompoundOperation
	{
		public function RemoveComponentsOperation( items:Array, dependencyManager:DependencyManager )
		{
			var removedItems:Array = [];
			for each ( var component:IComponent in items )
			{
				addOperation( new RemoveComponentOperation( component, dependencyManager, removedItems ) );
			}
		}
	}
}