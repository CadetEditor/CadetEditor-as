// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.tools
{
	import cadet2D.components.geom.CircleGeometry;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class CircleTool extends GeometryPrimitiveTool
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, CircleTool, "Circle Tool", CadetEditorIcons.CircleTool );
		}
		
		public function CircleTool()
		{
			GeometryType = CircleGeometry;
		}
		
		override protected function updateShape( rect:Rectangle, normalizedRect:Rectangle, event:MouseEvent ):void
		{
			transform.x = rect.x;
			transform.y = rect.y
			
			CircleGeometry( geometry ).radius = Math.sqrt(normalizedRect.width*normalizedRect.width + normalizedRect.height*normalizedRect.height);
		}
		
		
		override protected function isShapeValid():Boolean
		{
			return CircleGeometry( geometry ).radius > 1;
		}
		
		override protected function getOperationDescription():String { return "Create Circle"; }
		override protected function getName():String { return "Circle"; }
	}
}