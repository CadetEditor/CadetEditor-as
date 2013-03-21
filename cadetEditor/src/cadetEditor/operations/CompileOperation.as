// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.operations
{
	import cadet.core.ICadetScene;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.util.AsynchronousUtil;

	public class CompileOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var inputScene		:ICadetScene;
		private var outputScene		:ICadetScene;
		
		public function CompileOperation( scene:ICadetScene )
		{
			inputScene = scene;
		}
		
		public function getResult():ICadetScene { return outputScene; }

		public function execute():void
		{
			outputScene = inputScene;
			outputScene.userData = {};
			
			AsynchronousUtil.dispatchLater(this, new Event( Event.COMPLETE ));
		}
		
		public function get label():String
		{
			return "Compile";
		}
	}
}