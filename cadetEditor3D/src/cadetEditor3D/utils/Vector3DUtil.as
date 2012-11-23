package cadetEditor3D.utils
{
	import away3d.containers.View3D;
	
	import flash.geom.Vector3D;

	public class Vector3DUtil
	{
		static public function getMousePositionOnPlane( planePos:Vector3D, planeNormal:Vector3D, view3D:View3D ):Vector3D
		{
			var rayPosition:Vector3D = view3D.camera.position;
			var rayDirection:Vector3D = view3D.unproject( view3D.mouseX, view3D.mouseY );
			rayDirection = rayDirection.subtract(rayPosition);
			rayDirection.normalize();
			
			var delta:Vector3D = planePos.subtract(rayPosition);
			var d:Number = delta.dotProduct(planeNormal) / rayDirection.dotProduct(planeNormal);
			rayDirection.scaleBy(d);
			
			return rayPosition.add( rayDirection );
		}
	}
}