// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.tools
{
	import cadet2D.components.geom.RectangleGeometry;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;	
	
	public class RectangleTool extends GeometryPrimitiveTool
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, RectangleTool, "Rectangle Tool", CadetEditorIcons.RectangleTool );
		}
		
		public function RectangleTool()
		{
			GeometryType = RectangleGeometry;
		}
		
		override protected function updateShape( rect:Rectangle, normalizedRect:Rectangle, event:MouseEvent ):void
		{
			transform.x = normalizedRect.x;
			transform.y = normalizedRect.y;
			
			RectangleGeometry( geometry ).width = normalizedRect.width;
			RectangleGeometry( geometry ).height = normalizedRect.height;
		}
		
		
		override protected function isShapeValid():Boolean
		{
			return RectangleGeometry( geometry ).width > 0 && RectangleGeometry( geometry ).height > 0;
		}
		
		override protected function getOperationDescription():String { return "Create rectangle"; }
		override protected function getName():String { return "Rectangle"; }
	}
}