// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.operations
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import flox.app.managers.DependencyManager;
	import flox.app.operations.RemoveDependencyOperation;
	import flox.app.operations.RemoveItemOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.util.ArrayUtil;

	/**
	 * There are two ways you can remove a Component from the scene. The first way is by simply removing the component from it's
	 * parent's children array. For most situations this is fine, but sometimes the component you are removing has other components
	 * depending on it (or one of its children) being in the scene for them to function properly.
	 * 
	 * An example of this is the Connection Component. This component links two Transform2D Component's together. If one of these Transforms
	 * is removed from the scene then there is nothing for it to connect to.
	 * 
	 * Connections automatically use the DependencyManager on the CadetScene to register this dependency. This Operation honours dependencies
	 * when removing a Component from the scene, and will make sure any objects dependent on the Component being removed are also removed.
	 * 
	 * This operations will perform its behaviour recursively, so it any of the dependents are themselves dependencies for another component, then
	 * they will also be removed, and so on.
	 * @author Jonathan
	 * 
	 */	
	public class RemoveComponentOperation extends UndoableCompoundOperation
	{
		public function RemoveComponentOperation( component:IComponent, dependencyManager:DependencyManager = null, removedItems:Array = null )
		{
			if ( !removedItems )
			{
				removedItems = []
			}
			
			if ( removedItems.indexOf( component ) != -1 ) return
			removedItems.push( component );
			
			
			addOperation( new RemoveItemOperation( component, component.parentComponent.children ) );
			
			if ( !dependencyManager ) return;
			
			var childComponents:Array = [];
			if ( component is IComponentContainer )
			{
				childComponents = IComponentContainer(component).children.source;
			}
			
			// Now find and recursively remove any dependants
			var dependants:Array = [];
			dependants = dependants.concat(dependencyManager.getDependants( component ));
			
			ArrayUtil.removeDuplicates(childComponents);
			for each ( var childComponent:IComponent in childComponents )
			{
				dependants = dependants.concat(dependencyManager.getDependants( childComponent ));
			}
			
			
			for each ( var dependant:IComponent in dependants )
			{
				if ( dependant.parentComponent ) addOperation( new RemoveComponentOperation( dependant, dependencyManager, removedItems ) );
				addOperation( new RemoveDependencyOperation( dependant, component, dependencyManager ) );
			}
			
			var dependencies:Array = dependencyManager.getImmediateDependencies( component );
			for each ( var dependency:IComponent in dependencies )
			{
				addOperation( new RemoveDependencyOperation( component, dependency, dependencyManager ) );
			}
		}
	}
}