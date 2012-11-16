// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.ui.components
{
	import cadet.core.IComponent;
	
	import cadetEditor.ui.data.OutlineTreeDataDescriptor;
	import flox.ui.components.Tree;
	

	public class OutlineTree extends Tree
	{
		public function OutlineTree()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			dataDescriptor = new OutlineTreeDataDescriptor();
			showRoot = false;
			allowMultipleSelection = true;
			allowDragAndDrop = true;
		}
		
		override public function set dataProvider(value:Object):void
		{
			if ( value != null && value is IComponent == false )
			{
				throw( new Error( "OutlineTree only supports a IComponent as its dataProvider" ) );
				return;
			}
			
			super.dataProvider = value;
		}
	}
}