// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.tools
{
	import cadet2D.components.geom.TriangleGeometry;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class TriangleTool extends GeometryPrimitiveTool
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, TriangleTool, "Triangle Tool", CadetEditorIcons.TriangleTool );
		}
		
		public function TriangleTool()
		{
			GeometryType = TriangleGeometry;
		}
		
		override protected function updateShape( rect:Rectangle, normalizedRect:Rectangle, event:MouseEvent ):void
		{
			transform.x = normalizedRect.x;
			transform.y = normalizedRect.y
			TriangleGeometry( geometry ).width = normalizedRect.width;
			TriangleGeometry( geometry ).height = normalizedRect.height;
		}
		
		
		override protected function isShapeValid():Boolean
		{
			return TriangleGeometry( geometry ).width > 0 && TriangleGeometry( geometry ).height > 0;
		}
		
		override protected function getOperationDescription():String { return "Create Triangle"; }
		override protected function getName():String { return "Triangle"; }
	}
}