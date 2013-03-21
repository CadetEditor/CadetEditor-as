// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package 
{
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	
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
	import cadetEditor2D.tools.PanTool;
	
	import cadetEditor2DS.commandHandlers.ZoomExtentsCommandHandler;
	import cadetEditor2DS.contexts.CadetContext2D;
	import cadetEditor2DS.contexts.CadetEditorContext2D;
	import cadetEditor2DS.tools.SelectionTool;
	
	import core.app.CoreApp;
	import core.app.entities.KeyModifier;
	import core.app.managers.ResourceManager;
	import core.app.managers.SettingsManager;
	import core.app.resources.FactoryResource;
	import core.app.resources.FileType;
	import core.app.resources.KeyBinding;
	import core.editor.CoreEditor;
	import core.editor.core.IGlobalViewContainer;
	import core.editor.icons.CoreEditorIcons;
	import core.editor.resources.ActionFactory;
	import core.editor.resources.EditorFactory;
	
	public class CadetEditor_Ext_2DS_Main extends Sprite
	{
		public function CadetEditor_Ext_2DS_Main()
		{
			var resourceManager:ResourceManager = CoreApp.resourceManager;			
			
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
			resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.ZOOM_EXTENTS, "Zoom extents", "view", "", CoreEditorIcons.Zoom ) );
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
			settingsManager.setBoolean( "cadetEditor.contexts.OutlinePanelContext.visible", true, true );
			settingsManager.setBoolean( "core.editor.contexts.PropertiesPanelContext.visible", true, true );
		}
	}
}
