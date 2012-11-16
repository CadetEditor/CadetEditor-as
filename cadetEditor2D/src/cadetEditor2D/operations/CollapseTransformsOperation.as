// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.operations
{
	import cadet.components.geom.IGeometry;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.transforms.Transform2D;
	
	import flox.app.operations.UndoableCompoundOperation;

	public class CollapseTransformsOperation extends UndoableCompoundOperation
	{
		private var components		:Array;
		
		public function CollapseTransformsOperation( components:Array )
		{
			this.components = components;
			label = "Collapse Transform(s)";
			
			for ( var i:int = 0; i < components.length; i++ )
			{
				var component:IComponentContainer = components[i];
				var transform:Transform2D = ComponentUtil.getChildOfType( component, Transform2D ) as Transform2D;
				if ( !transform ) continue;
				var geometries:Vector.<IComponent> = ComponentUtil.getChildrenOfType( component, IGeometry );
				if ( geometries.length == 0 ) continue;;
				
				for each ( var geometry:IGeometry in geometries )
				{
					addOperation( new CollapseTransformOperation( geometry, transform ) );
				}
			}
		}
	}
}