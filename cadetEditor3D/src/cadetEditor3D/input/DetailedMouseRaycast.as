// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.input
{

	import away3d.core.base.SubMesh;
	import away3d.core.data.RenderableListItem;
	import away3d.core.raycast.MouseHitMethod;
	import away3d.core.raycast.colliders.*;
	import away3d.entities.Entity;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class DetailedMouseRaycast extends ColliderBase
	{
		private var _triangleCollider			:TriangleCollider;
		private var _entityCollisions			:Vector.<Entity>;
		private var _collisionVOForEntityTable	:Dictionary;

		public function DetailedMouseRaycast() 
		{
			_triangleCollider = new TriangleCollider();
			_entityCollisions = new Vector.<Entity>();
			_collisionVOForEntityTable = new Dictionary();
		}

		override public function evaluate():Boolean 
		{
			var item:RenderableListItem = _target as RenderableListItem;
			_entityCollisions = new Vector.<Entity>();
			
			if( !item ) return _collisionExists = false;

			// init
			var t:Number;
			var entity:Entity;
			var i:uint, j:uint;
			var rp:Vector3D, rd:Vector3D;
			var collisionVO:MouseCollisionVO;
			var cameraIsInEntityBounds:Boolean;
			var entityHasBeenChecked:Dictionary = new Dictionary();
			var entityToCollisionVoDictionary:Dictionary = new Dictionary();
			var collisionVOs:Vector.<MouseCollisionVO> = new Vector.<MouseCollisionVO>();
			
			// sweep renderables and collect entities whose bounds are hit by ray
			while( item ) 
			{
				entity = item.renderable.sourceEntity;
				if( entity.visible && entity.mouseEnabled ) 
				{
					if( !entityHasBeenChecked[ entity ] ) 
					{
						// convert ray to object space
						rp = entity.inverseSceneTransform.transformVector( _rayPosition );
						rd = entity.inverseSceneTransform.deltaTransformVector( _rayDirection );
						// check for ray-bounds collision
						t = entity.bounds.intersectsRay( rp, rd );
						cameraIsInEntityBounds = false;
						if( t == -1 ) 
						{ // if there is no collision, check if the ray starts inside the bounding volume
							cameraIsInEntityBounds = entity.bounds.containsPoint( rp );
							if( cameraIsInEntityBounds ) t = 0;
						}
						if( t >= 0 ) 
						{ // collision exists for this renderable's entity bounds
							// store collision VO
							collisionVO = new MouseCollisionVO();
							collisionVO.boundsCollisionT = t;
							collisionVO.boundsCollisionFarT = entity.bounds.rayFarT;
							collisionVO.entity = entity;
							collisionVO.localRayPosition = rp;
							collisionVO.localRayDirection = rd;
							collisionVO.renderableItems.push( item );
							collisionVO.cameraIsInEntityBounds = cameraIsInEntityBounds;
							collisionVO.collidingRenderable = item.renderable;
							entityToCollisionVoDictionary[ entity ] = collisionVO;
							collisionVOs.push( collisionVO );
						}
						entityHasBeenChecked[ entity ] = true; // do not check entities twice
					}
					else 
					{
						// if entity has been checked and a collision was found for it, collect all its renderables
						collisionVO = entityToCollisionVoDictionary[ entity ];
						if( collisionVO ) collisionVO.renderableItems.push( item );
					}
				}
				item = item.next;
			}

			// no bound hits?
			var numBoundHits:uint = collisionVOs.length;
			if( numBoundHits == 0 ) return _collisionExists = false;

			// sort collision vos, closest to furthest
			collisionVOs = collisionVOs.sort( onSmallestT );
			_collisionVOForEntityTable = new Dictionary();
			
			// find nearest collision and perform triangle collision tests where necessary
			var numItems:uint;
			for( i = 0; i < numBoundHits; ++i ) 
			{
				collisionVO = collisionVOs[ i ];
				
				numItems = collisionVO.renderableItems.length;
				if( numItems > 0 ) _triangleCollider.updateRay( collisionVO.localRayPosition, collisionVO.localRayDirection );
				// sweep renderables
				var triHitFound:Boolean = false;
				for( j = 0; j < numItems; ++j ) 
				{
					item = collisionVO.renderableItems[ j ];
					if ( item.renderable.mouseHitMethod == MouseHitMethod.BOUNDS_ONLY )
					{
						collisionVO.isTriangleHit = false;
						_entityCollisions.push( collisionVO.entity );
						_collisionVOForEntityTable[collisionVO.entity] = collisionVO;
					}
					// need triangle collision test?
					else if( collisionVO.cameraIsInEntityBounds
							|| item.renderable.mouseHitMethod == MouseHitMethod.MESH_CLOSEST_HIT
							|| item.renderable.mouseHitMethod == MouseHitMethod.MESH_ANY_HIT ) 
					{
						_triangleCollider.breakOnFirstTriangleHit = item.renderable.mouseHitMethod == MouseHitMethod.MESH_ANY_HIT;
						_triangleCollider.updateTarget(item.renderable as SubMesh);
						if( _triangleCollider.evaluate() ) 
						{ // triangle collision exists?
							collisionVO.finalCollisionT = _triangleCollider.collisionT;
							collisionVO.collidingRenderable = item.renderable;
							collisionVO.collisionUV = _triangleCollider.collisionUV.clone();
							collisionVO.isTriangleHit = true;
							triHitFound = true;
							_entityCollisions.push( collisionVO.entity );
							_collisionVOForEntityTable[collisionVO.entity] = collisionVO;
						}
						// on required tri hit, if there is no triangle hit the collisionVO is not eligible for nearest hit ( its a miss )
					}
					else if( !triHitFound ) 
					{ // on required bounds hit, consider t for nearest hit
						collisionVO.finalCollisionT = collisionVO.boundsCollisionT;
					}
				}
				
			}
			
			return _collisionExists = _entityCollisions.length > 0;
		}
		
		public function get entityCollisions():Vector.<Entity>
		{
			return _entityCollisions;
		}
		
		public function getCollisionPoint( entity:Entity ):Vector3D
		{
			var collisionVO:MouseCollisionVO = _collisionVOForEntityTable[entity];
			if ( collisionVO == null )
			{
				return null;
			}
			
			var point:Vector3D = new Vector3D();
			point.x = collisionVO.localRayPosition.x + collisionVO.finalCollisionT * collisionVO.localRayDirection.x;
			point.y = collisionVO.localRayPosition.y + collisionVO.finalCollisionT * collisionVO.localRayDirection.y;
			point.z = collisionVO.localRayPosition.z + collisionVO.finalCollisionT * collisionVO.localRayDirection.z;
			return point;
		}
		
		public function getCollisionUV( entity:Entity ):Point 
		{
			var collisionVO:MouseCollisionVO = _collisionVOForEntityTable[entity];
			if ( collisionVO == null )
			{
				return null;
			}
			return collisionVO.collisionUV;
		}
		
		/*
		override public function get collisionPoint():Vector3D
		{
			if( !_collisionExists )
				return null;
			
			var point:Vector3D = new Vector3D();
			point.x = _nearestCollisionVO.localRayPosition.x + _nearestCollisionVO.finalCollisionT * _nearestCollisionVO.localRayDirection.x;
			point.y = _nearestCollisionVO.localRayPosition.y + _nearestCollisionVO.finalCollisionT * _nearestCollisionVO.localRayDirection.y;
			point.z = _nearestCollisionVO.localRayPosition.z + _nearestCollisionVO.finalCollisionT * _nearestCollisionVO.localRayDirection.z;
			return point;
		}
		
		public function get collisionUV():Point {
			if( !_collisionExists || !_nearestCollisionVO.isTriangleHit ) return null;
			return _nearestCollisionVO.collisionUV;
		}
		*/
		
		private function onSmallestT( a:MouseCollisionVO, b:MouseCollisionVO ):Number {
			return a.boundsCollisionT < b.boundsCollisionT ? -1 : 1;
		}
	}
}

import away3d.core.base.IRenderable;
import away3d.core.data.RenderableListItem;
import away3d.entities.Entity;

import flash.geom.Point;
import flash.geom.Vector3D;

class MouseCollisionVO
{
	public var boundsCollisionT:Number;
	public var boundsCollisionFarT:Number;
	public var finalCollisionT:Number;
	public var entity:Entity;
	public var collisionUV:Point;
	public var isTriangleHit:Boolean;
	public var localRayPosition:Vector3D;
	public var localRayDirection:Vector3D;
	public var cameraIsInEntityBounds:Boolean;
	public var collidingRenderable:IRenderable;
	public var renderableItems:Vector.<RenderableListItem>;

	public function MouseCollisionVO() {
		renderableItems = new Vector.<RenderableListItem>();
	}
}
