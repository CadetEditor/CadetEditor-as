// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Mesh;
	import away3d.primitives.CubeGeometry;
	
	import cadet3D.components.geom.CubeGeometryComponent;
	import cadet3D.components.geom.SphereGeometryComponent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	
	import flash.geom.Vector3D;

	public class SpherePrimitiveTool extends AbstractPrimitveTool
	{
		private var geometryComponent	:SphereGeometryComponent;
		
		private var mousePressPoint	:Vector3D;
		
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, SpherePrimitiveTool, "Create Sphere", CadetEditor3DIcons.Sphere );
		}
		
		public function SpherePrimitiveTool()
		{
			
		}
		
		override protected function begin():void
		{
			meshComponent.name = "Sphere";
			
			geometryComponent = new SphereGeometryComponent();
			geometryComponent.name = "Sphere Geometry";
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
			geometryComponent.radius = delta.length;
		}
	}
}