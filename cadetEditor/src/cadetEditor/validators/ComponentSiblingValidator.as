// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.validators
{
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	public class ComponentSiblingValidator implements IComponentValidator
	{
		private var maxSiblingsOfSameType	:int = -1;
		private var requiredSiblingTypes	:Array;
		
		public function ComponentSiblingValidator( maxSiblingsOfSameType:int = -1, requiredSiblingTypes:Array = null )
		{
			this.maxSiblingsOfSameType = maxSiblingsOfSameType;
			this.requiredSiblingTypes = requiredSiblingTypes || [];
		}
		
		public function validate(componentType:Class, parent:IComponentContainer):Boolean
		{
			if ( maxSiblingsOfSameType != -1 )
			{
				var numSameTypeSiblings:int = ComponentUtil.getChildrenOfType( parent, componentType, false ).length;
				if ( numSameTypeSiblings >= maxSiblingsOfSameType ) return false;
			}
			
			for each ( var requiredSiblingType:Class in requiredSiblingTypes )
			{
				var numRequiredSiblings:int = ComponentUtil.getChildrenOfType( parent, requiredSiblingType, false ).length;
				if ( numRequiredSiblings == 0 ) return false;
			}
			
			return true;
		}
	}
}