// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package
{
	import flash.display.Sprite;
	
	import cadet3D.resources.ExternalAway3DResourceParser;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.entities.CadetEditorCommands;
	
	import cadetEditor3D.commandHandlers.ExportToAS3CommandHandler;
	import cadetEditor3D.commandHandlers.ImportCommandHandler;
	import cadetEditor3D.contexts.CadetContext3D;
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.controllers.PhysicsControlBarController;
	import cadetEditor3D.entities.CadetEditor3DCommands;
	import cadetEditor3D.tools.CameraPanTool;
	import cadetEditor3D.tools.CameraRotateTool;
	import cadetEditor3D.tools.CameraZoomTool;
	import cadetEditor3D.tools.CubePrimitiveTool;
	import cadetEditor3D.tools.PlanePrimitiveTool;
	import cadetEditor3D.tools.RotateTool;
	import cadetEditor3D.tools.ScaleTool;
	import cadetEditor3D.tools.SelectionTool;
	import cadetEditor3D.tools.SpherePrimitiveTool;
	import cadetEditor3D.tools.TranslateTool;
	
	import flox.app.FloxApp;
	import flox.app.managers.ResourceManager;
	import flox.app.resources.ExternalResourceParserFactory;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.FileType;
	import flox.editor.FloxEditor;
	import flox.editor.core.IGlobalViewContainer;
	import flox.editor.resources.ActionFactory;
	import flox.editor.resources.EditorFactory;
	
	public class CadetEditor_Ext_3D_Core extends Sprite
	{
		public function CadetEditor_Ext_3D_Core()
		{	
			var resourceManager:ResourceManager = FloxApp.resourceManager;
			
			// Cadet Viewer
			resourceManager.addResource( new EditorFactory( CadetContext3D, "Cadet Viewer", "cdt", CadetEditorIcons.Cadet ) );
			
			
			resourceManager.addResource( new ExternalResourceParserFactory( ExternalAway3DResourceParser, "External Away3D Resource Parser", ["obj", "3ds"] ) );
			
			var baseUrl:String = "cadet";
			
			// Bit of a hack, as we're hard-coding the path to the assets folder.
			// This should be handled as part of loading a project
/*			if ( FloxEditor.environment == FloxEditorEnvironment.AIR )
			{
				new ExternalResourceController( resourceManager, new URI(baseUrl+".local/assets/"), FloxApp.fileSystemProvider );
			}
			else if ( FloxEditor.environment == FloxEditorEnvironment.BROWSER )
			{
				new ExternalResourceController( resourceManager, new URI(baseUrl+".url/assets/"), FloxApp.fileSystemProvider );
			}*/
			
			// CadetEditorView Actions
			//resourceManager.addResource( new ActionFactory( ICadetEditorContext2D, CadetEditorCommands.ADD_COMPONENT, "Add Component...", "modify", "", CadetEditorIcons.NewComponent ) );
			resourceManager.addResource( new ActionFactory( CadetEditorContext3D, CadetEditorCommands.BUILD_AND_RUN, "Test Scene", "build", "", CadetEditorIcons.Run ) );
			
			
			// File Types
			resourceManager.addResource( new FileType( "Cadet3D Editor Scene", "cdt3d", CadetEditorIcons.CadetEditor ) );
			resourceManager.addResource( new FileType( "Cadet3D Scene", "c3d", CadetEditorIcons.Cadet ) );
			
			// Editors
			resourceManager.addResource( new EditorFactory( CadetEditorContext3D, "Cadet3D Editor", "cdt3d", CadetEditorIcons.CadetEditor ) );		
			
			// Tools
			resourceManager.addResource( SelectionTool.getFactory() );
			resourceManager.addResource( TranslateTool.getFactory() );
			resourceManager.addResource( RotateTool.getFactory() );
			resourceManager.addResource( ScaleTool.getFactory() );
			resourceManager.addResource( CameraRotateTool.getFactory() );
			resourceManager.addResource( CameraPanTool.getFactory() );
			resourceManager.addResource( CameraZoomTool.getFactory() );
			resourceManager.addResource( CubePrimitiveTool.getFactory() );
			resourceManager.addResource( SpherePrimitiveTool.getFactory() );
			resourceManager.addResource( PlanePrimitiveTool.getFactory() );
			
			// Controllers
			//resourceManager.addResource( new FactoryResource( DefaultControlBar3DController, "Default Control Bar" ) );
			resourceManager.addResource( new FactoryResource( PhysicsControlBarController, "Physics Control Bar" ) );
			
			// CommandHandlers
			resourceManager.addResource( ImportCommandHandler.getFactory() );
			resourceManager.addResource( ExportToAS3CommandHandler.getFactory() );
			
			// Actions
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, CadetEditor3DCommands.IMPORT, "Import 3D Resource...", "", "File/import" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, CadetEditorCommands.EXPORT, "Export...", "", "File/export" ) );
			
			// Default settings
			FloxEditor.settingsManager.setBoolean( "cadetEditor.contexts.OutlinePanelContext.visible", true, true );
			FloxEditor.settingsManager.setBoolean( "flox.editor.contexts.PropertiesPanelContext.visible", true, true );
		}
	}
}