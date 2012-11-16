// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.entities
{
	import flox.app.resources.FactoryResource;
	import flox.app.resources.ITargetedResource;
	
	public class ToolFactory extends FactoryResource implements ITargetedResource
	{
		private var _target				:Class;
		private var _keyCodes			:Array;
		private var _keyToggle			:Boolean;
		
		
		public function ToolFactory( target:Class, type:Class,label:String, icon:Class = null, keyCodes:Array = null, keyToggle:Boolean = true )
		{
			super( type, label, icon );
			_keyCodes = keyCodes;
			_target = target;
			_keyToggle = keyToggle;
		}
		
		public function get target():Class
		{ 
			return _target;
		}
		
		public function get keyCodes():Array
		{ 
			return _keyCodes;
		}
		
		public function get keyToggle():Boolean
		{
			return _keyToggle;
		}
		
	}
}