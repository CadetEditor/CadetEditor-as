// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.data
{
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.entities.ComponentFactory;
	
	import flash.utils.Dictionary;
	
	import flox.app.FloxApp;
	import flox.app.resources.IResource;
	import flox.app.util.IntrospectionUtil;
	import flox.core.data.ArrayCollection;
	import flox.editor.FloxEditor;
	import flox.ui.data.IDataDescriptor;
	
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
				factories = FloxApp.resourceManager.getResourcesOfType(ComponentFactory);
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
			return CadetEditorIcons.Component;
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