// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.data
{
	import flash.utils.Dictionary;
	
	import cadet.assets.CadetEngineIcons;
	import cadet.core.IComponentContainer;
	import cadet.entities.ComponentFactory;
	
	import core.app.CoreApp;
	import core.app.resources.IResource;
	import core.app.util.IntrospectionUtil;
	import core.data.ArrayCollection;
	import core.ui.data.IDataDescriptor;
	
	public class OutlineTreeDataDescriptor implements IDataDescriptor
	{
		private static var factories		:Vector.<IResource>;
		private static var iconTable		:Dictionary;
		
		public function OutlineTreeDataDescriptor()
		{
			
		}
		
		public function getLabel(data:Object):String 
		{
			return data.name;
		}
		
		public function getIcon(data:Object):Object 
		{
			// This is an expensive call, so the result is cached in a static variable.
			if ( !factories )
			{
				factories = CoreApp.resourceManager.getResourcesOfType(ComponentFactory);
				iconTable = new Dictionary();
			}
			
			var type:Class = IntrospectionUtil.getType(data);
			
			var icon:Class = iconTable[type];
			
			if ( icon ) return icon;
			
			for each ( var factory:ComponentFactory in factories )
			{
				if ( data is factory.getInstanceType() )
				{
					iconTable[type] = factory.icon;
					return factory.icon;
				}
			}
			return CadetEngineIcons.Component;
		}
		
		public function hasChildren(data:Object):Boolean 
		{
			if ( data is IComponentContainer ) return true;
			return false;
		}
		
		public function getChildren(data:Object):ArrayCollection 
		{
			var container:IComponentContainer = data as IComponentContainer;
			if ( !container ) return null;
			return container.children;
			return null;
		}
		
		public function getEnabled( item:Object ):Boolean
		{
			return true;
		}
		
		public function getChangeEventTypes( item:Object ):Array
		{
			return [ "propertyChange_name" ];
		}
	}
}