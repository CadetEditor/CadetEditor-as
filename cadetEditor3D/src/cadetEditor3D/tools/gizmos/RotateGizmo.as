// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools.gizmos
{
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	
	import mx.effects.Rotate;
	
	public class RotateGizmo extends GizmoBase
	{
		[Embed(source="RotateAxisX.png")]
		public static var RotateAxisX	:Class;
		[Embed(source="RotateAxisY.png")]
		public static var RotateAxisY	:Class;
		[Embed(source="RotateAxisZ.png")]
		public static var RotateAxisZ	:Class;
		[Embed(source="RotateAxisHighlighted.png")]
		public static var RotateAxisHighlighted	:Class;
		
		private var redMaterial		:TextureMaterial;
		private var greenMaterial	:TextureMaterial;
		private var blueMaterial	:TextureMaterial;
		private var yellowMaterial	:TextureMaterial;
		
		public var globe			:Mesh;
		public var wheelX			:Mesh;
		public var wheelY			:Mesh;
		public var wheelZ			:Mesh;
		
		private var interactiveMeshes	:Vector.<Mesh>;
		private var materials			:Vector.<MaterialBase>;
		private var highlightMaterials	:Vector.<MaterialBase>;
		
		public function RotateGizmo()
		{
			redMaterial = new TextureMaterial( new BitmapTexture( new RotateAxisX().bitmapData ), true, true, false );
			redMaterial.alphaBlending = true;
			greenMaterial = new TextureMaterial( new BitmapTexture( new RotateAxisY().bitmapData ), true, true, false );
			greenMaterial.alphaBlending = true;
			blueMaterial = new TextureMaterial( new BitmapTexture( new RotateAxisZ().bitmapData ), true, true, false );
			blueMaterial.alphaBlending = true;
			yellowMaterial = new TextureMaterial( new BitmapTexture( new RotateAxisHighlighted().bitmapData ), true, true, false );
			yellowMaterial.alphaBlending = true;
			
			
			var globeMaterial:DefaultMaterialBase = new ColorMaterial(0xFFFFFF,0);
			var whiteBMP:BitmapData = new BitmapData(8,8,false,0xFFFFFF);
			var whiteCubeMap:BitmapCubeTexture = new BitmapCubeTexture( whiteBMP, whiteBMP, whiteBMP, whiteBMP, whiteBMP, whiteBMP );
			var envMapMethod:FresnelEnvMapMethod = new FresnelEnvMapMethod( whiteCubeMap );
			envMapMethod.fresnelPower = 4;
			globeMaterial.addMethod( EffectMethodBase(envMapMethod) );
			globeMaterial.depthCompareMode = Context3DCompareMode.ALWAYS;
			
			var globeGeom:SphereGeometry = new SphereGeometry(80, 32, 28);
			globe = new Mesh( globeGeom, globeMaterial);
			addChild(globe);
			
			var wheelGeom:CylinderGeometry = new CylinderGeometry(80, 80, 24, 32, 1, false, false);
			
			wheelX = new Mesh( wheelGeom, redMaterial );
			wheelX.rotationZ = 90;
			addChild(wheelX);
			
			wheelY = new Mesh( wheelGeom, greenMaterial );
			addChild(wheelY);
			
			wheelZ = new Mesh( wheelGeom, blueMaterial );
			wheelZ.rotationZ = 90;
			wheelZ.rotationX = 90;
			addChild(wheelZ);
			
			interactiveMeshes = Vector.<Mesh>( [wheelX, wheelY, wheelZ, globe] );
			materials = Vector.<MaterialBase>( [redMaterial, greenMaterial, blueMaterial, globeMaterial] );
			highlightMaterials = Vector.<MaterialBase>( [ yellowMaterial, yellowMaterial, yellowMaterial, globeMaterial ] );
			
			for each ( var interactiveMesh:Mesh in interactiveMeshes )
			{
				interactiveMesh.mouseEnabled = true;
				//interactiveMesh.mouseHitMethod = MouseHitMethod.MESH_CLOSEST_HIT;
				interactiveMesh.pickingCollider = PickingColliderType.AUTO_BEST_HIT;
			}
			
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
		
		//TODO: group select needs to be reintroduced
		override public function getClosestActiveEntity( entities:Vector.<Entity> ):Entity
		{
			entities = entities.filter( filterFunc );
			if ( entities.length == 0 )
			{
				return null;
			}
			
			var closestEntity:Entity = entities[0];
			if ( entities.length == 1 ) return closestEntity;
			
			if ( closestEntity == globe )
			{
				return entities[1];
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