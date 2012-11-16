package cadetEditor2D.util
{
	import flash.geom.Matrix;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	public class DisplayListUtilStarling
	{
		static public function getChildren( container:DisplayObjectContainer, recursive:Boolean = true ):Vector.<DisplayObject>
		{
			var children:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for ( var i:int = 0; i < container.numChildren; i++ )
			{
				var child:DisplayObject = container.getChildAt(i);
				children.push(child);
				if ( child is DisplayObjectContainer && recursive )
				{
					children = children.concat( getChildren( DisplayObjectContainer(child), true ) );
				}
			}
			return children;
		}
		
		static public function getConcatenatedMatrix( dispObject:DisplayObject, top:DisplayObject = null ):Matrix
		{
			if ( top == null )
			{
				top = dispObject.stage;
				if ( top == null )
				{
					top = dispObject.parent;
				}
			}
			
			var m:Matrix = new Matrix();
			var current:DisplayObject = dispObject;
			while ( current && current != top )
			{
				m.concat(current.transformationMatrix);
				current = current.parent;
			}
			return m;
		}
	}
}