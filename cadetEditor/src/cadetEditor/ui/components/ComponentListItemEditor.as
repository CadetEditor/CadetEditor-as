// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.components
{
	import cadet.core.IComponent;
	import cadet.util.ComponentUtil;
	
	import flash.utils.*;
	
	import flox.core.data.ArrayCollection;
	import flox.ui.data.DefaultDataDescriptor;
	
	import flox.app.util.VectorUtil;
	import flox.ui.components.DropDownMenu;

	public class ComponentListItemEditor extends DropDownMenu
	{
		private var _components		:Array;
		private var _propertyName	:String;
		private var _scope			:String = "parent";
		
		private var dataProviderInvalid	:Boolean = false;
		
		public function ComponentListItemEditor()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			DefaultDataDescriptor(list.dataDescriptor).labelField = "name";
		}
		
		override protected function validate():void
		{
			if ( dataProviderInvalid )
			{
				validateDataProvider();
				dataProviderInvalid = false;
			}
			super.validate();
		}
		
		public function set scope( value:String ):void
		{
			if ( value != "parent" && value != "scene" )
			{
				throw( new Error( "Scope must be either 'parent' or 'scene'." ) );
				return;
			}
			_scope = value;
			dataProviderInvalid = true;
			invalidate();
		}
		public function get scope():String { return _scope; }
		
		public function set components( value:Array ):void
		{
			_components = value;
			dataProviderInvalid = true;
			invalidate();
		}
		public function get components():Array { return _components; }
		
		public function set propertyName( value:String ):void
		{
			_propertyName = value;
			dataProviderInvalid = true;
			invalidate();
		}
		public function get propertyName():String { return _propertyName; }
		
		private function validateDataProvider():void
		{
			dataProvider = new ArrayCollection();
			if ( _components.length < 0 ) return;
			var component:IComponent = _components[0] as IComponent;
			if ( component == null ) return;
			if ( propertyName == null ) return;
			if ( component.parentComponent == null ) return;
			
			var description:XML = describeType(component);
			
			var propertyNode:XML = description.variable.(@name == _propertyName)[0];
			if ( propertyNode == null )
			{
				propertyNode = description.accessor.(@name == _propertyName)[0];
			}
			
			if ( propertyNode == null ) return;
			
			var typeName:String = String( propertyNode.@type ).replace("::",".");
			var type:Class = getDefinitionByName(typeName) as Class;
			if ( type == null ) return;
			
			var dp:Vector.<IComponent> = new Vector.<IComponent>();
			if ( _scope == "parent" )
			{
				dp = ComponentUtil.getChildrenOfType( component.parentComponent, type, true );
			}
			else if ( _scope == "scene" )
			{
				dp = ComponentUtil.getChildrenOfType( component.scene, type, true );
			}
			
			dataProvider = new ArrayCollection(VectorUtil.toArray(dp));
			//dataProvider.addItemAt(null, 0);
			
			selectedItem = component[_propertyName];
		}
		
		public static function labelFunction( item:*, host:Object, property:String ):String
		{
			if ( item == null )
			{
				return "<No component>";
			}
			
			if ( item is IComponent == false )
			{
				return "<Not a component>";
			}
			
			return IComponent(item).name;
		}
								
	}
}