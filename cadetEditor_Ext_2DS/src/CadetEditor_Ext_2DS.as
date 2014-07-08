// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package 
{
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	
	import cadet.assets.CadetEngineIcons;
	import cadet.core.ComponentContainer;
	import cadet.core.ICadetScene;
	import cadet.entities.ComponentFactory;
	
	import cadet2D.components.behaviours.MouseFollowBehaviour;
	import cadet2D.components.materials.StandardMaterialComponent;
	import cadet2D.components.particles.PDParticleSystemComponent;
	import cadet2D.components.processes.InputProcess2D;
	import cadet2D.components.processes.TrackCamera2DProcess;
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.shaders.fragment.TextureFragmentShaderComponent;
	import cadet2D.components.shaders.vertex.AnimateUVVertexShaderComponent;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.entities.CadetEditorCommands;
	
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
	import cadetEditor2D.entities.CadetEditorCommands2D;
	import cadetEditor2D.tools.PanTool;
	
	import cadetEditor2DS.commandHandlers.PreviewAnimationCommandHandler;
	import cadetEditor2DS.commandHandlers.ZoomExtentsCommandHandler;
	import cadetEditor2DS.contexts.CadetContext2D;
	import cadetEditor2DS.contexts.CadetEditorContext2D;
	import cadetEditor2DS.contexts.OutlinePanelContext2D;
	import cadetEditor2DS.tools.SelectionTool;
	
	import core.app.CoreApp;
	import core.app.managers.ResourceManager;
	import core.app.resources.FactoryResource;
	import core.appEx.entities.KeyModifier;
	import core.appEx.managers.SettingsManager;
	import core.appEx.resources.FileType;
	import core.appEx.resources.KeyBinding;
	import core.editor.CoreEditor;
	import core.editor.core.IGlobalViewContainer;
	import core.editor.icons.CoreEditorIcons;
	import core.editor.resources.ActionFactory;
	import core.editor.resources.EditorFactory;
	
	public class CadetEditor_Ext_2DS extends Sprite
	{
		public function CadetEditor_Ext_2DS()
		{
			var resourceManager:ResourceManager = CoreApp.resourceManager;			
			
			// Processes
			resourceManager.addResource( new ComponentFactory( InputProcess2D,				"Input Process", 				"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( WorldBounds2D, 				"World Bounds 2D", 				"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( TrackCamera2DProcess, 		"Track Camera", 				"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( Renderer2D, 					"2D Renderer", 					"Processes", 	CadetEngineIcons.Renderer, 		ICadetScene, 	1 ) );
			resourceManager.addResource( new ComponentFactory( PDParticleSystemComponent,	"Particle System",				"Processes",	CadetEngineIcons.Process ) );
			
			// Transforms
			resourceManager.addResource( new ComponentFactory( Transform2D, 				"2D Transform", 				null, 			CadetEngineIcons.Transform, 	null, 			1 ) );
			
			// Skins
			resourceManager.addResource( new ComponentFactory( ImageSkin, 					"Image Skin", 					"Display", 		CadetEngineIcons.Skin ) );
			resourceManager.addResource( new ComponentFactory( MovieClipSkin, 				"MovieClip Skin", 				"Display", 		CadetEngineIcons.Skin ) );			
			
			// Textures
			resourceManager.addResource( new ComponentFactory( TextureComponent,			"Texture",						"Display",		CadetEngineIcons.Texture ) );
			resourceManager.addResource( new ComponentFactory( TextureAtlasComponent,		"TextureAtlas",					"Display",		CadetEngineIcons.Texture) );
			
			// Behaviours - Core
			resourceManager.addResource( new ComponentFactory( MouseFollowBehaviour,		"Mouse Follow",					"Behaviours",	CadetEngineIcons.Behaviour, ComponentContainer,		1 ) );
			
			// Materials
			resourceManager.addResource( new ComponentFactory( StandardMaterialComponent,	"StandardMaterialComponent",	"Display",	CadetEngineIcons.Component ) );
			
			// Shaders
			resourceManager.addResource( new ComponentFactory( AnimateUVVertexShaderComponent, "AnimateUVVertexShaderComponent",	"Display",	CadetEngineIcons.Component ) );
			resourceManager.addResource( new ComponentFactory( TextureFragmentShaderComponent, "TextureFragmentShaderComponent",	"Display", CadetEngineIcons.Component ) );
			
			////			
			
			// Cadet Viewer
			resourceManager.addResource( new EditorFactory( CadetContext2D, "Cadet Viewer", "cdt", CadetEditorIcons.Cadet ) );
			
			// Global actions
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.COMBINE, "Combine", "", "Modify/geometry" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.COLLAPSE_TRANSFORM, "Collapse Transform", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.CENTER_ORIGIN, "Center Origin", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.CENTER_ORIGIN_CENTROID, "Center Origin Centroid", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.MAKE_CONVEX, "Make Convex", "", "Modify/transform" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.EDIT_COMPONENT_PROPERTIES, "Properties", "", "Modify/properties" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.IMPORT_TEMPLATE, "Import Template", "", "File/template" ) );
			
			// CadetEditorView Actions
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands2D.PREVIEW_ANIMATION, "Preview Animation", "view", "", CadetEditorIcons.Animation ) );
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.ZOOM_EXTENTS, "Zoom extents", "view", "", CoreEditorIcons.Zoom ) );
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.ADD_COMPONENT, "Add Component...", "modify", "", CadetEditorIcons.NewComponent ) );
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.BUILD_AND_RUN, "Test Scene", "build", "", CadetEditorIcons.Run ) );
			
			// Visual contexts
			resourceManager.addResource( new FactoryResource( OutlinePanelContext2D, "Outline", CadetEditorIcons.Outline ) );
			resourceManager.addResource( new FactoryResource( InfoPanelContext, "Info", CadetEditorIcons.Info ) );

			// File Types
			resourceManager.addResource( new FileType( "Cadet2D Editor Scene", "cdt2d", CadetEditorIcons.CadetEditor ) );
			resourceManager.addResource( new FileType( "Cadet2D Scene", "c2d", CadetEditorIcons.Cadet ) );
			
			// Editors
			resourceManager.addResource( new EditorFactory( CadetEditorContext2D, "Cadet2D Editor", "cdt2d", CadetEditorIcons.CadetEditor ) );
			
			// Tools
			resourceManager.addResource( SelectionTool.getFactory() );
			resourceManager.addResource( PanTool.getFactory() );
			//resourceManager.addResource( TransformTool.getFactory() );
			
			// Controllers
			resourceManager.addResource( new FactoryResource( DefaultControlBar2DController, "Default Control Bar" ) );
			//resourceManager.addResource( new FactoryResource( PhysicsControlBarController, "Physics Control Bar" ) );
			
			// Command handlers
			resourceManager.addResource( ZoomInCommandHandler.getFactory() );
			resourceManager.addResource( ZoomOutCommandHandler.getFactory() );
			resourceManager.addResource( CollapseTransformCommandHandler.getFactory() );
			resourceManager.addResource( CenterOriginCommandHandler.getFactory() );
			resourceManager.addResource( CenterOriginCentroidCommandHandler.getFactory() );
			resourceManager.addResource( MakeConvexCommandHandler.getFactory() );
			resourceManager.addResource( ZoomExtentsCommandHandler.getFactory() );
			resourceManager.addResource( PreviewAnimationCommandHandler.getFactory() );
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
			
			// Settings
			var settingsManager:SettingsManager = CoreEditor.settingsManager;
			//settingsManager.setBoolean( "cadetEditor.contexts.OutlinePanelContext.visible", true, true );
			settingsManager.setBoolean( "cadetEditor2DS.contexts.OutlinePanelContext2D.visible", true, true );
			settingsManager.setBoolean( "core.editor.contexts.PropertiesPanelContext.visible", true, true );
		}
	}
}
