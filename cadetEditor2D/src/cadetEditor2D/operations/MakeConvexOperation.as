// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.operations
{
	import cadet.core.IComponentContainer;
	
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.IGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.util.VertexUtil;
	
	import flox.app.core.operations.IUndoableOperation;

	public class MakeConvexOperation implements IUndoableOperation
	{
		private var polygon		:PolygonGeometry;
		private var childIndex	:int = -1;
		
		private var _result		:IGeometry;
		
		public function MakeConvexOperation( polygon:PolygonGeometry )
		{
			this.polygon = polygon;
		}
		
		public function execute():void
		{
			if ( polygon.parentComponent )
			{
				childIndex = polygon.parentComponent.children.getItemIndex(polygon);
			}
			
			if ( VertexUtil.isConcave(polygon.vertices) == false )
			{
				_result = polygon;
				return;
			}
			
			var compoundGeometry:CompoundGeometry = new CompoundGeometry();
			compoundGeometry.name = polygon.name;
			
			var decomposedVertices:Array = VertexUtil.makeConvex(VertexUtil.copy(polygon.vertices));
			
			for each ( var convexVertices:Array in decomposedVertices )
			{
				var childPolygon:PolygonGeometry = new PolygonGeometry();
				childPolygon.vertices = convexVertices;
				compoundGeometry.children.addItem(childPolygon);
			}
			
			_result = compoundGeometry;
			
			if ( childIndex == -1 ) return;
			
			var parent:IComponentContainer = polygon.parentComponent;
			parent.children.removeItem(polygon);
			parent.children.addItemAt(compoundGeometry, childIndex);
		}
		
		public function undo():void
		{
			if ( !_result ) return;
			
			var parent:IComponentContainer = _result.parentComponent;
			
			if ( childIndex == -1 ) return;
			
			parent.children.removeItem(_result);
			parent.children.addItemAt(polygon, childIndex);
			
			childIndex = -1;
		}
		
		public function getResult():IGeometry { return _result; }
		
		public function get label():String { return "Make convex"; }
		
	}
}