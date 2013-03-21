// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.tools
{
	import core.app.core.contexts.IContext;
	
	public interface ITool
	{
		function init(context:IContext):void
		function dispose():void
		function enable():void
		function disable():void
	}
}