// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package 
{
	import cadet.components.behaviours.VehicleUserControlBehaviour;
	import cadet.core.ICadetScene;
	
	import cadet2D.components.behaviours.BezierCurveFootprintBehaviour;
	import cadet2D.components.behaviours.GeometryFootprintBehaviour;
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
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AssetSkin;
	import cadet2D.components.skins.ConnectionSkin;
	import cadet2D.components.skins.GeometrySkin;
	import cadet2D.components.skins.SpringSkin;
	import cadet2D.components.transforms.Transform2D;
	
	import cadet2DBox2D.components.behaviours.DistanceJointBehaviour;
	import cadet2DBox2D.components.behaviours.MotorbikeBehaviour;
	import cadet2DBox2D.components.behaviours.PrismaticJointBehaviour;
	import cadet2DBox2D.components.behaviours.RevoluteJointBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyCollisionDetectBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyMouseDragBehaviour;
	import cadet2DBox2D.components.behaviours.SimpleFootprintBehaviour;
	import cadet2DBox2D.components.behaviours.SimpleVehicleBehaviour;
	import cadet2DBox2D.components.behaviours.SpringBehaviour;
	import cadet2DBox2D.components.behaviours.VehicleBehaviour;
	import cadet2DBox2D.components.processes.PhysicsProcess;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.commandHandlers.CompileAndRunCommandHandler;
	import cadetEditor.commandHandlers.CompileCommandHandler;
	import cadetEditor.commandHandlers.CopyComponentCommandHandler;
	import cadetEditor.commandHandlers.DeleteComponentsCommandHandler;
	import cadetEditor.commandHandlers.EditComponentPropertiesCommandHandler;
	import cadetEditor.commandHandlers.ImportTemplateCommandHandler;
	import cadetEditor.commandHandlers.PasteComponentsCommandHandler;
	import cadetEditor.contexts.CadetContext;
	import cadetEditor.contexts.OutlinePanelContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.entities.ComponentFactory;
	
	import cadetEditor2D.commandHandlers.CenterOriginCentroidCommandHandler;
	import cadetEditor2D.commandHandlers.CenterOriginCommandHandler;
	import cadetEditor2D.commandHandlers.CollapseTransformCommandHandler;
	import cadetEditor2D.commandHandlers.CombineCommandHandler;
	import cadetEditor2D.commandHandlers.EditSnapSettingsCommandHandler;
	import cadetEditor2D.commandHandlers.MakeConvexCommandHandler;
	import cadetEditor2D.commandHandlers.NudgeCommandHandler;
	import cadetEditor2D.commandHandlers.ZoomInCommandHandler;
	import cadetEditor2D.commandHandlers.ZoomOutCommandHandler;
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.contexts.InfoPanelContext;
	import cadetEditor2D.controllers.DefaultControlBar2DController;
	import cadetEditor2D.tools.PanTool;
	
	import cadetEditor2DS.commandHandlers.ZoomExtentsCommandHandler;
	import cadetEditor2DS.contexts.CadetEditorContext2D;
	import cadetEditor2DS.tools.BezierCurveTool;
	import cadetEditor2DS.tools.CircleTool;
	import cadetEditor2DS.tools.PolygonTool;
	import cadetEditor2DS.tools.RectangleTool;
	import cadetEditor2DS.tools.SelectionTool;
	import cadetEditor2DS.tools.TransformTool;
	import cadetEditor2DS.tools.TriangleTool;
	
	import cadetEditor2DSBox2D.controllers.PhysicsControlBarController;
	import cadetEditor2DSBox2D.tools.ConnectionTool;
	import cadetEditor2DSBox2D.tools.PinTool;
	import cadetEditor2DSBox2D.tools.TerrainTool;
	
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	
	import flox.app.FloxApp;
	import flox.app.controllers.ExternalResourceController;
	import flox.app.entities.KeyModifier;
	import flox.app.entities.URI;
	import flox.app.managers.ResourceManager;
	import flox.app.managers.SettingsManager;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.FileType;
	import flox.app.resources.KeyBinding;
	import flox.app.resources.PropertyInspectorItemEditorFactory;
	import flox.editor.FloxEditor;
	import flox.editor.core.FloxEditorEnvironment;
	import flox.editor.core.IGlobalViewContainer;
	import flox.editor.icons.FloxEditorIcons;
	import flox.editor.resources.ActionFactory;
	import flox.editor.resources.EditorFactory;
	
	public class CadetEditorExtension2DS extends Sprite
	{
		public function CadetEditorExtension2DS()
		{
			var resourceManager:ResourceManager = FloxApp.resourceManager;			
			
			// Global actions
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.COMBINE, "Combine", "", "Modify/geometry" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.COLLAPSE_TRANSFORM, "Collapse Transform", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.CENTER_ORIGIN, "Center Origin", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.CENTER_ORIGIN_CENTROID, "Center Origin Centroid", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.MAKE_CONVEX, "Make Convex", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.EDIT_COMPONENT_PROPERTIES, "Properties", "", "Modify/properties" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.IMPORT_TEMPLATE, "Import Template", "", "File/template" ) );
			
			// CadetEditorView Actions
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.ZOOM_EXTENTS, "Zoom extents", "view", "", FloxEditorIcons.Zoom ) );
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.ADD_COMPONENT, "Add Component...", "modify", "", CadetEditorIcons.NewComponent ) );
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.BUILD_AND_RUN, "Test Scene", "build", "", CadetEditorIcons.Run ) );
			
			// Visual contexts
			resourceManager.addResource( new FactoryResource( InfoPanelContext, "Info", CadetEditorIcons.Info ) );
			
			// File Types
			resourceManager.addResource( new FileType( "Cadet2D Editor Scene", "cdt2d", CadetEditorIcons.CadetEditor ) );
			resourceManager.addResource( new FileType( "Cadet2D Scene", "c2d", CadetEditorIcons.Cadet ) );
			
			// Editors
			resourceManager.addResource( new EditorFactory( CadetEditorContext2D, "Cadet2D Editor", "cdt2d", CadetEditorIcons.CadetEditor ) );
			
			// Tools
			resourceManager.addResource( SelectionTool.getFactory() );
			resourceManager.addResource( PanTool.getFactory() );
			resourceManager.addResource( TransformTool.getFactory() );
			resourceManager.addResource( RectangleTool.getFactory() );
			resourceManager.addResource( TriangleTool.getFactory() );
			resourceManager.addResource( CircleTool.getFactory() );
			resourceManager.addResource( PolygonTool.getFactory() );
			resourceManager.addResource( BezierCurveTool.getFactory() );
			resourceManager.addResource( ConnectionTool.getFactory() );
			resourceManager.addResource( PinTool.getFactory() );
			resourceManager.addResource( TerrainTool.getFactory() );
			
			// Controllers
			resourceManager.addResource( new FactoryResource( DefaultControlBar2DController, "Default Control Bar" ) );
			resourceManager.addResource( new FactoryResource( PhysicsControlBarController, "Physics Control Bar" ) );
			
			// Command handlers
			resourceManager.addResource( ZoomInCommandHandler.getFactory() );
			resourceManager.addResource( ZoomOutCommandHandler.getFactory() );
			resourceManager.addResource( CollapseTransformCommandHandler.getFactory() );
			resourceManager.addResource( CenterOriginCommandHandler.getFactory() );
			resourceManager.addResource( CenterOriginCentroidCommandHandler.getFactory() );
			resourceManager.addResource( MakeConvexCommandHandler.getFactory() );
			resourceManager.addResource( ZoomExtentsCommandHandler.getFactory() );
			resourceManager.addResource( CombineCommandHandler.getFactory() );
			resourceManager.addResource( EditSnapSettingsCommandHandler.getFactory() );
			resourceManager.addResource( NudgeCommandHandler.getFactory() );
			
			// Key bindings
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.LEFT ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.RIGHT ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.UP ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.DOWN ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.LEFT, KeyModifier.SHIFT ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.RIGHT, KeyModifier.SHIFT ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.UP, KeyModifier.SHIFT ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.NUDGE, Keyboard.DOWN, KeyModifier.SHIFT ) );
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.TOGGLE_SNAP, 83 ) );		// S
			
			// Core Component
			resourceManager.addResource( new ComponentFactory( Entity, "Entity" ) );
			
			// Processes
			resourceManager.addResource( new ComponentFactory( WorldBounds2D, 				"World Bounds 2D", 				"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( PhysicsProcess, 				"Physics", 						"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( FootprintManagerProcess, 	"Footprint Manager", 			"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
//			resourceManager.addResource( new ComponentFactory( TrackCamera2DProcess, 		"Track Camera", 				"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( CollisionDetectionProcess, 	"Collision Detection", 			"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( Renderer2D, 					"2D Renderer", 					"Processes", 	CadetEditorIcons.Renderer, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			
			// Transforms
			resourceManager.addResource( new ComponentFactory( Transform2D, 				"2D Transform", 				null, 			CadetEditorIcons.Transform, 	null, 			1, null, CadetEditorContext2D ) );
			
			// Skins
			resourceManager.addResource( new ComponentFactory( GeometrySkin, 				"Geometry Skin", 				"Skins", 		CadetEditorIcons.Skin, 		Entity, 		1, null, CadetEditorContext2D ) );
//			resourceManager.addResource( new ComponentFactory( GeometryDebugSkin, 			"Geometry Debug Skin", 			"Skins", 		CadetEditorIcons.Skin, 		Entity, 		1, null, CadetEditorContext2D ) );
//			resourceManager.addResource( new ComponentFactory( FractalPolygonSkin, 			"Fractal Polygon Skin", 		"Skins", 		CadetEditorIcons.Skin, 		Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( AssetSkin, 					"Asset Skin", 					"Skins", 		CadetEditorIcons.Skin, 		Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( ConnectionSkin, 				"Connection Skin", 				"Skins", 		CadetEditorIcons.Skin, 		Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( SpringSkin, 					"Spring Skin", 					"Skins", 		CadetEditorIcons.Skin, 		Entity, 		1, null, CadetEditorContext2D ) );
//			resourceManager.addResource( new ComponentFactory( ScrollingBackgroundSkin, 	"Scrolling Background Skin", 	"Skins", 		CadetEditorIcons.Skin, 		null, 			1, null, CadetEditorContext2D ) );
//			resourceManager.addResource( new ComponentFactory( FootprintManagerDebugSkin, 	"Footprint Manager Debug Skin", "Skins", 		CadetEditorIcons.Skin, 		null, 			1, null, CadetEditorContext2D ) );
//			resourceManager.addResource( new ComponentFactory( WorldBoundsDebugSkin, 		"World Bounds Debug Skin", 		"Skins",		CadetEditorIcons.Skin,			null,			1, null, CadetEditorContext2D ) );
			
			// Behaviours
			resourceManager.addResource( new ComponentFactory( RigidBodyBehaviour, 			"Rigid Body", 					"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( RigidBodyMouseDragBehaviour, "Mouse Drag", 					"Behaviours",	CadetEditorIcons.Behaviour,	Entity,			1, null, CadetEditorContext2D ) );			
			resourceManager.addResource( new ComponentFactory( RigidBodyCollisionDetectBehaviour, "RB Collision Detect", 	"Behaviours",	CadetEditorIcons.Behaviour,	Entity,			1, null, CadetEditorContext2D ) );
			
			resourceManager.addResource( new ComponentFactory( DistanceJointBehaviour, 		"Distance Joint", 				"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( SpringBehaviour, 			"Spring Joint", 						"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( RevoluteJointBehaviour, 		"Revolute Joint", 				"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( PrismaticJointBehaviour, 	"Prismatic Joint", 				"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			
			resourceManager.addResource( new ComponentFactory( SimpleVehicleBehaviour, 		"Simple Vehicle", 				"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( VehicleBehaviour, 			"Vehicle", 						"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( VehicleUserControlBehaviour, "Vehicle User Control", 		"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( MotorbikeBehaviour, 			"Motorbike", 					"Behaviours", 	CadetEditorIcons.Behaviour,	Entity, 		1, null, CadetEditorContext2D ) );
			
			resourceManager.addResource( new ComponentFactory( SimpleFootprintBehaviour, 	"Footprint Simple", 			"Behaviours", 	CadetEditorIcons.Behaviour,	null, 			1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( GeometryFootprintBehaviour, 	"Footprint Geometry", 			"Behaviours", 	CadetEditorIcons.Behaviour,	null, 			1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( BezierCurveFootprintBehaviour, "Footprint Bezier", 			"Behaviours", 	CadetEditorIcons.Behaviour,	null, 			1, null, CadetEditorContext2D ) );
			
			// Geometry
			resourceManager.addResource( new ComponentFactory( RectangleGeometry, 			"Rectangle", 					"Geometry", 	CadetEditorIcons.Geometry, 	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( TriangleGeometry, 			"Triangle", 					"Geometry", 	CadetEditorIcons.Geometry, 	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( CircleGeometry, 				"Circle", 						"Geometry", 	CadetEditorIcons.Geometry, 	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( PolygonGeometry, 			"Polygon", 						"Geometry", 	CadetEditorIcons.Geometry, 	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( CompoundGeometry, 			"Compound Geometry", 			"Geometry", 	CadetEditorIcons.Geometry, 	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( TerrainGeometry, 			"Terrain Geometry", 			"Geometry", 	CadetEditorIcons.Geometry, 	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( BoundingSphere, 				"Bounding Sphere", 				"Geometry", 	CadetEditorIcons.Geometry, 	null, 			1, null, CadetEditorContext2D  ) );
			
			// Settings
			var settingsManager:SettingsManager = FloxEditor.settingsManager;
			settingsManager.setBoolean( "cadetEditor.contexts.OutlinePanelContext.visible", true, true );
			settingsManager.setBoolean( "flox.editor.contexts.PropertiesPanelContext.visible", true, true );
		}
	}
}
