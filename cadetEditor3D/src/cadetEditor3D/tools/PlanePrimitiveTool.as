// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Mesh;
	import away3d.primitives.CubeGeometry;
	
	import cadet3D.components.geom.CubeGeometryComponent;
	import cadet3D.components.geom.PlaneGeometryComponent;
	import cadet3D.components.geom.SphereGeometryComponent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	
	import flash.geom.Vector3D;

	public class PlanePrimitiveTool extends AbstractPrimitveTool
	{
		private var geometryComponent	:PlaneGeometryComponent;
		
		private var mousePressPoint	:Vector3D;
		
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, PlanePrimitiveTool, "Create Plane", CadetEditor3DIcons.Plane );
		}
		
		public function PlanePrimitiveTool()
		{
			
		}
		
		override protected function begin():void
		{
			meshComponent.name = "Plane";
			
			geometryComponent = new PlaneGeometryComponent();
			geometryComponent.name = "Plane Geometry";
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
			geometryComponent.width = geometryComponent.height = delta.length*2;
		}
	}
}