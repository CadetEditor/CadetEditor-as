// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.managers
{
	import cadet.components.geom.IGeometry;
	import cadet.core.ICadetScene;
	import cadet.core.IComponent;
	import cadet.events.ComponentEvent;
	import cadet.events.InvalidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.Vertex;
	import cadet2D.util.VertexUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import core.events.PropertyChangeEvent;

	/**
	 * The SnapManager class implements a variety of snapping methods, allowing tools to use it to perform
	 * useful snapping behaviour without implementing it themselves.
	 * 
	 * These methods are implemented as a manager rather than a static set of methods because this class
	 * monitors a cadet DOM to detect geometric objects being added to the scene. It then computes bounding
	 * boxes for these geometries when needed. This allows the manager to perform a very fast look-up to see what
	 * snap points are available near the given input, rather than using bruteforce.
	 * This may produce a stalls just after a scene has been deserialised, as this is when the CadetEditorContext
	 * will pass the fresh DOM to the snapmanager. At which point it will need to compute bounding boxes for all
	 * the geometries in the scene.
	 * 
	 * If this proves to a problem it should be possible to stretch out this operation into an IAsynchronous operation.
	 * @author Jonathan Pace
	 * 
	 */	
	public class SnapManager2D extends EventDispatcher
	{
		private static const EPSILON:Number = 0.001;
		
		private var scene					:ICadetScene;
		
		private var geometries				:Array;
		private var transforms				:Array;
		private var boundingBoxes			:Array;
		private var centerPoints			:Array;
		private var transformedVertices		:Array;
		private var untransformedVertices	:Array;
		
		private var verticesToIgnore		:Array;
		private var allVerticesToIgnore		:Array;
		private var additionalSnapPoints	:Array;
		
		private var _tolerance			:Number;
		private var toleranceSquared	:Number;
		private var closestPoint		:Object;
		
		private var _gridSizeX				:Number = 10;
		private var _gridSizeY				:Number = 10;
		private var _snapEnabled			:Boolean = true;
		private var _gridSnapEnabled		:Boolean = true;
		private var _vertexSnapEnabled		:Boolean = true;
		private var _centerPointSnapEnabled	:Boolean = true;
		
		public function SnapManager2D()
		{
			geometries = [];
			transforms = [];
			boundingBoxes = [];
			centerPoints = [];
			transformedVertices = [];
			untransformedVertices = [];
			tolerance = 20;
			
			verticesToIgnore = [];
			allVerticesToIgnore = [];
			additionalSnapPoints = [];
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////
		// Public API //////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////
		
		public function dispose():void
		{
			setScene(null);
		}
		
		public function setScene( value:ICadetScene ):void
		{
			if ( scene )
			{
				scene.removeEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
				scene.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
				while ( geometries.length > 0 )
				{
					removeChild(0);
				}
			}
			
			scene = value;
			
			if ( scene )
			{
				scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
				scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
				
				var allGeometries:Vector.<IComponent> = ComponentUtil.getChildrenOfType(scene, IGeometry, true);
				for each ( var geometry:IGeometry in allGeometries )
				{
					var transform:Transform2D = ComponentUtil.getChildOfType(geometry.parentComponent, Transform2D, false);
					if ( !transform ) continue;
					
					geometries.push(geometry);
					transforms.push(transform);
					
					geometry.addEventListener(InvalidationEvent.INVALIDATE, invalidateGeometryHandler);
					transform.addEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
					
					recalculateBoundingBox(geometries.length-1);
				}
			}
		}
		
		
		public function set tolerance( value:Number ):void
		{
			_tolerance = value;
			toleranceSquared = _tolerance*_tolerance;
		}
		public function get tolerance():Number { return _tolerance; }
		
		public function setVerticesToIgnore( value:Array ):void
		{
			value = value == null ? [] : value;
			verticesToIgnore = value;
			
			if ( closestPoint )
			{
				allVerticesToIgnore = verticesToIgnore.concat([closestPoint]);
			}
			else
			{
				allVerticesToIgnore = verticesToIgnore.slice();
			}
		}
		
		public function setAdditionalSnapPoints( value:Array ):void
		{
			value = value == null ? [] : value;
			additionalSnapPoints = value;
		}
		
		public function ignoreClosestPointTo(p:Point):void
		{
			snapPoint(p);
			
			if ( closestPoint )
			{
				allVerticesToIgnore = verticesToIgnore.concat([closestPoint]);
			}
			else
			{
				allVerticesToIgnore = verticesToIgnore.slice();
			}
		}
		
		public function clearIgnore():void
		{
			allVerticesToIgnore = verticesToIgnore.slice();
		}
		
		/**
		 *  
		 * @param p The point you wish to be snapped in world coordinates.
		 * @return The snapped point in world coordinates.
		 * 
		 */		
		public function snapPoint(p:Point):SnapInfo
		{
			var snapInfo:SnapInfo = new SnapInfo();
			var bestSnap:Point = snapInfo.snapPoint = p.clone();
			var closestDistance:Number = Number.POSITIVE_INFINITY;
			closestPoint = null;
			
			var dx:Number;
			var dy:Number;
			
			if ( snapEnabled )
			{
				if ( gridSnapEnabled )
				{
					dx = p.x % gridSizeX;
					if ( dx < 0 ) dx = gridSizeX + dx;
					dy = p.y % gridSizeY;
					if ( dy < 0 ) dy = gridSizeY + dy;
					
					dx = dx > gridSizeX*0.5 ? gridSizeX-dx : -dx;
					dy = dy > gridSizeY*0.5 ? gridSizeY-dy : -dy;
					
					var d:Number = dx*dx + dy*dy;
					
					if ( d < closestDistance && d < toleranceSquared )
					{
						closestDistance = d;
						bestSnap.x = p.x + dx;
						bestSnap.y = p.y + dy;
						snapInfo.snapType = SnapInfo.GRID;
					}
				}
				
				// Snap to vertices on PolygonGeometry's in the scene
				if ( vertexSnapEnabled )
				{
					var indices:Array = getIndicesOverlappingPoint( p );
					for each ( var i:int in indices )
					{
						var geometry:IGeometry = geometries[i];
						if ( geometry is PolygonGeometry == false ) continue;
						
						var untransformedVertices:Array = untransformedVertices != null && untransformedVertices[i] != null ? untransformedVertices[i] : new Array();
						var transformedVertices:Array = transformedVertices != null && transformedVertices[i] != null ? transformedVertices[i] : new Array();
						
						for ( var j:int = 0; j < transformedVertices.length; j++ )
						{
							var untransformedVertex:Vertex = untransformedVertices[j];
							
							// Don't snap to vertices we've been asked to ignore.
							if ( allVerticesToIgnore.indexOf(untransformedVertex) != -1 ) continue;
							
							var transformedVertex:Vertex = transformedVertices[j];
							
							dx = transformedVertex.x - p.x;
							dy = transformedVertex.y - p.y;
							d = dx*dx + dy*dy;
							if ( d < closestDistance && d < toleranceSquared )
							{
								closestPoint = untransformedVertex;
								closestDistance = d;
								bestSnap.x = transformedVertex.x;
								bestSnap.y = transformedVertex.y;
								snapInfo.snapType = SnapInfo.VERTEX;
							}
						}
					}
				}
				
				if ( centerPointSnapEnabled )
				{
					for each ( var centerPoint:Point in centerPoints )
					{
						if (!centerPoint) continue;
						dx = centerPoint.x - p.x;
						dy = centerPoint.y - p.y;
						d = dx*dx + dy*dy;
						if ( d < closestDistance && d < toleranceSquared )
						{
							closestPoint = centerPoint;
							closestDistance = d;
							bestSnap.x = centerPoint.x;
							bestSnap.y = centerPoint.y;
							snapInfo.snapType = SnapInfo.CENTER_POINT;
						}
					}
				}
			
			
				// Snap to any additional snap points provided
				for each ( var vertex:Object in additionalSnapPoints )
				{
					if ( allVerticesToIgnore.indexOf(vertex) != -1 ) 
					{
						trace("ignoring additional snap point : " + vertex);
						continue;
					}
					
					dx = vertex.x - p.x;
					dy = vertex.y - p.y;
					d = dx*dx + dy*dy;
					if ( d < closestDistance && d < toleranceSquared )
					{
						closestPoint = vertex;
						closestDistance = d;
						bestSnap.x = vertex.x;
						bestSnap.y = vertex.y;
						snapInfo.snapType = SnapInfo.OTHER;
					}
				}
			}
			
			
			return snapInfo;
		}
		
		
		/////////////////////////////////////////////////////////////////////////////////////////
		// Private methods //////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Invoked when any component is added to the DOM 
		 * @param event
		 * 
		 */		
		private function componentAddedHandler( event:ComponentEvent ):void
		{
			var geometry:IGeometry;
			var transform:Transform2D;
			
			if ( event.component is IGeometry )
			{
				geometry = IGeometry(event.component);
				if ( geometries.indexOf(geometry) != -1 ) return;
				
				transform = ComponentUtil.getChildOfType(event.component.parentComponent, Transform2D) as Transform2D
				
				if ( !transform ) return;
				
				geometries.push(geometry);
				transforms.push(transform);
			}
			else if ( event.component is Transform2D )
			{
				transform = Transform2D(event.component);
				if ( transforms.indexOf(transform) != -1 ) return;
				
				geometry = ComponentUtil.getChildOfType(transform.parentComponent, IGeometry);
				
				if ( !geometry ) return;
				
				geometries.push(geometry);
				transforms.push(transform);
			}
			// Added component is neither a Geometry or Transform, so we don't care.
			else
			{
				return;
			}
			
			// Register listeners for change events on both the geometry and Transform.
			transform.addEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
			geometry.addEventListener(InvalidationEvent.INVALIDATE, invalidateGeometryHandler);
			recalculateBoundingBox(geometries.length-1);
		}
		
		private function componentRemovedHandler( event:ComponentEvent ):void
		{
			var index:int;
			if ( event.component == IGeometry )
			{
				index = geometries.indexOf(event.component);
				if ( index == -1 ) return;
				removeChild(index);
			}
			else if ( event.component is Transform2D )
			{
				index = transforms.indexOf(event.component);
				if ( index == -1 ) return;
				removeChild(index);
			}
		}
		
		private function invalidateTransformHandler( event:InvalidationEvent ):void
		{
			var transform:Transform2D = Transform2D(event.target);
			var index:int = transforms.indexOf(transform);
			if ( index == -1 )
			{
				throw( new Error( "Snap manager is still listening to events on a Transform2D it no longer has in its internal list" ) );
				transform.removeEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			recalculateBoundingBox(index);
		}
		
		private function invalidateGeometryHandler( event:InvalidationEvent ):void
		{
			var geometry:IGeometry = IGeometry(event.target);
			var index:int = geometries.indexOf(geometry);
			if ( index == -1 )
			{
				throw( new Error( "Snap manager is still listening to events on a IGeometry it no longer has in its internal list" ) );
				geometry.removeEventListener(InvalidationEvent.INVALIDATE, invalidateGeometryHandler);
			}
			recalculateBoundingBox(index);
		}
		
		private function removeChild(index:int):void
		{
			var transform:Transform2D = transforms[index];
			transform.removeEventListener(InvalidationEvent.INVALIDATE, invalidateTransformHandler);
			
			var geometry:IGeometry = geometries[index];
			geometry.removeEventListener(InvalidationEvent.INVALIDATE, invalidateGeometryHandler);
			
			transforms.splice(index,1);
			geometries.splice(index,1);
			boundingBoxes.splice(index, 1);
			centerPoints.splice(index, 1);
			transformedVertices.splice(index,1);
			untransformedVertices.splice(index,1);
		}
		
		private function recalculateBoundingBox(index:int):void
		{
			var boundingBox:Rectangle = boundingBoxes[index];
			var geometry:IGeometry = geometries[index];
			var transform:Transform2D = transforms[index];
			
			transformedVertices[index] = null;
			untransformedVertices[index] = null;
			centerPoints[index] = null;
			
			if ( !boundingBox )
			{
				boundingBox = boundingBoxes[index] = new Rectangle();
			}
			
			if ( geometry is PolygonGeometry )
			{
				var polygon:PolygonGeometry = PolygonGeometry(geometry);
				untransformedVertices[index] = polygon.vertices;
				var transformedVs:Array = VertexUtil.copy(polygon.vertices);
				
				VertexUtil.transform(transformedVs, transform.matrix);
				transformedVertices[index] = transformedVs;
				VertexUtil.getBounds(transformedVs, boundingBox);
			}
			else if ( geometry is CircleGeometry )
			{
				var circle:CircleGeometry = CircleGeometry(geometry);
				var position:Point = new Point( transform.x, transform.y );
				
				boundingBox.x = position.x - circle.radius;
				boundingBox.width = circle.radius * 2;
				boundingBox.y = position.y - circle.radius;
				boundingBox.height = boundingBox.width;
			}
			else
			{
				boundingBoxes[index] = null;
				return;
			}
			
			centerPoints[index] = new Point( boundingBox.x + boundingBox.width * 0.5, boundingBox.y + boundingBox.height * 0.5 );
		}
		
		private function getIndicesOverlappingPoint( p:Point ):Array
		{
			var indices:Array = [];
			var L:int = boundingBoxes.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var boundingBox:Rectangle = boundingBoxes[i];
				if ( !boundingBox ) continue;
				
				if ( p.x > boundingBox.left - _tolerance && p.x < boundingBox.right  + _tolerance &&
					 p.y > boundingBox.top  - _tolerance && p.y < boundingBox.bottom + _tolerance )
				{
					indices.push(i);
				}
			}
			
			return indices;
		}

		public function get gridSizeX():Number
		{
			return _gridSizeX;
		}

		public function set gridSizeX(value:Number):void
		{
			_gridSizeX = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_gridSizeX", null, _gridSizeX ) );
		}

		public function get gridSizeY():Number
		{
			return _gridSizeY;
		}

		public function set gridSizeY(value:Number):void
		{
			_gridSizeY = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_gridSizeY", null, _gridSizeY ) );
		}

		public function get snapEnabled():Boolean
		{
			return _snapEnabled;
		}

		public function set snapEnabled(value:Boolean):void
		{
			_snapEnabled = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_snapEnabled", null, _snapEnabled ) );
		}

		public function get gridSnapEnabled():Boolean
		{
			return _gridSnapEnabled;
		}

		public function set gridSnapEnabled(value:Boolean):void
		{
			_gridSnapEnabled = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_gridSnapEnabled", null, _gridSnapEnabled ) );
		}

		public function get vertexSnapEnabled():Boolean
		{
			return _vertexSnapEnabled;
		}

		public function set vertexSnapEnabled(value:Boolean):void
		{
			_vertexSnapEnabled = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_vertexSnapEnabled", null, _vertexSnapEnabled ) );
		}

		public function get centerPointSnapEnabled():Boolean
		{
			return _centerPointSnapEnabled;
		}

		public function set centerPointSnapEnabled(value:Boolean):void
		{
			_centerPointSnapEnabled = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_centerPointSnapEnabled", null, _centerPointSnapEnabled ) );
		}
	}
}