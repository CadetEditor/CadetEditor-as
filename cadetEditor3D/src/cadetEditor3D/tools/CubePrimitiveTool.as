// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Mesh;
	import away3d.primitives.CubeGeometry;
	
	import cadet3D.components.geom.CubeGeometryComponent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	
	import flash.geom.Vector3D;

	public class CubePrimitiveTool extends AbstractPrimitveTool
	{
		private var geometryComponent	:CubeGeometryComponent;
		
		private var mousePressPoint	:Vector3D;
		
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, CubePrimitiveTool, "Create Cube", CadetEditor3DIcons.Cube );
		}
		
		public function CubePrimitiveTool()
		{
			
		}
		
		override protected function begin():void
		{
			meshComponent.name = "Cube";
			
			geometryComponent = new CubeGeometryComponent();
			geometryComponent.name = "Cube Geometry";
			meshComponent.geometryComponent = geometryComponent;
			meshComponent.children.addItem(geometryComponent);
			
			mousePressPoint = getMousePositionOnPlane( new Vector3D(), Vector3D.Y_AXIS );
			meshComponent.x = mousePressPoint.x;
			meshComponent.y = mousePressPoint.y;
			meshComponent.z = mousePressPoint.z;
		}
		
		override protected function update():void
		{
			var mouseWorldPos:Vector3D = getMousePositionOnPlane( new Vector3D(), Vector3D.Y_AXIS );
			var delta:Vector3D = mouseWorldPos.subtract(mousePressPoint);
			geometryComponent.width = geometryComponent.height = geometryComponent.depth = delta.length * 0.5;
			meshComponent.y = geometryComponent.height * 0.5;
		}
	}
}