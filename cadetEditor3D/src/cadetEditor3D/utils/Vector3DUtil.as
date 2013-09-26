package cadetEditor3D.utils
{
	import away3d.containers.View3D;
	
	import flash.geom.Vector3D;

	public class Vector3DUtil
	{
		static public function getMousePositionOnPlane( planePos:Vector3D, planeNormal:Vector3D, view3D:View3D ):Vector3D
		{
			var rayPosition:Vector3D = view3D.camera.position;
			trace("mouseX "+view3D.mouseX+" mouseY "+view3D.mouseY);
			trace("rayPosition "+rayPosition);
			var rayDirection:Vector3D = view3D.unproject( view3D.mouseX, view3D.mouseY, 0);
			trace("rayDirection preSubtract "+rayDirection);
			rayDirection = rayDirection.subtract(rayPosition);
			trace("rayDirection preNormalise "+rayDirection);
			rayDirection.normalize();
			// TODO: This is wrong, should be between 0 & -1
			trace("rayDirection "+rayDirection);
			
			var delta:Vector3D = planePos.subtract(rayPosition);
			//trace("delta "+delta);
			var deltaPlaneNorm:Number = delta.dotProduct(planeNormal);
			// divide by zero error
			var rayPlaneNorm:Number = Math.max(rayDirection.dotProduct(planeNormal), 0.1);
			var d:Number = deltaPlaneNorm / rayPlaneNorm;
			//trace("deltaPlaneNorm "+deltaPlaneNorm+" rayPlaneNorm "+rayPlaneNorm+" d "+d);
			rayDirection.scaleBy(d);
			//trace("rayDirection2 "+rayDirection);
			return rayPosition.add( rayDirection );
		}
	}
}