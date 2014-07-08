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
	import cadetEditor.contexts.OutlinePanelContext;
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
	
	import core.app.CoreApp;
	import core.app.managers.ResourceManager;
	import core.app.resources.ExternalResourceParserFactory;
	import core.app.resources.FactoryResource;
	import core.appEx.resources.FileType;
	import core.editor.CoreEditor;
	import core.editor.core.IGlobalViewContainer;
	import core.editor.resources.ActionFactory;
	import core.editor.resources.EditorFactory;
	
	public class CadetEditor_Ext_3D_Main extends Sprite
	{
		public function CadetEditor_Ext_3D_Main()
		{	
			var resourceManager:ResourceManager = CoreApp.resourceManager;
			
			
			// Entities =======================================	
			// Cameras
			resourceManager.addResource( new ComponentFactory( CameraComponent, "Camera", "Display", CadetEngine3DIcons.Camera ) );
			// Debug
			resourceManager.addResource( new ComponentFactory( TridentComponent, "Trident", "Display", CadetEngine3DIcons.Mesh ) );
			// Entities
			resourceManager.addResource( new ComponentFactory( MeshComponent, "Mesh", "Display", CadetEngine3DIcons.Mesh ) );
			resourceManager.addResource( new ComponentFactory( ObjectContainer3DComponent, "ObjectContainer3D", "Display", CadetEngine3DIcons.Mesh ) );
			resourceManager.addResource( new ComponentFactory( SkyBoxComponent, "SkyBox", "Display", CadetEngine3DIcons.Mesh ) );
			resourceManager.addResource( new ComponentFactory( Sprite3DComponent, "Sprite3D", "Display", CadetEngine3DIcons.Mesh ) );
			
			// Geometries =====================================
//			resourceManager.addResource( new ComponentFactory( HeightmapGeometryComponent, "HeightmapGeometry", "Geometry", CadetEngine3DIcons.Geometry ) );
			resourceManager.addResource( new ComponentFactory( PlaneGeometryComponent, "PlaneGeometry", "Geometry", CadetEngine3DIcons.Geometry ) );
			resourceManager.addResource( new ComponentFactory( SphereGeometryComponent, "SphereGeometry", "Geometry", CadetEngine3DIcons.Geometry ) );
			resourceManager.addResource( new ComponentFactory( CubeGeometryComponent, "CubeGeometry", "Geometry", CadetEngine3DIcons.Geometry ) );			
			
			// Lights =========================================
			resourceManager.addResource( new ComponentFactory( DirectionalLightComponent, "Directional Light", "Display", CadetEngine3DIcons.DirectionalLight ) );
			resourceManager.addResource( new ComponentFactory( PointLightComponent, "Point Light", "Display", CadetEngine3DIcons.PointLight ) );
			
			// Materials ======================================
			resourceManager.addResource( new ComponentFactory( ColorMaterialComponent, "Color Material", "Display", CadetEngine3DIcons.Material ) );
			resourceManager.addResource( new ComponentFactory( SkyBoxMaterialComponent, "SkyBox Material", "Display", CadetEngine3DIcons.Material ) );
			resourceManager.addResource( new ComponentFactory( TextureMaterialComponent, "Texture Material", "Display", CadetEngine3DIcons.Material ) );
			
			// Processes ======================================
			resourceManager.addResource( new ComponentFactory( InputProcess3D, "Input Process", "Processes", CadetEngineIcons.Process, ICadetScene, 1 ) );
			resourceManager.addResource( new ComponentFactory( HoverCamProcess, "HoverCamProcess", "Processes", CadetEngineIcons.Process, ICadetScene, 1 ) );
			resourceManager.addResource( new ComponentFactory( Renderer3D, "Away3D Renderer", "Processes", CadetEngine3DIcons.Renderer, ICadetScene, 1 ) );	
			
			// Textures =======================================
			resourceManager.addResource( new ComponentFactory( BitmapTextureComponent, "Bitmap Texture", "Display", CadetEngineIcons.Texture ) );
			resourceManager.addResource( new ComponentFactory( BitmapCubeTextureComponent, "Bitmap Cube Texture", "Display", CadetEngineIcons.Texture ) );
			
			////			
			
			// Cadet Viewer
			resourceManager.addResource( new EditorFactory( CadetContext3D, "Cadet Viewer", "cdt", CadetEditorIcons.Cadet ) );
			
			
			resourceManager.addResource( new ExternalResourceParserFactory( ExternalAway3DResourceParser, "External Away3D Resource Parser", ["obj", "3ds"] ) );
			
			var baseUrl:String = "cadet";

			// Visual Contexts
			resourceManager.addResource( new FactoryResource( OutlinePanelContext, "Outline", CadetEditorIcons.Outline ) );
			
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
			CoreEditor.settingsManager.setBoolean( "cadetEditor.contexts.OutlinePanelContext.visible", true, true );
			CoreEditor.settingsManager.setBoolean( "core.editor.contexts.PropertiesPanelContext.visible", true, true );
		}
	}
}