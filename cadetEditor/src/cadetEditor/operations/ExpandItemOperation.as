// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.operations
{
	import flash.events.EventDispatcher;
	
	import flox.ui.components.Tree;
	
	import flox.app.core.operations.IUndoableOperation;

	public class ExpandItemOperation extends EventDispatcher implements IUndoableOperation
	{
		private var tree				:Tree;
		private var item				:*;
		private var isInitiallyExpanded	:Boolean;
		
		public function ExpandItemOperation( tree:Tree, item:* )
		{
			this.tree = tree;
			this.item = item;
			isInitiallyExpanded = tree.getItemOpened(item);
		}
		
		public function execute():void
		{
			tree.setItemOpened(item, true);
		}
		
		public function undo():void
		{
			if ( isInitiallyExpanded ) return;
			tree.setItemOpened( item, false );
		}
		
		public function get label():String
		{
			return "Expand Item";
		}
	}
}