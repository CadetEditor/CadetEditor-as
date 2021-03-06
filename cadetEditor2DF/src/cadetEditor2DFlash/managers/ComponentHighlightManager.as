// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.managers
{
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.skins.IRenderable;
	import cadet2DFlash.components.skins.AbstractSkin2D;
	
	import cadetEditor2D.managers.IComponentHighlightManager;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	
	public class ComponentHighlightManager implements IComponentHighlightManager
	{
		private var highlightedComponents	:Array;
		private var highlightedSkins		:Array;
		
		private var filter					:GlowFilter;
		
		public function ComponentHighlightManager()
		{
			highlightedComponents = [];
			highlightedSkins = [];
			
			filter = new GlowFilter(0xFF0000, 1, 8, 8, 2, 1);
		}
		
		public function dispose():void
		{
			unhighlightAllComponents();
			
			highlightedSkins = [];
			highlightedComponents = [];
		}
		
		public function highlightComponent( component:IComponentContainer ):void
		{
			if ( highlightedComponents.indexOf(component) != -1 ) return;
			
			var skin:IRenderable = ComponentUtil.getChildOfType(component, IRenderable);
			if ( !skin )
			{
				trace("ComponentHighlightManager.highlightComponent() : Unable to highlight component as it doesn't have a Skin2D");
				return;
			}
			
			highlightedComponents.push(component);
			highlightedSkins.push(skin);
			
			AbstractSkin2D(skin).displayObjectContainer.filters = [filter];
		}
		
		public function unhighlightComponent( component:IComponentContainer ):void
		{
			var index:int = highlightedComponents.indexOf(component);
			if ( index == -1 ) return;
			var skin:IRenderable = highlightedSkins[index];
			var displayObject:DisplayObject = AbstractSkin2D(skin).displayObjectContainer;
			
			if ( !displayObject ) return;
			displayObject.filters = [];
			highlightedComponents.splice(index, 1);
			highlightedSkins.splice(index, 1);
		}
		
		public function unhighlightAllComponents():void
		{
			while ( highlightedSkins.length > 0 )
			{
				unhighlightComponent(highlightedComponents[0]);
			}
		}
	}
}