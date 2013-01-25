// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.util
{
	import cadet.core.Component;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import cadet2D.components.skins.IRenderable;
	
	import flash.utils.Dictionary;
	
	public class SelectionUtil
	{
		public static function doesArrayContainComponentAnscestor( array:Array, component:IComponent ):Boolean
		{
			if ( array.indexOf(component) != -1 ) return true;
			if ( component.parentComponent == null ) return false;
			return doesArrayContainComponentAnscestor( array, component.parentComponent );
		}
		
		public static function getSkinsFromComponents( components:Array, visitedComponents:Dictionary = null ):Array
		{
			var skins:Array = [];
			
			if ( visitedComponents == null )
			{
				visitedComponents = new Dictionary(true);
			}
			
			const L:int = components.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var component:IComponent = components[i];
				
				if ( visitedComponents[component] ) continue;
				visitedComponents[component] = true;
				
				if ( component is IRenderable )
				{
					skins.push(component);
				}
				else if ( component is IComponentContainer )
				{
					skins = skins.concat( getSkinsFromComponents( IComponentContainer(component).children.source, visitedComponents ) );
				}
				else if ( component.parentComponent && component.parentComponent != component.scene )
				{
					skins = skins.concat( getSkinsFromComponents( component.parentComponent.children.source, visitedComponents ) );
				}
			}
			return skins;
		}
	}
}


















