// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Entity;
	import away3d.events.MouseEvent3D;
	//import away3d.tools.utils.Ray;
	
	import cadet.events.InvalidationEvent;
	
	import cadet3D.components.core.Object3DComponent;
	import cadet3D.events.Renderer3DEvent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.events.DetailedMouse3DEvent;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.tools.gizmos.GizmoBase;
	import cadetEditor3D.tools.gizmos.ScaleGizmo;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import flox.core.events.ArrayCollectionEvent;
	
	import flox.editor.FloxEditor;
	import flox.app.events.OperationManagerEvent;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;

	public class TransformToolBase extends SelectionTool
	{
		protected var isDragging				:Boolean = false;
		protected var dragPlane					:Vector3D;
		protected var dragStartPoint			:Vector3D;
		protected var operationName				:String = "Transform";
		protected var gizmo						:GizmoBase;
		
		protected var entitiesBeingTransformed	:Vector.<Object3DComponent>;
		protected var storedEntityTransforms	:Vector.<Matrix3D>;
		
		public function TransformToolBase()
		{
			
		}
		
		override protected function performEnable():void
		{
			super.performEnable();
			
			renderer.addEventListener(Renderer3DEvent.PRE_RENDER, preRenderHandler);
			context.detailedMouse3DManager.addEventListener(DetailedMouse3DEvent.MOUSE_OVER, mouseOverHandler, false, 10);
			context.detailedMouse3DManager.addEventListener(DetailedMouse3DEvent.MOUSE_OUT, mouseOutHandler, false, 10);
			context.detailedMouse3DManager.addEventListener(DetailedMouse3DEvent.MOUSE_DOWN, mouseDownHandler, false, 10);
			
			context.selection.addEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			context.operationManager.addEventListener(OperationManagerEvent.CHANGE, contextChangeHandler);
			updateFromSelection();
		}
		
		override protected function performDisable():void
		{
			super.performDisable();
			
			if ( gizmo.scene )
			{
				renderer.view3D.scene.removeChild(gizmo);
			}
			renderer.removeEventListener(Renderer3DEvent.PRE_RENDER, preRenderHandler);
			context.detailedMouse3DManager.removeEventListener(DetailedMouse3DEvent.MOUSE_OVER, mouseOverHandler);
			context.detailedMouse3DManager.removeEventListener(DetailedMouse3DEvent.MOUSE_OUT, mouseOutHandler);
			context.detailedMouse3DManager.removeEventListener(DetailedMouse3DEvent.MOUSE_DOWN, mouseDownHandler);
			
			context.selection.removeEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			context.operationManager.removeEventListener(OperationManagerEvent.CHANGE, contextChangeHandler);
		}
		
		private function contextChangeHandler( event:OperationManagerEvent ):void
		{
			if ( isDragging )
			{
				endDrag();
			}
			updateFromSelection();
		}
		
		private function selectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			if ( isDragging )
			{
				endDrag();
			}
			updateFromSelection();
		}
		
		protected function updateFromSelection():void
		{
			entitiesBeingTransformed = new Vector.<Object3DComponent>();
			storedEntityTransforms = new Vector.<Matrix3D>();
			
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
			
			if ( gizmo.parent && entitiesBeingTransformed.length == 0 )
			{
				renderer.view3D.scene.removeChild(gizmo);
				return;
			}
			
			if ( entitiesBeingTransformed.length > 0 )
			{
				averagePos.scaleBy( 1/entitiesBeingTransformed.length );
				gizmo.position = averagePos;
				renderer.view3D.scene.addChild(gizmo);
			}
		}
		
		private function preRenderHandler( event:Renderer3DEvent ):void
		{
			// Before rendering each frame, scale the gizmo proportionatly to
			// its distance from the camera.
			// This causes the gizmo to appear the same scale at all distances.
			var d:Vector3D = renderer.view3D.camera.position.subtract(gizmo.position);
			gizmo.scaleX = gizmo.scaleY = gizmo.scaleZ = d.length * 0.001;
		}
		
		protected function beginDrag():void
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
			
			dragStartPoint = getMousePositionOnPlane(gizmo.position, dragPlane);
		}
		
		protected function getMousePositionOnPlane( planePos:Vector3D, planeNormal:Vector3D ):Vector3D
		{
			var rayPosition:Vector3D = renderer.view3D.camera.position;
			var rayDirection:Vector3D = renderer.view3D.unproject( renderer.view3D.mouseX, renderer.view3D.mouseY );
			rayDirection.normalize();
			
			var delta:Vector3D = planePos.subtract(rayPosition);
			var d:Number = delta.dotProduct(planeNormal) / rayDirection.dotProduct(planeNormal);
			rayDirection.scaleBy(d);
			
			return rayPosition.add( rayDirection );
		}
		
		
		
		protected function updateDrag():void
		{
			
		}
		
		protected function endDrag():void
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
			operation.label = operationName;
			for ( var i:int = 0; i < entitiesBeingTransformed.length; i++ )
			{
				var entity:Object3DComponent = entitiesBeingTransformed[i];
				operation.addOperation( new ChangePropertyOperation( entity, "transform", entity.transform.clone(), storedEntityTransforms[i].clone() ) );
			}
			
			context.operationManager.addOperation( operation );
			
			gizmo.updateRollOvers(context.detailedMouse3DManager.activeEntities);
		}
		
		private function mouseDownHandler( event:DetailedMouse3DEvent ):void
		{
			if ( event.altKey || event.ctrlKey ) return;
			
			if ( handleMouseDown(event.entities) == false ) return;
			event.stopImmediatePropagation();
			beginDrag();
		}
		
		protected function handleMouseDown( entities:Vector.<Entity> ):Boolean
		{
			return false;
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
		
		private function mouseOverHandler( event:DetailedMouse3DEvent ):void
		{
			if ( isDragging ) return;
			gizmo.updateRollOvers( context.detailedMouse3DManager.activeEntities );
		}
		
		private function mouseOutHandler( event:DetailedMouse3DEvent ):void
		{
			if ( isDragging ) return;
			gizmo.updateRollOvers( context.detailedMouse3DManager.activeEntities );
		}
	}
}