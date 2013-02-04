// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package 
{
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.commandHandlers.AddComponentCommandHandler;
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
	import cadetEditor.entities.ToggleCadetEditorPropertyCommandHandlerFactory;
	import cadetEditor.ui.components.ComponentListItemEditor;
	
	import flox.app.FloxApp;
	import flox.app.entities.KeyModifier;
	import flox.app.managers.ResourceManager;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.KeyBinding;
	import flox.app.resources.PropertyInspectorItemEditorFactory;
	import flox.editor.core.IGlobalViewContainer;
	import flox.editor.entities.Commands;
	import flox.editor.icons.FloxEditorIcons;
	import flox.editor.resources.ActionFactory;
	import flox.editor.resources.EditorFactory;
	
	public class CadetEditor_Ext_Tools extends Sprite
	{
		public function CadetEditor_Ext_Tools()
		{
			var resourceManager:ResourceManager = FloxApp.resourceManager;
			
			// Global actions
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.BUILD, "Build", "", "Project/build" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, 	CadetEditorCommands.BUILD_AND_RUN, "Build And Run", "", "Project/build" ) );
			
			// Outline Context Actions
			resourceManager.addResource( new ActionFactory( OutlinePanelContext, CadetEditorCommands.ADD_COMPONENT, "Add Component...", "modify", "", CadetEditorIcons.NewComponent ) );
			resourceManager.addResource( new ActionFactory( OutlinePanelContext, Commands.DELETE, "Delete Component...", "modify", "", FloxEditorIcons.Bin ) );
			
			resourceManager.addResource( new EditorFactory( CadetContext, "Cadet Viewer", "cdt", CadetEditorIcons.Cadet ) );
			
			
			// Visual Contexts
			resourceManager.addResource( new FactoryResource( OutlinePanelContext, "Outline", CadetEditorIcons.Outline ) );
			
			// Register some additional Property inspector item editors
			resourceManager.addResource( new PropertyInspectorItemEditorFactory( "ComponentList", ComponentListItemEditor, "selectedItem", "components", "propertyName" ) );
			
			// Command handlers
			resourceManager.addResource( AddComponentCommandHandler.getFactory() );
			resourceManager.addResource( DeleteComponentsCommandHandler.getFactory() );
			resourceManager.addResource( CompileCommandHandler.getFactory() );
			resourceManager.addResource( CompileAndRunCommandHandler.getFactory() );
			resourceManager.addResource( CopyComponentCommandHandler.getFactory() );
			resourceManager.addResource( PasteComponentsCommandHandler.getFactory() );
			resourceManager.addResource( ImportTemplateCommandHandler.getFactory() );
			resourceManager.addResource( EditComponentPropertiesCommandHandler.getFactory() );
//			resourceManager.addResource( EditSnapSettingsCommandHandler.getFactory() );
			resourceManager.addResource( new ToggleCadetEditorPropertyCommandHandlerFactory( CadetEditorCommands.TOGGLE_GRID, "showGrid" ) );
			resourceManager.addResource( new ToggleCadetEditorPropertyCommandHandlerFactory( CadetEditorCommands.TOGGLE_SNAP, "snapEnabled" ) );
			
			// Key bindings
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.BUILD_AND_RUN, Keyboard.ENTER, KeyModifier.CTRL ) );
			resourceManager.addResource( new KeyBinding( Commands.SELECT_ALL, 65, KeyModifier.CTRL ) );		// CTRL + A
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.ZOOM_IN, 187, KeyModifier.CTRL ) );		// CTRL + +
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.ZOOM_OUT, 189, KeyModifier.CTRL ) );		// CTRL + -
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.ZOOM_EXTENTS, 90 ) );		// Z
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.TOGGLE_GRID, 71 ) );		// G
//			resourceManager.addResource( new KeyBinding( CadetEditorCommands.TOGGLE_SNAP, 83 ) );		// S
			resourceManager.addResource( new KeyBinding( CadetEditorCommands.ADD_COMPONENT, Keyboard.F9 ) );
		}
	}
}
