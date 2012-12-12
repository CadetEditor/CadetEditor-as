// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Entity;
	
	import cadet3D.components.core.ObjectContainer3DComponent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.tools.gizmos.ScaleGizmo;
	import cadetEditor3D.utils.Vector3DUtil;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class ScaleTool extends TransformToolBase
	{
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, ScaleTool, "Scale [R]", CadetEditor3DIcons.Scale, [Keyboard.R] );
		}
		
		private var scaleAxis		:Array;
		private var scaleGizmo		:ScaleGizmo;
		
		public function ScaleTool()
		{
			gizmo = scaleGizmo = new ScaleGizmo();
			operationName = "Scale";
		}
		
		override protected function updateFromSelection():void
		{
			super.updateFromSelection();
			
			if ( entitiesBeingTransformed.length == 0 ) return;
			
			if ( entitiesBeingTransformed.length == 1 )
			{
				gizmo.rotationX = entitiesBeingTransformed[0].rotationX;
				gizmo.rotationY = entitiesBeingTransformed[0].rotationY;
				gizmo.rotationZ = entitiesBeingTransformed[0].rotationZ;
			}
			else
			{
				gizmo.rotationX = gizmo.rotationY = gizmo.rotationZ = 0;
			}
		}
		
		override protected function handleMouseDown( entities:Vector.<Entity> ):Boolean
		{
			var overEntity:Entity = gizmo.getClosestActiveEntity(entities);
			switch ( overEntity )
			{
				case scaleGizmo.armX :
					dragPlane = gizmo.forwardVector;
					scaleAxis = [1,0,0];
					return true;
					break;
				case scaleGizmo.armY :
					dragPlane = gizmo.forwardVector;
					scaleAxis = [0,1,0];
					return true;
					break;
				case scaleGizmo.armZ :
					dragPlane = gizmo.rightVector;
					scaleAxis = [0,0,1];
					return true;
					break;
				case scaleGizmo.planeXY :
					dragPlane = gizmo.forwardVector;
					scaleAxis = [1,1,0];
					return true;
					break;
				case scaleGizmo.planeXZ :
					dragPlane = gizmo.upVector;
					scaleAxis = [1,0,1];
					return true;
					break;
				case scaleGizmo.planeZY :
					dragPlane = gizmo.rightVector;
					scaleAxis = [0,1,1];
					return true;
					break;
				case scaleGizmo.center :
					dragPlane = context.renderer.cameraComponent.camera.position.subtract( gizmo.position );
					dragPlane.normalize();
					scaleAxis = [1,1,1];
					return true;
					break;
			}
			
			return false;
		}
		
		override protected function updateDrag():void
		{
			//var currentPosition:Vector3D = getMousePositionOnPlane( dragStartPoint, dragPlane );
			var currentPosition:Vector3D = Vector3DUtil.getMousePositionOnPlane( dragStartPoint, dragPlane, renderer.view3D );
			var delta:Vector3D = currentPosition.subtract(dragStartPoint);
			
			var m:Matrix3D = gizmo.transform.clone();
			m.position = new Vector3D();
			m.invert();
			delta = m.transformVector(delta)
			
			var length:Number = delta.x + delta.y + delta.z;
			var scaleAmount:Number = 1 + length * 0.005;
			scaleAmount = scaleAmount < 0.1 ? 0.1 : scaleAmount;
			
			for ( var i:int = 0; i < entitiesBeingTransformed.length; i++ )
			{
				var entity:ObjectContainer3DComponent = entitiesBeingTransformed[i];
				var transform:Matrix3D = storedEntityTransforms[i].clone();
				transform.prependScale( scaleAxis[0] == 1 ? scaleAmount : 1, scaleAxis[1] == 1 ? scaleAmount : 1, scaleAxis[2] == 1 ? scaleAmount : 1 );
				entity.transform = transform;
			}
		}
	}
}