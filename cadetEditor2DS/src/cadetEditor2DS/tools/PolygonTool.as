// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.tools
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor2D.events.PickingManagerEvent;
	
	import cadetEditor2DS.ui.overlays.PolygonToolOverlay;
	
	import core.app.operations.AddItemOperation;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.core.contexts.IContext;
	import core.appEx.operations.AddToArrayOperation;
	import core.events.ArrayCollectionEvent;
	
	public class PolygonTool extends CadetEditorTool2D
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, PolygonTool, "Polygon Tool", CadetEditorIcons.PolygonTool );
		}
		
		private var polygon		:PolygonGeometry;
		private var transform	:Transform2D;
		
		private var overlay		:PolygonToolOverlay;
		
		private var draggedVertex:Vertex;
		private var storedX		:Number;
		private var storedY		:Number;
		
		public function PolygonTool()
		{
			
		}
		
		override public function init(context:IContext):void
		{
			super.init(context);
			overlay = new PolygonToolOverlay( this );
		}
				
		override public function enable():void
		{
			super.enable();
			
			var renderer2D:Renderer2D = Renderer2D(view.renderer);
			if (renderer2D)	renderer2D.addOverlay(overlay);
			
			context.selection.addEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			updateFromSelection();
		}
		
		override public function disable():void
		{
			super.disable();
			
			polygon = null;
			transform = null;
			
			context.selection.removeEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
						
			overlay.polygon = null;
			overlay.transform2D = null;
			
			var renderer2D:Renderer2D = Renderer2D(view.renderer);
			if (renderer2D)	renderer2D.removeOverlay(overlay);		
		}
		
		private function selectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			updateFromSelection();
		}
		
		private function updateFromSelection():void
		{
			polygon = null;
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
				
				polygon = ComponentUtil.getChildOfType( container, PolygonGeometry );
				transform = ComponentUtil.getChildOfType( container, Transform2D );
			}
						
			overlay.polygon = polygon;
			overlay.transform2D = transform;
		}
		
		override protected function onMouseDownContainer(event:PickingManagerEvent):void
		{
			if ( !polygon )
			{
				createPolygon();
				addVertex(getSnappedWorldMouse());
				return;
			}
			
			
			var vertex:Vertex = getClosestVertex(getSnappedWorldMouse());
			
			if ( !vertex )
			{
				addVertex(getSnappedWorldMouse());
				return;
			}
			else
			{
				draggedVertex = vertex;
				storedX = draggedVertex.x;
				storedY = draggedVertex.y;
				context.snapManager.setVerticesToIgnore([draggedVertex]);
			}
		}
		
		//override protected function onMouseMoveContainer(event:PickingManagerEvent):void
		override protected function onMouseDragContainer(event:PickingManagerEvent):void
		{
			if ( !draggedVertex ) return;
			
			var localPos:Point = worldToLocal( getSnappedWorldMouse() );
			
			draggedVertex.x = localPos.x;
			draggedVertex.y = localPos.y;
			polygon.vertices = polygon.vertices;
		}
	
		//override protected function onMouseUpStage(event:PickingManagerEvent):void
		override protected function onClickBackground(event:PickingManagerEvent):void
		{
			if ( !draggedVertex ) return;
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Move vertex";
			var x:Number = draggedVertex.x;
			var y:Number = draggedVertex.y;
			draggedVertex.x = storedX;
			draggedVertex.y = storedY;
			operation.addOperation( new ChangePropertyOperation( draggedVertex, "x", x ) );
			operation.addOperation( new ChangePropertyOperation( draggedVertex, "y", y ) );
			context.operationManager.addOperation(operation);
			
			draggedVertex = null;
			context.snapManager.setVerticesToIgnore(null);
		}
		
		private function createPolygon():void
		{
			var mouseDownPoint:Point = context.snapManager.snapPoint(view.worldMouse).snapPoint;
			
			var component:IComponentContainer = new Entity();
			component.name = ComponentUtil.getUniqueName("Polygon", context.scene);
			
			polygon = new PolygonGeometry();
			transform = new Transform2D();
			transform.x = mouseDownPoint.x;
			transform.y = mouseDownPoint.y;
			
			component.children.addItem(polygon);
			component.children.addItem(new GeometrySkin());
			component.children.addItem(transform);
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Create Polygon";
			operation.addOperation( new AddItemOperation( component, context.scene.children ) );
			operation.addOperation( new ChangePropertyOperation( context.selection, "source", [component] ) );
			
			context.operationManager.addOperation(operation);
			
			overlay.polygon = polygon;
			overlay.transform2D = transform;
		}
		
		private function addVertex( worldPos:Point ):void
		{
			var localPos:Point = worldToLocal( worldPos );
			var vertex:Vertex = new Vertex(localPos.x,localPos.y);
			var operation:AddToArrayOperation = new AddToArrayOperation( vertex, polygon.vertices, -1, polygon, "vertices" );
			context.operationManager.addOperation(operation);
		}
		
		private function getClosestVertex( pt:Point ):Vertex
		{
			if ( !polygon ) return null;
			
			var x:Number = pt.x;
			var y:Number = pt.y;
			
			var closestDistance:Number = Number.POSITIVE_INFINITY;
			var closestVertex:Vertex;
			
			var L:int = polygon.vertices.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var vertex:Vertex = polygon.vertices[i];
				
				var worldPos:Point = new Point( vertex.x, vertex.y );
				worldPos = transform.matrix.transformPoint(worldPos);
				
				var dx:Number = worldPos.x - x;
				var dy:Number = worldPos.y - y;
				var d:Number = dx*dx + dy*dy;
				
				if ( d < closestDistance )
				{
					closestDistance = d;
					closestVertex = vertex;
				}
			}
			
			if ( closestDistance > 20*20 ) return null;
			
			return closestVertex;
		}
		
		private function worldToLocal( pt:Point ):Point
		{
			if (!transform) return null;
			
			var m:Matrix = transform.matrix.clone();
			m.invert();
			return m.transformPoint(pt);
		}
	}
}