package
{
	import flash.display.Sprite;
	
	import cadet.assets.CadetEngineIcons;
	import cadet.core.ComponentContainer;
	import cadet.entities.ComponentFactory;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.connections.Pin;
	import cadet2D.components.geom.BoundingSphere;
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.geom.RectangleGeometry;
	import cadet2D.components.geom.TerrainGeometry;
	import cadet2D.components.geom.TriangleGeometry;
	import cadet2D.components.skins.ConnectionSkin;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.skins.PinSkin;
	import cadet2D.components.skins.SpringSkin;
	import cadet2D.components.skins.TerrainSkin;
	
	import cadetEditor2DS.tools.BezierCurveTool;
	import cadetEditor2DS.tools.CircleTool;
	import cadetEditor2DS.tools.PolygonTool;
	import cadetEditor2DS.tools.RectangleTool;
	import cadetEditor2DS.tools.TriangleTool;
	
	import core.app.CoreApp;
	import core.app.managers.ResourceManager;
	
	public class CadetEditor_Ext_2DS_Geom extends Sprite
	{
		public function CadetEditor_Ext_2DS_Geom()
		{
			var resourceManager:ResourceManager = CoreApp.resourceManager;		
			
	// Geometry
			resourceManager.addResource( new ComponentFactory( RectangleGeometry, 			"Rectangle", 					"Geometry", 	CadetEngineIcons.Geometry, 	ComponentContainer, 	1 ) );
			resourceManager.addResource( new ComponentFactory( TriangleGeometry, 			"Triangle", 					"Geometry", 	CadetEngineIcons.Geometry, 	ComponentContainer, 	1 ) );
			resourceManager.addResource( new ComponentFactory( CircleGeometry, 				"Circle", 						"Geometry", 	CadetEngineIcons.Geometry, 	ComponentContainer, 	1 ) );
			resourceManager.addResource( new ComponentFactory( PolygonGeometry, 			"Polygon", 						"Geometry", 	CadetEngineIcons.Geometry, 	ComponentContainer, 	1 ) );
			resourceManager.addResource( new ComponentFactory( CompoundGeometry, 			"Compound Geometry", 			"Geometry", 	CadetEngineIcons.Geometry, 	ComponentContainer, 	1 ) );
			resourceManager.addResource( new ComponentFactory( BoundingSphere, 				"Bounding Sphere", 				"Geometry", 	CadetEngineIcons.Geometry, 	null, 		1 ) );
			
			// Graphics Skins
			resourceManager.addResource( new ComponentFactory( GeometrySkin, 				"Geometry Skin", 				"Display", 		CadetEngineIcons.Skin, 		ComponentContainer, 		1 ) );
//			resourceManager.addResource( new ComponentFactory( GeometryDebugSkin, 			"Geometry Debug Skin", 			"Skins", 		CadetEngineIcons.Skin, 		ComponentContainer, 		1 ) );
//			resourceManager.addResource( new ComponentFactory( FractalPolygonSkin, 			"Fractal Polygon Skin", 		"Skins", 		CadetEngineIcons.Skin, 		ComponentContainer, 		1 ) );
			resourceManager.addResource( new ComponentFactory( ConnectionSkin, 				"Connection Skin", 				"Display", 		CadetEngineIcons.Skin, 		ComponentContainer, 		1 ) );
			resourceManager.addResource( new ComponentFactory( SpringSkin, 					"Spring Skin", 					"Display", 		CadetEngineIcons.Skin, 		ComponentContainer, 		1 ) );
			resourceManager.addResource( new ComponentFactory( PinSkin, 					"Pin Skin", 					"Display", 		CadetEngineIcons.Skin, 		ComponentContainer, 		1 ) );			
			
			resourceManager.addResource( new ComponentFactory( Pin, 						"Pin", 							"Behaviours",	CadetEngineIcons.Behaviour,	ComponentContainer,			1 ) );
			resourceManager.addResource( new ComponentFactory( Connection, 					"Connection",					"Behaviours",	CadetEngineIcons.Behaviour,	ComponentContainer,			1 ) );
			
			// Specific implementation: doesn't belong here.
			resourceManager.addResource( new ComponentFactory( TerrainGeometry, 			"Terrain Geometry", 			"Geometry", 	CadetEngineIcons.Geometry, 	ComponentContainer, 	1 ) );
			resourceManager.addResource( new ComponentFactory( TerrainSkin,					"Terrain Skin",					"Display",		CadetEngineIcons.Skin,		ComponentContainer,			1 ) );
			
			////			
			
			// Geom Tools
			resourceManager.addResource( RectangleTool.getFactory() );
			resourceManager.addResource( TriangleTool.getFactory() );
			resourceManager.addResource( CircleTool.getFactory() );
			resourceManager.addResource( PolygonTool.getFactory() );
			resourceManager.addResource( BezierCurveTool.getFactory() );
		}
	}
}