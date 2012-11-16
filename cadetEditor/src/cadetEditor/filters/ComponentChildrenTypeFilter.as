// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.filters
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;

	/**
	 * This filters components based upon the type of their children. At least one of a components children must be
	 * one of the supplied types.
	 * @author Jonathan Pace
	 * 
	 */	
	public class ComponentChildrenTypeFilter
	{
		private var validTypes		:Array;
		
		public function ComponentChildrenTypeFilter( validTypes:Array )
		{
			this.validTypes = validTypes;
		}

		public function filterFunc(item:Object):Boolean
		{
			var componentContainer:IComponentContainer = item as IComponentContainer;
			if ( !componentContainer ) return false;
			
			for each ( var child:IComponent in componentContainer.children )
			{
				for each ( var type:Class in validTypes )
				{
					if ( child is type ) return true;
				}
			}
			
			return false;
		}
	}
}