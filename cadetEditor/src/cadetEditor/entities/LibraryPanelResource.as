// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.entities
{
	import flox.app.entities.URI;

	public class LibraryPanelResource
	{
		public var uri	:URI;
		
		public function LibraryPanelResource( path:String )
		{
			uri = new URI(path);
		}

		public function get label():String
		{
			return "LibraryPanelResource : " + uri.path;
		}
		
		public function get icon():Class
		{
			return null;
		}
	}
}