// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Entity;
	
	import cadet.events.InvalidationEvent;
	
	import cadet3D.components.core.Object3DComponent;
	import cadet3D.events.Renderer3DEvent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.events.DetailedMouse3DEvent;
	import cadetEditor3D.events.MouseEvent3DEx;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.tools.gizmos.RotateGizmo;
	import cadetEditor3D.tools.gizmos.TranslateGizmo;
	import cadetEditor3D.utils.Vector3DUtil;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import flox.app.events.OperationManagerEvent;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.core.events.ArrayCollectionEvent;
	import flox.editor.FloxEditor;

	public class RotateTool extends SelectionTool
	{
		private static const X		:int = 0;
		private static const Y		:int = 1;
		private static const Z		:int = 2;
		private static const SCREEN	:int = 3;
		
		private var rotateMode		:int;
		
		private var isDragging		:Boolean = false;
		private var dragPlaneNormal	:Vector3D;
		private var dragPlaneUp		:Vector3D;
		private var dragPlanePos	:Vector3D;
		private var dragStartPoint	:Vector3D;
		private var gizmoStoredTransform:Matrix3D;
		private var pivotPoint		:Vector3D;
		private var gizmoStoredRightVector:Vector3D;
		private var gizmoStoredUpVector:Vector3D;
		private var gizmoStoredForwardVector:Vector3D;
		
		private var delta			:Vector3D;
		
		private var entitiesBeingTransformed:Vector.<Object3DComponent>;
		private var storedEntityTransforms	:Vector.<Matrix3D>;
		
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, RotateTool, "Rotate [E]", CadetEditor3DIcons.Rotate, [Keyboard.E] );
		}
		
		private var gizmo	:RotateGizmo;
		
		public function RotateTool()
		{
			gizmo = new RotateGizmo();
		}
		
		override protected function performEnable():void
		{
			super.performEnable();
			
			renderer.addEventListener(Renderer3DEvent.PRE_RENDER, preRenderHandler);
			
			context.pickingManager.addEventListener(MouseEvent3DEx.MOUSE_OVER, mouseOverHandler, false, 10);
			context.pickingManager.addEventListener(MouseEvent3DEx.MOUSE_OUT, mouseOutHandler, false, 10);
			context.pickingManager.addEventListener(MouseEvent3DEx.MOUSE_DOWN, mouseDownHandler, false, 10);
			
			context.selection.addEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			context.operationManager.addEventListener(OperationManagerEvent.CHANGE, contextChangeHandler);
			storeInitialValues();
		}
		
		override protected function performDisable():void
		{
			super.performDisable();
			
			if ( gizmo.scene )
			{
				renderer.view3D.scene.removeChild(gizmo);
			}
			renderer.removeEventListener(Renderer3DEvent.PRE_RENDER, preRenderHandler);
			
			context.pickingManager.removeEventListener(MouseEvent3DEx.MOUSE_OVER, mouseOverHandler);
			context.pickingManager.removeEventListener(MouseEvent3DEx.MOUSE_OUT, mouseOutHandler);
			context.pickingManager.removeEventListener(MouseEvent3DEx.MOUSE_DOWN, mouseDownHandler);
			
			context.selection.removeEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			context.operationManager.removeEventListener(OperationManagerEvent.CHANGE, contextChangeHandler);
		}
		
		private function contextChangeHandler( event:OperationManagerEvent ):void
		{
			if ( isDragging )
			{
				endDrag();
			}
			storeInitialValues();
		}
		
		private function selectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			if ( isDragging )
			{
				endDrag();
			}
			storeInitialValues();
		}
		
		private function preRenderHandler( event:Renderer3DEvent ):void
		{
			// Before rendering each frame, scale the gizmo proportionatly to
			// its distance from the camera.
			// This causes the gizmo to appear the same scale at all distances.
			var d:Vector3D = renderer.view3D.camera.position.subtract(gizmo.position);
			gizmo.scaleX = gizmo.scaleY = gizmo.scaleZ = d.length * 0.001;
		}
		
		private function beginDrag():void
		{
			if ( isDragging )
			{
				throw( new Error( "Already dragging" ) );
				return;
			}
			
			ignoreNextMouseUp = true;
			isDragging = true;
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveStageHandler);
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
			
			//dragStartPoint = getMousePositionOnPlane( dragPlanePos, dragPlaneNormal );
			dragStartPoint = Vector3DUtil.getMousePositionOnPlane( dragPlanePos, dragPlaneNormal, renderer.view3D );
			gizmoStoredTransform = gizmo.transform.clone();
		}
		
		private function storeInitialValues( resetGizmo:Boolean = true ):void
		{
			entitiesBeingTransformed = new Vector.<Object3DComponent>();
			storedEntityTransforms = new Vector.<Matrix3D>();
			
			if ( resetGizmo )
			{
				gizmo.transform = new Matrix3D();
			}
			
			var averagePos:Vector3D = new Vector3D();
			for each ( var item:* in context.selection )
			{
				var entity:Object3DComponent = item as Object3DComponent
				if ( entity )
				{
					entitiesBeingTransformed.push(entity);
					averagePos = averagePos.add(entity.transform.position);
					storedEntityTransforms.push(entity.transform.clone());
				}
			}
			
			if ( entitiesBeingTransformed.length > 0 )
			{
				averagePos.scaleBy( 1/entitiesBeingTransformed.length );
				renderer.view3D.scene.addChild(gizmo);
				gizmo.position = averagePos.clone();
			}
			else if ( gizmo.scene )
			{
				renderer.view3D.scene.removeChild(gizmo);
			}
			
			pivotPoint = averagePos;
			gizmoStoredRightVector = gizmo.rightVector;
			gizmoStoredUpVector = gizmo.upVector;
			gizmoStoredForwardVector = gizmo.forwardVector;
		}
		
		private function updateDrag():void
		{
			if ( !isDragging )
			{
				throw( new Error( "No drag started to update" ) );
				return;
			}
			
			//var currentPosition:Vector3D = getMousePositionOnPlane( dragPlanePos, dragPlaneNormal );
			var currentPosition:Vector3D = Vector3DUtil.getMousePositionOnPlane( dragPlanePos, dragPlaneNormal, renderer.view3D );
			delta = currentPosition.subtract(dragStartPoint);
			
			// Project the length of delta onto dragPlaneUp
			var angleBetween:Number = Vector3D.angleBetween(delta, dragPlaneUp);
			var deltaLength:Number = delta.length * Math.cos(angleBetween);
			
			var sensitivity:Number = 0.7;
			var rotationTransform:Matrix3D = new Matrix3D();
			switch ( rotateMode )
			{
				case X :
					rotationTransform.appendRotation( -deltaLength * sensitivity, gizmoStoredRightVector, pivotPoint);
					break;
				case Y :
					rotationTransform.appendRotation( -deltaLength * sensitivity, gizmoStoredUpVector, pivotPoint);
					break;
				case Z :
					rotationTransform.appendRotation( -deltaLength * sensitivity, gizmoStoredForwardVector, pivotPoint);
					break;
				case SCREEN :
					var rotateVector:Vector3D = dragPlanePos.subtract(pivotPoint).crossProduct(currentPosition.subtract(pivotPoint));
					rotationTransform.appendRotation( delta.length * sensitivity, rotateVector, pivotPoint);
					break;
			}
			
			/*
			var gizmoTransform:Matrix3D = gizmoStoredTransform.clone();
			gizmoTransform.append(rotationTransform);
			gizmo.transform = gizmoTransform;
			*/
			
			for ( var i:int = 0; i < entitiesBeingTransformed.length; i++ )
			{
				var entity:Object3DComponent = entitiesBeingTransformed[i];
				var transform:Matrix3D = storedEntityTransforms[i].clone();
				transform.append(rotationTransform);
				entity.transform = transform;
			}
		}
		
		private function endDrag():void
		{
			if ( !isDragging )
			{
				throw( new Error( "Not dragging" ) );
				return;
			}
			
			isDragging = false;
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveStageHandler);
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
			
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Rotate";
			for ( var i:int = 0; i < entitiesBeingTransformed.length; i++ )
			{
				var entity:Object3DComponent = entitiesBeingTransformed[i];
				var storedTransform:Matrix3D = storedEntityTransforms[i];
				var newTransform:Matrix3D = entity.transform.clone();
				
				operation.addOperation( new ChangePropertyOperation( entity, "transform", newTransform, storedTransform ) );
			}
			
			delta = new Vector3D();
			
			context.operationManager.removeEventListener(OperationManagerEvent.CHANGE, contextChangeHandler);
			context.operationManager.addOperation( operation );
			context.operationManager.addEventListener(OperationManagerEvent.CHANGE, contextChangeHandler);
			
			gizmo.updateRollOvers(context.pickingManager.activeEntities);
			
			storeInitialValues(false)
		}
		
		////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////
		
		private function mouseDownHandler( event:MouseEvent3DEx ):void
		{
			if ( event.altKey || event.ctrlKey ) return;
			
			dragPlaneNormal = null;
			
			var overEntity:Entity = gizmo.getClosestActiveEntity(event.entities);
			if ( !overEntity ) return;
			
			//dragPlanePos = context.detailedMouse3DManager.getCollisionPoint(overEntity);
			dragPlanePos = event.scenePosition;
			if ( !dragPlanePos ) return;
			
			
			dragPlanePos = overEntity.sceneTransform.transformVector(dragPlanePos);
			dragPlaneNormal = dragPlanePos.subtract(gizmo.position);
			dragPlaneNormal.normalize();
			
			switch ( overEntity )
			{
				case gizmo.wheelX :
					rotateMode = X;
					dragPlaneUp = dragPlaneNormal.crossProduct(gizmo.rightVector);
					dragPlaneUp.normalize();
					break;
				case gizmo.wheelY :
					rotateMode = Y;
					dragPlaneUp = dragPlaneNormal.crossProduct(gizmo.upVector);
					dragPlaneUp.normalize();
					break;
				case gizmo.wheelZ :
					rotateMode = Z;
					dragPlaneUp = dragPlaneNormal.crossProduct(gizmo.forwardVector);
					dragPlaneUp.normalize();
					break;
				case gizmo.globe :
					rotateMode = SCREEN;
					dragPlaneUp = dragPlaneNormal.crossProduct(gizmo.forwardVector);
					dragPlaneUp.normalize();
					break;
					
			}
			
			event.stopImmediatePropagation();
			beginDrag();
		}
		
		private function mouseMoveStageHandler( event:MouseEvent ):void
		{
			if ( isDragging )
			{
				updateDrag();
			}
		}
		
		private function mouseUpStageHandler( event:MouseEvent ):void
		{
			if ( isDragging )
			{
				endDrag();
			}
		}
		
		private function mouseOverHandler( event:MouseEvent3DEx ):void
		{
			if ( isDragging ) return;
			gizmo.updateRollOvers( context.pickingManager.activeEntities );
		}
		
		private function mouseOutHandler( event:MouseEvent3DEx ):void
		{
			if ( isDragging ) return;
			gizmo.updateRollOvers( context.pickingManager.activeEntities );
		}
	}
}