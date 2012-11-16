// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.managers 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Jon
	 */
	public class SnapInfo
	{
		public static const VERTEX		:int = 0;
		public static const GRID		:int = 1;
		public static const CENTER_POINT:int = 2;
		public static const OTHER		:int = 3;
		
		public var snapPoint:Point;
		public var snapType	:int;
		
		public function SnapInfo() 
		{
			
		}
	}
}