// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.tools
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.CubicBezier;
	import cadet2D.geom.QuadraticBezier;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor2D.events.PickingManagerEvent;
	
	import cadetEditor2DS.ui.overlays.BezierCurveToolOverlay;
	
	import core.app.operations.AddItemOperation;
	import core.app.operations.AddToVectorOperation;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.core.contexts.IContext;
	import core.appEx.events.OperationManagerEvent;
	import core.events.ArrayCollectionEvent;
	
	public class BezierCurveTool extends CadetEditorTool2D
	{
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, BezierCurveTool, "Bezier Curve Tool", CadetEditorIcons.PathTool );
		}
		
		private var curve			:BezierCurve;
		private var transform		:Transform2D;
		
		private var previousSegment	:CubicBezier;
		private var currentSegment	:CubicBezier;
		private var nextSegment		:CubicBezier;
		
		private var mouseDownX		:Number;
		private var mouseDownY		:Number;
		private var mouseDX			:Number;
		private var mouseDY			:Number;
		
		private var controlOffsetX	:Number;
		private var controlOffsetY	:Number;
		
		
		private var overlay			:BezierCurveToolOverlay;
		
		private var mode					:int = -1;
		private static const NEW_CURVE		:int = 0;
		private static const NEW_SEGMENT	:int = 1;
		private static const DRAG_START		:int = 2;
		private static const DRAG_CP1		:int = 3;
		private static const DRAG_CP2		:int = 4;
		private static const DRAG_END		:int = 5;
		
		public function BezierCurveTool()
		{
			
		}
		
		override public function init(context:IContext):void
		{
			super.init(context);
			
			overlay = new BezierCurveToolOverlay(this);
		}
				
		override public function enable():void
		{
			super.enable();
						
			//view.addOverlay(overlay);
			var renderer2D:Renderer2D = Renderer2D(view.renderer);
			if (renderer2D)	renderer2D.addOverlay(overlay);
			
			context.selection.addEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			context.operationManager.addEventListener(OperationManagerEvent.CHANGE, operationManagerChangeHandler);
			
			updateFromSelection();
		}
		
		override public function disable():void
		{
			super.disable();
			
			endInteraction();
			
			curve = null;
			transform = null;
			
			context.selection.removeEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			context.operationManager.removeEventListener(OperationManagerEvent.CHANGE, operationManagerChangeHandler);
			
			overlay.curve = null;
			overlay.transform2D = null;
			
			//view.removeOverlay(overlay);
			var renderer2D:Renderer2D = Renderer2D(view.renderer);
			if (renderer2D)	renderer2D.removeOverlay(overlay);
		}
		
		private function selectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			updateFromSelection();
		}
		
		private var supressOperationManagerChangeHandler:Boolean = false;
		private function operationManagerChangeHandler(event:OperationManagerEvent):void
		{
			if ( supressOperationManagerChangeHandler ) return;
			endInteraction();
		}
		
		private function updateFromSelection():void
		{
			curve = null;
			transform = null;
			
			var selectedItems:Array = context.selection.source;
			if ( selectedItems.length != 0 )
			{
				var selectedItem:IComponent = selectedItems[0];
				
				var container:IComponentContainer;
				if ( selectedItem is IComponentContainer )
				{
					container = IComponentContainer(selectedItem);
				}
				else
				{
					container = selectedItem.parentComponent;
				}
				
				curve = ComponentUtil.getChildOfType( container, BezierCurve );
				transform = ComponentUtil.getChildOfType( container, Transform2D );
			}
			
			if ( !transform || !curve )
			{
				transform = null;
				curve = null;
			}
			
			overlay.curve = curve;
			overlay.transform2D = transform;
		}
		
		private function endInteraction():void
		{
			if ( mode == -1 ) return;
			mode = -1;
			currentSegment = null;
			nextSegment = null;
			previousSegment = null;
		}
		
		override protected function onMouseDownContainer(event:PickingManagerEvent):void
		{	
			var localPos:Point;
			
			// First segment
			if ( !curve )
			{
				initNewCurve();
				localPos = worldToLocal( getSnappedWorldMouse() );
				mouseDownX = localPos.x;
				mouseDownY = localPos.y;
				mouseDX = 0;
				mouseDY = 0;
				return;
			}
			
			if ( determineDragMode() )
			{
				localPos = worldToLocal( getSnappedWorldMouse() );
				mouseDownX = localPos.x;
				mouseDownY = localPos.y;
				mouseDX = 0;
				mouseDY = 0;
				initDragMode();
				return;
			}
			
			// Clicked background - create new segment
			initNewSegment();
			localPos = worldToLocal( getSnappedWorldMouse() );
			mouseDownX = localPos.x;
			mouseDownY = localPos.y;
			mouseDX = 0;
			mouseDY = 0;
		}
		
		private function initNewCurve():void
		{
			mode = NEW_CURVE;
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "New curve";
			
			var entity:ComponentContainer = new ComponentContainer();
			entity.name = ComponentUtil.getUniqueName("Curve", context.scene);
			
			curve = new BezierCurve();
			transform = new Transform2D();
			entity.children.addItem(curve);
			entity.children.addItem(new GeometrySkin());
			entity.children.addItem( transform );
			
			operation.addOperation( new AddItemOperation( entity, context.scene.children ) );
			operation.addOperation( new ChangePropertyOperation( context.selection, "source", [entity] ) );
			
			overlay.curve = curve;
			overlay.transform2D = transform;
			
			supressOperationManagerChangeHandler = true;
			context.operationManager.addOperation(operation);
			supressOperationManagerChangeHandler = false;
		}
		
		private function initNewSegment():void
		{
			mode = NEW_SEGMENT;
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Add segment";
			
			var localPos:Point = worldToLocal( getSnappedWorldMouse() );
			
			
			currentSegment = new CubicBezier();
			
			if ( curve.segments.length == 0 )
			{
				currentSegment.startX = mouseDownX;
				currentSegment.startY = mouseDownY;
				currentSegment.controlAX = currentSegment.startX + mouseDX;
				currentSegment.controlAY = currentSegment.startY + mouseDY;
				currentSegment.endX = localPos.x;
				currentSegment.endY = localPos.y;
				currentSegment.controlBX = localPos.x;
				currentSegment.controlBY = localPos.y;
			}
			else
			{
				previousSegment = new CubicBezier();
				previousSegment.segmentA = curve.segments[curve.segments.length-2];
				previousSegment.segmentB = curve.segments[curve.segments.length-1];
				
				currentSegment.startX = previousSegment.endX;
				currentSegment.startY = previousSegment.endY;
				var dx:Number = previousSegment.endX - previousSegment.controlBX;
				var dy:Number = previousSegment.endY - previousSegment.controlBY;
				currentSegment.controlAX = currentSegment.startX + dx;
				currentSegment.controlAY= currentSegment.startY + dy;
				currentSegment.endX = localPos.x;
				currentSegment.endY = localPos.y;
				currentSegment.controlBX = localPos.x;
				currentSegment.controlBY = localPos.y;
			}
			
			
			
//			operation.addOperation(new AddToArrayOperation(currentSegment.segmentA, curve.segments, -1, curve, "segments" ));
//			operation.addOperation(new AddToArrayOperation(currentSegment.segmentB, curve.segments, -1, curve, "segments" ));
			operation.addOperation(new AddToVectorOperation(currentSegment.segmentA, curve.segments, -1, curve, "segments" ));
			operation.addOperation(new AddToVectorOperation(currentSegment.segmentB, curve.segments, -1, curve, "segments" ));
			addChangeOperations(operation);
			
			supressOperationManagerChangeHandler = true;
			context.operationManager.addOperation(operation);
			supressOperationManagerChangeHandler = false;
			
			var segmentIndex:int = curve.segments.indexOf(currentSegment.segmentA);
			if ( segmentIndex < curve.segments.length-2 )
			{
				nextSegment = new CubicBezier();
				nextSegment.segmentA = curve.segments[segmentIndex+1];
				nextSegment.segmentB = curve.segments[segmentIndex+2];
			}
		}
		
		private function initDragMode():void
		{
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Add segment";
			
			var localPos:Point = worldToLocal( getSnappedWorldMouse() );
			
			var segmentIndex:int = curve.segments.indexOf(currentSegment.segmentA);
			if ( segmentIndex < curve.segments.length-2 )
			{
				nextSegment = new CubicBezier();
				nextSegment.segmentA = curve.segments[segmentIndex+2];
				nextSegment.segmentB = curve.segments[segmentIndex+3];
			}
			
			if ( segmentIndex > 0 )
			{
				previousSegment = new CubicBezier();
				previousSegment.segmentA = curve.segments[segmentIndex-2];
				previousSegment.segmentB = curve.segments[segmentIndex-1];
			}
			
			addChangeOperations(operation);
			supressOperationManagerChangeHandler = true;
			context.operationManager.addOperation(operation);
			supressOperationManagerChangeHandler = false;
		}
		
		private function updateNewCurve():void
		{
			
		}
		
		private function updateNewSegment():void
		{
			var dx:Number;
			var dy:Number;
			
			var localPos:Point = worldToLocal( getSnappedWorldMouse() );
			dx = localPos.x - currentSegment.endX;
			dy = localPos.y - currentSegment.endY;
			currentSegment.controlBX = currentSegment.endX - dx;
			currentSegment.controlBY = currentSegment.endY - dy;
			
			validateSegments();
		}
		
		private function updateDragMode():void
		{
			var localPos:Point = worldToLocal( getSnappedWorldMouse() );
			
			
			if ( mode == DRAG_START )
			{
				currentSegment.startX = localPos.x;
				currentSegment.startY = localPos.y;
				
				currentSegment.controlAX = currentSegment.startX + controlOffsetX;
				currentSegment.controlAY = currentSegment.startY + controlOffsetY;
				
			}
			else if ( mode == DRAG_CP1 )
			{
				currentSegment.controlAX = localPos.x;
				currentSegment.controlAY = localPos.y;
			}
			else if ( mode == DRAG_CP2 )
			{
				currentSegment.controlBX = localPos.x;
				currentSegment.controlBY = localPos.y;
			}
			else if ( mode == DRAG_END )
			{
				currentSegment.endX = localPos.x;
				currentSegment.endY = localPos.y;
				
				currentSegment.controlBX = currentSegment.endX - controlOffsetX;
				currentSegment.controlBY = currentSegment.endY - controlOffsetY;
			}
			
			validateSegments();
		}
		
		private function validateSegments():void
		{
			var dx:Number;
			var dy:Number;
			if ( previousSegment )
			{
				previousSegment.endX = currentSegment.startX;
				previousSegment.endY = currentSegment.startY;
				
				// Validate previous CP2
				dx = currentSegment.controlAX - currentSegment.startX;
				dy = currentSegment.controlAY - currentSegment.startY;
				previousSegment.controlBX = previousSegment.endX - dx;
				previousSegment.controlBY = previousSegment.endY - dy;
			}
			
			if ( nextSegment )
			{
				nextSegment.startX = currentSegment.endX;
				nextSegment.startY = currentSegment.endY;
				
				// Validate next CP1
				dx = currentSegment.controlBX - currentSegment.endX;
				dy = currentSegment.controlBY - currentSegment.endY;
				nextSegment.controlAX = nextSegment.startX - dx;
				nextSegment.controlAY = nextSegment.startY - dy;
			}
		}
		
		override protected function onMouseDragContainer(event:PickingManagerEvent):void
		{
			if ( mode == -1 ) return;
			
			var localPos:Point = worldToLocal( getSnappedWorldMouse() );
			mouseDX = localPos.x - mouseDownX;
			mouseDY = localPos.y - mouseDownY;
			switch ( mode )
			{
				case NEW_CURVE :
					updateNewCurve();
					break;
				case NEW_SEGMENT :
					updateNewSegment();
					break;
				case DRAG_CP1 :
					updateDragMode();
					break;
				case DRAG_CP2 :
					updateDragMode();
					break;
				case DRAG_START :
					updateDragMode();
					break;
				case DRAG_END :
					updateDragMode();
					break;
			}
			curve.segments = curve.segments;
		}
		
		//override protected function onMouseUpStage(event:PickingManagerEvent):void
		override protected function onClickBackground(event:PickingManagerEvent):void
		{
			endInteraction();
		}
		
		private function addChangeOperations( operation:UndoableCompoundOperation ):void
		{
			if ( previousSegment )
			{
				addChangeOperation(operation, previousSegment.segmentA);
				addChangeOperation(operation, previousSegment.segmentB);
			}
			if ( currentSegment )
			{
				addChangeOperation(operation, currentSegment.segmentA);
				addChangeOperation(operation, currentSegment.segmentB);
			}
			if ( nextSegment )
			{
				addChangeOperation(operation, nextSegment.segmentA);
				addChangeOperation(operation, nextSegment.segmentB);
			}
			
			operation.addOperation( new ChangePropertyOperation( curve, "segments", curve.segments ) );
		}
		
		private function addChangeOperation( operation:UndoableCompoundOperation, segment:QuadraticBezier ):void
		{
			operation.addOperation( new ChangePropertyOperation( segment, "startX", segment.startX ) );
			operation.addOperation( new ChangePropertyOperation( segment, "startY", segment.startY ) );
			operation.addOperation( new ChangePropertyOperation( segment, "endX", segment.endX ) );
			operation.addOperation( new ChangePropertyOperation( segment, "endY", segment.endY ) );
			operation.addOperation( new ChangePropertyOperation( segment, "controlX", segment.controlX ) );
			operation.addOperation( new ChangePropertyOperation( segment, "controlY", segment.controlY ) );
			
		}
		
		
		private function determineDragMode():Boolean
		{
			var local:Point = worldToLocal( getSnappedWorldMouse() );
			
			var closestDistance:Number = Number.POSITIVE_INFINITY;
			var closestSegment:QuadraticBezier;
			var closestMode:int;
			
			var dx:Number;
			var dy:Number;
			var d:Number;
			
			for ( var i:int = 0; i < curve.segments.length; i++ )
			{
				var segment:QuadraticBezier = curve.segments[i];
				
				if ( i % 2 == 0 )
				{
					dx = segment.startX - local.x;
					dy = segment.startY - local.y;
					d = dx*dx + dy*dy;
					
					if ( d < closestDistance )
					{
						closestDistance = d;
						closestSegment = segment;
						closestMode = DRAG_START;
						
						controlOffsetX = segment.controlX-segment.startX;
						controlOffsetY = segment.controlY-segment.startY;
					}
					
					dx = segment.controlX - local.x;
					dy = segment.controlY - local.y;
					d = dx*dx + dy*dy;
					
					if ( d < closestDistance )
					{
						closestDistance = d;
						closestSegment = segment;
						closestMode = DRAG_CP1;
					}
				}
				else
				{
					dx = segment.controlX - local.x;
					dy = segment.controlY - local.y;
					d = dx*dx + dy*dy;
					
					if ( d < closestDistance )
					{
						closestDistance = d;
						closestSegment = segment;
						closestMode = DRAG_CP2;
					}
					
					dx = segment.endX - local.x;
					dy = segment.endY - local.y;
					d = dx*dx + dy*dy;
					
					if ( d < closestDistance )
					{
						closestDistance = d;
						closestSegment = segment;
						closestMode = DRAG_END;
						
						controlOffsetX = segment.endX - segment.controlX;
						controlOffsetY = segment.endY - segment.controlY;
					}
				}
			}
			
			
			
			if ( closestDistance > 20*20 )
			{
				mode = -1;
				return false;
			}
			
			mode = closestMode;
			
			var index:int = curve.segments.indexOf(closestSegment);
			if ( index % 2 == 0 )
			{
				currentSegment = new CubicBezier();
				currentSegment.segmentA = curve.segments[index];
				currentSegment.segmentB = curve.segments[index+1];
			}
			else
			{
				currentSegment = new CubicBezier();
				currentSegment = new CubicBezier();
				currentSegment.segmentA = curve.segments[index-1];
				currentSegment.segmentB = curve.segments[index];
			}
			return true
		}
		
		
		private function worldToLocal( pt:Point ):Point
		{
			var m:Matrix = transform.matrix.clone();
			m.invert();
			return m.transformPoint(pt);
		}
	}
}