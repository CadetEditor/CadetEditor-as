package
{
	import flash.display.Sprite;
	
	import cadet.components.behaviours.VehicleUserControlBehaviour;
	import cadet.core.ICadetScene;
	
	import cadet2D.components.behaviours.BezierCurveFootprintBehaviour;
	import cadet2D.components.behaviours.GeometryFootprintBehaviour;
	import cadet2D.components.behaviours.MouseFollowBehaviour;
	import cadet2D.components.behaviours.ParallaxBehaviour;
	import cadet2D.components.behaviours.SimpleFootprintBehaviour;
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.BoundingSphere;
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.geom.TerrainGeometry;
	import cadet2D.components.geom.TriangleGeometry;
	import cadet2D.components.processes.CollisionDetectionProcess;
	import cadet2D.components.processes.FootprintManagerProcess;
	import cadet2D.components.processes.TrackCamera2DProcess;
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.ConnectionSkin;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.skins.SpringSkin;
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	
	import cadet.assets.CadetEngineIcons;
	import cadet.entities.ComponentFactory;
	
	import flox.app.FloxApp;
	import flox.app.managers.ResourceManager;
	
	public class CadetEditor_Ext_2DS extends Sprite
	{
		public function CadetEditor_Ext_2DS()
		{
			var resourceManager:ResourceManager = FloxApp.resourceManager;	
			
			// Core Component
			resourceManager.addResource( new ComponentFactory( Entity, "Entity" ) );
			
			// Processes
			resourceManager.addResource( new ComponentFactory( WorldBounds2D, 				"World Bounds 2D", 				"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
//			resourceManager.addResource( new ComponentFactory( PhysicsProcess, 				"Physics", 						"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( FootprintManagerProcess, 	"Footprint Manager", 			"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( TrackCamera2DProcess, 		"Track Camera", 				"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( CollisionDetectionProcess, 	"Collision Detection", 			"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( Renderer2D, 					"2D Renderer", 					"Processes", 	CadetEngineIcons.Renderer, 		ICadetScene, 	1 ) );
			
			// Transforms
			resourceManager.addResource( new ComponentFactory( Transform2D, 				"2D Transform", 				null, 			CadetEngineIcons.Transform, 	null, 			1 ) );
			
			// Skins
			resourceManager.addResource( new ComponentFactory( GeometrySkin, 				"Geometry Skin", 				"Skins", 		CadetEngineIcons.Skin, 		Entity, 		1 ) );
//			resourceManager.addResource( new ComponentFactory( GeometryDebugSkin, 			"Geometry Debug Skin", 			"Skins", 		CadetEngineIcons.Skin, 		Entity, 		1 ) );
//			resourceManager.addResource( new ComponentFactory( FractalPolygonSkin, 			"Fractal Polygon Skin", 		"Skins", 		CadetEngineIcons.Skin, 		Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( ImageSkin, 					"Image Skin", 					"Skins", 		CadetEngineIcons.Skin, 		Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( MovieClipSkin, 				"MovieClip Skin", 				"Skins", 		CadetEngineIcons.Skin, 		Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( ConnectionSkin, 				"Connection Skin", 				"Skins", 		CadetEngineIcons.Skin, 		Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( SpringSkin, 					"Spring Skin", 					"Skins", 		CadetEngineIcons.Skin, 		Entity, 		1 ) );
//			resourceManager.addResource( new ComponentFactory( ScrollingBackgroundSkin, 	"Scrolling Background Skin", 	"Skins", 		CadetEngineIcons.Skin, 		null, 			1 ) );
//			resourceManager.addResource( new ComponentFactory( FootprintManagerDebugSkin, 	"Footprint Manager Debug Skin", "Skins", 		CadetEngineIcons.Skin, 		null, 			1 ) );
//			resourceManager.addResource( new ComponentFactory( WorldBoundsDebugSkin, 		"World Bounds Debug Skin", 		"Skins",		CadetEngineIcons.Skin,		null,			1 ) );
			
			// Textures
			resourceManager.addResource( new ComponentFactory( TextureComponent,			"Texture",						"Textures",		CadetEngineIcons.Texture ) );
			resourceManager.addResource( new ComponentFactory( TextureAtlasComponent,		"TextureAtlas",					"Textures",		CadetEngineIcons.Texture) );
			
			// Behaviours - Core
			resourceManager.addResource( new ComponentFactory( MouseFollowBehaviour,		"Mouse Follow",					"Behaviours",	CadetEngineIcons.Behaviour, Entity,		1 ) );
			resourceManager.addResource( new ComponentFactory( ParallaxBehaviour,			"Parallax",						"Behaviours",	CadetEngineIcons.Behaviour, Entity,		1 ) );
			
			resourceManager.addResource( new ComponentFactory( VehicleUserControlBehaviour, "Vehicle User Control", 		"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 	1 ) );
			
			// Footprints
			resourceManager.addResource( new ComponentFactory( SimpleFootprintBehaviour, 	"Footprint Simple", 			"Behaviours", 	CadetEngineIcons.Behaviour,	null, 		1 ) );
			resourceManager.addResource( new ComponentFactory( GeometryFootprintBehaviour, 	"Footprint Geometry", 			"Behaviours", 	CadetEngineIcons.Behaviour,	null, 		1 ) );
			resourceManager.addResource( new ComponentFactory( BezierCurveFootprintBehaviour, "Footprint Bezier", 			"Behaviours", 	CadetEngineIcons.Behaviour,	null, 		1 ) );
			
			// Geometry
			resourceManager.addResource( new ComponentFactory( RectangleGeometry, 			"Rectangle", 					"Geometry", 	CadetEngineIcons.Geometry, 	Entity, 	1 ) );
			resourceManager.addResource( new ComponentFactory( TriangleGeometry, 			"Triangle", 					"Geometry", 	CadetEngineIcons.Geometry, 	Entity, 	1 ) );
			resourceManager.addResource( new ComponentFactory( CircleGeometry, 				"Circle", 						"Geometry", 	CadetEngineIcons.Geometry, 	Entity, 	1 ) );
			resourceManager.addResource( new ComponentFactory( PolygonGeometry, 			"Polygon", 						"Geometry", 	CadetEngineIcons.Geometry, 	Entity, 	1 ) );
			resourceManager.addResource( new ComponentFactory( CompoundGeometry, 			"Compound Geometry", 			"Geometry", 	CadetEngineIcons.Geometry, 	Entity, 	1 ) );
			resourceManager.addResource( new ComponentFactory( TerrainGeometry, 			"Terrain Geometry", 			"Geometry", 	CadetEngineIcons.Geometry, 	Entity, 	1 ) );
			resourceManager.addResource( new ComponentFactory( BoundingSphere, 				"Bounding Sphere", 				"Geometry", 	CadetEngineIcons.Geometry, 	null, 		1 ) );
			
		}
	}
}