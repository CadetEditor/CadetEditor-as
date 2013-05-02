// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.entities.Entity;
	
	import cadet.events.InvalidationEvent;
	
	import cadet3D.components.core.ObjectContainer3DComponent;
	import cadet3D.events.Renderer3DEvent;
	
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.events.DetailedMouse3DEvent;
	import cadetEditor3D.events.MouseEvent3DEx;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.tools.gizmos.GizmoBase;
	import cadetEditor3D.tools.gizmos.ScaleGizmo;
	import cadetEditor3D.utils.Vector3DUtil;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import core.appEx.events.OperationManagerEvent;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.events.ArrayCollectionEvent;
	import core.editor.CoreEditor;

	public class TransformToolBase extends SelectionTool
	{
		protected var isDragging				:Boolean = false;
		protected var dragPlane					:Vector3D;
		protected var dragStartPoint			:Vector3D;
		protected var operationName				:String = "Transform";
		protected var gizmo						:GizmoBase;
		
		protected var entitiesBeingTransformed	:Vector.<ObjectContainer3DComponent>;
		protected var storedEntityTransforms	:Vector.<Matrix3D>;
		
		public function TransformToolBase()
		{
			
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
			entitiesBeingTransformed = new Vector.<ObjectContainer3DComponent>();
			storedEntityTransforms = new Vector.<Matrix3D>();
			
			var averagePos:Vector3D = new Vector3D();
			for each ( var item:* in context.selection )
			{
				var entity:ObjectContainer3DComponent = item as ObjectContainer3DComponent
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
//				throw( new Error( "Already dragging" ) );
				return;
			}
			
			ignoreNextMouseUp = true;
			isDragging = true;
			CoreEditor.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveStageHandler);
			CoreEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
			
			//dragStartPoint = getMousePositionOnPlane(gizmo.position, dragPlane);
			dragStartPoint = Vector3DUtil.getMousePositionOnPlane( gizmo.position, dragPlane, renderer.view3D );
		}		
		
		protected function updateDrag():void
		{
			
		}
		
		protected function endDrag():void
		{
			if ( !isDragging )
			{
//				throw( new Error( "Not dragging" ) );
				return;
			}
			
			isDragging = false;
			CoreEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveStageHandler);
			CoreEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
			
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = operationName;
			for ( var i:int = 0; i < entitiesBeingTransformed.length; i++ )
			{
				var entity:ObjectContainer3DComponent = entitiesBeingTransformed[i];
				operation.addOperation( new ChangePropertyOperation( entity, "transform", entity.transform.clone(), storedEntityTransforms[i].clone() ) );
			}
			
			context.operationManager.addOperation( operation );
			
			gizmo.updateRollOvers(context.pickingManager.activeEntities);
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
		
		private function mouseDownHandler( event:MouseEvent3DEx ):void
		{
			if ( event.altKey || event.ctrlKey ) return;
			
			if ( handleMouseDown(event.entities) == false ) return;
			event.stopImmediatePropagation();
			beginDrag();
		}
		
		private function mouseOverHandler( event:MouseEvent3DEx ):void
		{
			if ( isDragging ) return;
			gizmo.updateRollOvers(context.pickingManager.activeEntities);
		}
		
		private function mouseOutHandler( event:MouseEvent3DEx ):void
		{
			if ( isDragging ) return;
			gizmo.updateRollOvers(context.pickingManager.activeEntities);
		}
	}
}