// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools.gizmos
{
	import away3d.core.base.Geometry;
	import away3d.core.base.SubMesh;
	import away3d.core.raycast.MouseHitMethod;
	import away3d.debug.Trident;
	import away3d.debug.data.TridentLines;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.LineSegment;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.data.Segment;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import away3d.tools.commands.Merge;
	
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class TranslateGizmo extends GizmoBase
	{
		[Embed(source="TranslatePlaneXY.png")]
		public static var TranslatePlaneXY	:Class;
		[Embed(source="TranslatePlaneZY.png")]
		public static var TranslatePlaneZY	:Class;
		[Embed(source="TranslatePlaneXZ.png")]
		public static var TranslatePlaneXZ	:Class;
		[Embed(source="TranslatePlaneHighlighted.png")]
		public static var TranslatePlaneHighlighted	:Class;
		
		public var armX			:Mesh;
		public var armY			:Mesh;
		public var armZ			:Mesh;
		
		public var planeXY		:Mesh;
		public var planeZY		:Mesh;
		public var planeXZ		:Mesh;
		
		private var redMaterial		:ColorMaterial;
		private var greenMaterial	:ColorMaterial;
		private var blueMaterial	:ColorMaterial;
		private var planeXYMaterial	:TextureMaterial;
		private var planeZYMaterial	:TextureMaterial;
		private var planeXZMaterial	:TextureMaterial;
		private var armHighlightMaterial:ColorMaterial;
		private var planeHighlightMaterial:TextureMaterial;
		
		private var interactiveMeshes	:Vector.<Mesh>;
		private var materials			:Vector.<MaterialBase>;
		private var highlightMaterials	:Vector.<MaterialBase>;
		
		public function TranslateGizmo()
		{
			redMaterial = new ColorMaterial( 0xFF0000, 1 );
			greenMaterial = new ColorMaterial( 0x00FF00, 1 );
			blueMaterial = new ColorMaterial( 0x0000FF, 1 );
			armHighlightMaterial = new ColorMaterial( 0xFFFF00, 1 );
				
			planeXYMaterial = new TextureMaterial(new BitmapTexture( new TranslatePlaneXY().bitmapData ), true, false, false);
			planeXYMaterial.alphaBlending = true;
			planeXYMaterial.bothSides = true;
			
			planeZYMaterial = new TextureMaterial(new BitmapTexture( new TranslatePlaneZY().bitmapData ), true, false, false);
			planeZYMaterial.alphaBlending = true;
			planeZYMaterial.bothSides = true;
			
			planeXZMaterial = new TextureMaterial(new BitmapTexture( new TranslatePlaneXZ().bitmapData ), true, false, false);
			planeXZMaterial.alphaBlending = true;
			planeXZMaterial.bothSides = true;
			
			planeHighlightMaterial = new TextureMaterial(new BitmapTexture( new TranslatePlaneHighlighted().bitmapData ), true, false, false);
			planeHighlightMaterial.alphaBlending = true;
			planeHighlightMaterial.bothSides = true;
			
			var armLineGeom:CylinderGeometry = new CylinderGeometry( 1, 1, 100, 3, 1, false, false, true, true );
			var armHeadGeom:ConeGeometry = new ConeGeometry( 8, 20, 6 );
			var armLineMesh:Mesh = new Mesh( armLineGeom, greenMaterial );
			armLineMesh.y = armLineGeom.height * 0.5;
			var armHeadMesh:Mesh = new Mesh( armHeadGeom, greenMaterial );
			armHeadMesh.y = armLineGeom.height;
			
			var merge:Merge = new Merge(false,true);
			var armMesh:Mesh = merge.applyToMeshes( new Mesh(), Vector.<Mesh>( [armLineMesh, armHeadMesh] ) );
			var armGeom:Geometry = armMesh.geometry;
			
			armX = new Mesh( armGeom, redMaterial );
			armX.rotationZ = -90;
			armX.x = 15;
			addChild(armX);
			
			armY = new Mesh( armGeom, greenMaterial );
			armY.y = 15;
			addChild(armY);
			
			armZ = new Mesh( armGeom, blueMaterial );
			armZ.rotationX = 90;
			armZ.z = 15;
			addChild(armZ);
			
			var planeGeom:PlaneGeometry = new PlaneGeometry(30,30);
			
			planeXY = new Mesh(planeGeom, planeXYMaterial);
			planeXY.x = 15;
			planeXY.y = 15;
			planeXY.rotationX = -90;
			addChild(planeXY);
			
			planeZY = new Mesh(planeGeom, planeZYMaterial);
			planeZY.z = 15;
			planeZY.y = 15;
			planeZY.rotationY = -90;
			planeZY.rotationX = -90;
			addChild(planeZY);
			
			planeXZ = new Mesh(planeGeom, planeXZMaterial);
			planeXZ.x = 15;
			planeXZ.z = 15;
			addChild(planeXZ);
			
			interactiveMeshes = Vector.<Mesh>( [armX, armY, armZ, planeXY, planeXZ, planeZY] );
			materials = Vector.<MaterialBase>( [redMaterial, greenMaterial, blueMaterial, planeXYMaterial, planeXZMaterial, planeZYMaterial] );
			highlightMaterials = Vector.<MaterialBase>( [ armHighlightMaterial, armHighlightMaterial, armHighlightMaterial, planeHighlightMaterial, planeHighlightMaterial, planeHighlightMaterial ] );
		
			for each ( var interactiveMesh:Mesh in interactiveMeshes )
			{
				interactiveMesh.mouseEnabled = true;
				interactiveMesh.mouseHitMethod = MouseHitMethod.MESH_ANY_HIT;
			}
			planeXY.mouseHitMethod = planeZY.mouseHitMethod = planeXZ.mouseHitMethod = MouseHitMethod.BOUNDS_ONLY;
			
			armX.mouseHitMethod = armY.mouseHitMethod = armZ.mouseHitMethod = MouseHitMethod.BOUNDS_ONLY;
			
			for each ( var material:MaterialBase in materials )
			{
				material.depthCompareMode = Context3DCompareMode.ALWAYS;
			}
			
			for each ( material in highlightMaterials )
			{
				material.depthCompareMode = Context3DCompareMode.ALWAYS;
			}
		}
		
		private function filterFunc( item:Entity, index:int, array:Vector.<Entity> ):Boolean
		{
			return interactiveMeshes.indexOf(item) != -1;
		}
		
		override public function getClosestActiveEntity( entities:Vector.<Entity> ):Entity
		{
			entities = entities.filter( filterFunc );
			if ( entities.length == 0 )
			{
				return null;
			}
			
			// This code will prioritise a plane over an arm.
			var closestEntity:Entity = entities[0];
			if ( closestEntity == armX || closestEntity == armY || closestEntity == armZ )
			{
				for ( var i:int = 1; i < entities.length; i++ )
				{
					var otherEntity:Entity = entities[i];
					if ( otherEntity == planeXY || otherEntity ==  planeXZ || otherEntity == planeZY )
					{
						closestEntity = otherEntity;
						break;
					}
				}
			}
			
			
			return closestEntity;
		}
		
		override public function updateRollOvers( entities:Vector.<Entity> ):Boolean
		{
			var overEntity:Entity = getClosestActiveEntity(entities);
			for ( var i:int = 0; i < interactiveMeshes.length; i++ )
			{
				var mesh:Mesh = interactiveMeshes[i];
				if ( mesh == overEntity )
				{
					mesh.material = highlightMaterials[i];
				}
				else
				{
					mesh.material = materials[i];
				}
			}
			
			return overEntity != null;
		}
	}
}