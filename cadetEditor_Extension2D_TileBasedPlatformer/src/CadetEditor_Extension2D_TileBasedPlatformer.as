package
{
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	
	import cadet.components.behaviours.EntityUserControlBehaviour;
	import cadet.core.ICadetScene;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.transforms.Transform2D;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.entities.ComponentFactory;
	
	import cadetEditor2D.commandHandlers.EditSnapSettingsCommandHandler;
	import cadetEditor2D.commandHandlers.NudgeCommandHandler;
	import cadetEditor2D.commandHandlers.ZoomInCommandHandler;
	import cadetEditor2D.commandHandlers.ZoomOutCommandHandler;
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.contexts.InfoPanelContext;
	import cadetEditor2D.controllers.DefaultControlBar2DController;
	import cadetEditor2D.tools.PanTool;
	
	import cadetEditor2DS.commandHandlers.ZoomExtentsCommandHandler;
	import cadetEditor2DS.contexts.CadetEditorContext2D;
	import cadetEditor2DS.tools.SelectionTool;
	
	import flox.app.FloxApp;
	import flox.app.entities.KeyModifier;
	import flox.app.managers.ResourceManager;
	import flox.app.managers.SettingsManager;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.FileType;
	import flox.app.resources.KeyBinding;
	import flox.editor.FloxEditor;
	import flox.editor.core.IGlobalViewContainer;
	import flox.editor.icons.FloxEditorIcons;
	import flox.editor.resources.ActionFactory;
	import flox.editor.resources.EditorFactory;
	
	import platformer.components.behaviours.TileBehaviour;
	import platformer.components.entities.ProtagonistEntity;
	import platformer.components.processes.GridProcess;
	import platformer.tools.BrushTool;
	
	public class CadetEditor_Extension2D_TileBasedPlatformer extends Sprite
	{
		public function CadetEditor_Extension2D_TileBasedPlatformer()
		{
			var resourceManager:ResourceManager = FloxApp.resourceManager;

			// Global actions
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
			resourceManager.addResource( BrushTool.getFactory() );
			
			// Controllers
			resourceManager.addResource( new FactoryResource( DefaultControlBar2DController, "Default Control Bar" ) );
			
			// Command handlers
			resourceManager.addResource( ZoomInCommandHandler.getFactory() );
			resourceManager.addResource( ZoomOutCommandHandler.getFactory() );
			resourceManager.addResource( ZoomExtentsCommandHandler.getFactory() );
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
			//resourceManager.addResource( new ComponentFactory( TrackCamera2DProcess, 		"Track Camera", 				"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			//resourceManager.addResource( new ComponentFactory( CollisionDetectionProcess, 	"Collision Detection", 			"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( Renderer2D, 					"2D Renderer", 					"Processes", 	CadetEditorIcons.Renderer, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( GridProcess, 				"Grid Process", 				"Processes", 	CadetEditorIcons.Process, 		ICadetScene, 	1, null, CadetEditorContext2D ) );
			
			// Transforms
			resourceManager.addResource( new ComponentFactory( Transform2D, 				"2D Transform", 				null, 			CadetEditorIcons.Transform, 	null, 			1, null, CadetEditorContext2D ) );
			
			// Skins
			resourceManager.addResource( new ComponentFactory( ImageSkin, 					"Image Skin", 					"Skins", 		CadetEditorIcons.Skin, 			Entity, 		1, null, CadetEditorContext2D ) );
				
			// Behaviours
			resourceManager.addResource( new ComponentFactory( TileBehaviour, 				"Tile Behaviour", 				"Behaviours", 	CadetEditorIcons.Behaviour, 	Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( ProtagonistEntity, 			"Protagonist Entity", 			"Behaviours", 	CadetEditorIcons.Behaviour,		Entity, 		1, null, CadetEditorContext2D ) );
			resourceManager.addResource( new ComponentFactory( EntityUserControlBehaviour, 	"Entity User Control", 			"Behaviours", 	CadetEditorIcons.Behaviour,		Entity, 		1, null, CadetEditorContext2D ) );
			
			// Geometry
			
			// Settings
			var settingsManager:SettingsManager = FloxEditor.settingsManager;
			settingsManager.setBoolean( "cadetEditor.contexts.OutlinePanelContext.visible", true, true );
			settingsManager.setBoolean( "flox.editor.contexts.PropertiesPanelContext.visible", true, true );			
		}
	}
}