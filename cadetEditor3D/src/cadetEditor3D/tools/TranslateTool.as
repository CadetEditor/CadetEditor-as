// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Entity;
	
	import cadet3D.components.core.Object3DComponent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.tools.gizmos.TranslateGizmo;
	import cadetEditor3D.utils.Vector3DUtil;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class TranslateTool extends TransformToolBase
	{
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, TranslateTool, "Translate [W]", CadetEditor3DIcons.Translate, [Keyboard.W] );
		}
		
		private var gizmoStartDragPosition	:Vector3D;
		private var translateGizmo			:TranslateGizmo;
		private var lockToAxis				:Vector3D;
		
		public function TranslateTool()
		{
			gizmo = translateGizmo = new TranslateGizmo();
			operationName = "Translate";
		}
		
		override protected function beginDrag():void
		{
			super.beginDrag();
			gizmoStartDragPosition = gizmo.position;
		}
		
		override protected function updateDrag():void
		{
			//var currentPosition:Vector3D = getMousePositionOnPlane( dragStartPoint, dragPlane );
			var currentPosition:Vector3D = Vector3DUtil.getMousePositionOnPlane( dragStartPoint, dragPlane, renderer.view3D );
			var delta:Vector3D = currentPosition.subtract(dragStartPoint);
			
			trace("TT currentPosition x "+Math.round(currentPosition.x)+" y "+Math.round(currentPosition.y)+" z "+Math.round(currentPosition.z));
			trace("TT delta x "+Math.round(delta.x)+" y "+Math.round(delta.y)+" z "+Math.round(delta.z));
			
			if ( lockToAxis )
			{
				var angle:Number = Vector3D.angleBetween( delta, lockToAxis );
				var cos:Number = Math.cos(angle);
				var v:Vector3D = lockToAxis.clone();
				v.scaleBy( cos * delta.length );
				delta = v;
			}
			
			gizmo.position = gizmoStartDragPosition.add(delta);
			for ( var i:int = 0; i < entitiesBeingTransformed.length; i++ )
			{
				var entity:Object3DComponent = entitiesBeingTransformed[i];
				var transform:Matrix3D = storedEntityTransforms[i].clone();
				transform.appendTranslation( delta.x, delta.y, delta.z );
				entity.transform = transform;
			}
		}
		
		override protected function handleMouseDown( entities:Vector.<Entity> ):Boolean
		{
			dragPlane = null;
			lockToAxis = null;
			
			var overEntity:Entity = gizmo.getClosestActiveEntity(entities);
			
			switch ( overEntity )
			{
				case translateGizmo.armX :
					dragPlane = Vector3D.Z_AXIS;
					lockToAxis = Vector3D.X_AXIS;
					return true;
					break;
				case translateGizmo.armY :
					dragPlane = Vector3D.Z_AXIS;
					lockToAxis = Vector3D.Y_AXIS;
					return true;
					break;
				case translateGizmo.armZ :
					dragPlane = Vector3D.X_AXIS;
					lockToAxis = Vector3D.Z_AXIS;
					return true;
					break;
				case translateGizmo.planeXY :
					dragPlane = Vector3D.Z_AXIS;
					return true;
					break;
				case translateGizmo.planeXZ :
					dragPlane = Vector3D.Y_AXIS;
					return true;
					break;
				case translateGizmo.planeZY :
					dragPlane = Vector3D.X_AXIS;
					return true;
					break;
			}
			
			return false;
		}
	}
}