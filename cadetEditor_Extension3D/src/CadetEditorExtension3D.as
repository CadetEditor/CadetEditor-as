// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package
{
	import cadet.core.Component;
	import cadet.core.ICadetScene;
	import cadet.core.IComponentContainer;
	
	import cadet3D.components.cameras.CameraComponent;
	import cadet3D.components.core.MeshComponent;
	import cadet3D.components.core.ObjectContainer3DComponent;
	import cadet3D.components.core.Renderer3D;
	import cadet3D.components.core.Sprite3DComponent;
	import cadet3D.components.debug.TridentComponent;
	import cadet3D.components.geom.CubeGeometryComponent;
	import cadet3D.components.geom.GeometryComponent;
	import cadet3D.components.geom.PlaneGeometryComponent;
	import cadet3D.components.geom.SphereGeometryComponent;
	import cadet3D.components.lights.DirectionalLightComponent;
	import cadet3D.components.lights.LightProbeComponent;
	import cadet3D.components.lights.PointLightComponent;
	import cadet3D.components.materials.ColorMaterialComponent;
	import cadet3D.components.materials.SkyBoxMaterialComponent;
	import cadet3D.components.materials.TextureMaterialComponent;
	import cadet3D.components.primitives.SkyBoxComponent;
	import cadet3D.components.processes.HoverCamProcess;
	import cadet3D.components.textures.BitmapCubeTextureComponent;
	import cadet3D.components.textures.BitmapTextureComponent;
	import cadet3D.resources.ExternalAway3DResourceParser;
	
	import cadet3DPhysics.components.behaviours.RigidBodyBehaviour;
	import cadet3DPhysics.components.processes.PhysicsProcess;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.entities.ComponentFactory;
	
	import cadetEditor3D.commandHandlers.ExportToAS3CommandHandler;
	import cadetEditor3D.commandHandlers.ImportCommandHandler;
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.controllers.DefaultControlBar3DController;
	import cadetEditor3D.controllers.PhysicsControlBarController;
	import cadetEditor3D.entities.CadetBuilder3DCommands;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.tools.*;
	
	import flash.display.Sprite;
	
	import flox.app.FloxApp;
	import flox.app.controllers.ExternalResourceController;
	import flox.app.entities.URI;
	import flox.app.managers.ResourceManager;
	import flox.app.resources.ExternalResourceParserFactory;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.FileType;
	import flox.editor.FloxEditor;
	import flox.editor.core.FloxEditorEnvironment;
	import flox.editor.core.IGlobalViewContainer;
	import flox.editor.resources.ActionFactory;
	import flox.editor.resources.EditorFactory;
	
	public class CadetEditorExtension3D extends Sprite
	{
		public function CadetEditorExtension3D()
		{
			// Force inclusion of some types
			PlaneGeometryComponent;
			SphereGeometryComponent;
			CubeGeometryComponent;
			
			var resourceManager:ResourceManager = FloxApp.resourceManager;
			
			resourceManager.addResource( new ExternalResourceParserFactory( ExternalAway3DResourceParser, "External Away3D Resource Parser", ["obj", "3ds"] ) );
			
			var baseUrl:String = "cadet";
			
			// Bit of a hack, as we're hard-coding the path to the assets folder.
			// This should be handled as part of loading a project
			if ( FloxEditor.environment == FloxEditorEnvironment.AIR )
			{
				new ExternalResourceController( resourceManager, new URI(baseUrl+".local/assets/"), FloxApp.fileSystemProvider );
			}
			else if ( FloxEditor.environment == FloxEditorEnvironment.BROWSER )
			{
				new ExternalResourceController( resourceManager, new URI(baseUrl+".url/assets/"), FloxApp.fileSystemProvider );
			}
			
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
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, CadetBuilder3DCommands.IMPORT, "Import 3D Resource...", "", "File/import" ) );
			resourceManager.addResource( new ActionFactory( IGlobalViewContainer, CadetEditorCommands.EXPORT, "Export...", "", "File/export" ) );
			
			
			
			///////////////////////////////
			// Cadet Component resources
			///////////////////////////////
			
			// Entities =======================================
			// Behaviours
			resourceManager.addResource( new ComponentFactory( RigidBodyBehaviour, "Rigid Body", "Behaviours", CadetEditorIcons.Behaviour, MeshComponent, 1, null, CadetEditorContext3D ) );	
			// Cameras
			resourceManager.addResource( new ComponentFactory( CameraComponent, "Camera", "Entities", CadetEditor3DIcons.Camera, null, -1, null, CadetEditorContext3D ) );
			// Debug
			resourceManager.addResource( new ComponentFactory( TridentComponent, "Trident", "Entities", CadetEditor3DIcons.Mesh, null, -1, null, CadetEditorContext3D ) );
			// Entities
			resourceManager.addResource( new ComponentFactory( MeshComponent, "Mesh", "Entities", CadetEditor3DIcons.Mesh, null, -1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( ObjectContainer3DComponent, "ObjectContainer3D", "Entities", CadetEditor3DIcons.Mesh, null, -1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( SkyBoxComponent, "SkyBox", "Entities", CadetEditor3DIcons.Mesh, null, -1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( Sprite3DComponent, "Sprite3D", "Entities", CadetEditor3DIcons.Mesh, null, -1, null, CadetEditorContext3D ) );
			
			// Geometries =====================================
//			resourceManager.addResource( new ComponentFactory( HeightmapGeometryComponent, "HeightmapGeometry", "Geometry", CadetBuilderAway3D4Icons.Geometry, null, -1, null, CadetEditorContextAway3D4 ) );
			resourceManager.addResource( new ComponentFactory( PlaneGeometryComponent, "PlaneGeometry", "Geometry", CadetEditor3DIcons.Geometry, null, -1, null, CadetEditorContext3D, false ) );
			resourceManager.addResource( new ComponentFactory( SphereGeometryComponent, "SphereGeometry", "Geometry", CadetEditor3DIcons.Geometry, null, -1, null, CadetEditorContext3D, false ) );
			resourceManager.addResource( new ComponentFactory( CubeGeometryComponent, "CubeGeometry", "Geometry", CadetEditor3DIcons.Geometry, null, -1, null, CadetEditorContext3D, false ) );			
			
			// Lights =========================================
			resourceManager.addResource( new ComponentFactory( DirectionalLightComponent, "Directional Light", "Entities", CadetEditor3DIcons.DirectionalLight, null, -1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( PointLightComponent, "Point Light", "Entities", CadetEditor3DIcons.PointLight, null, -1, null, CadetEditorContext3D ) );
			
			// Materials ======================================
			resourceManager.addResource( new ComponentFactory( ColorMaterialComponent, "Color Material", "Materials", CadetEditor3DIcons.Material, null, -1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( SkyBoxMaterialComponent, "SkyBox Material", "Materials", CadetEditor3DIcons.Material, null, -1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( TextureMaterialComponent, "Texture Material", "Materials", CadetEditor3DIcons.Material, null, -1, null, CadetEditorContext3D ) );
						
			// Processes ======================================
			resourceManager.addResource( new ComponentFactory( HoverCamProcess, "HoverCamProcess", "Processes", CadetEditorIcons.Process, ICadetScene, 1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( Renderer3D, "Away3D Renderer", "Processes", CadetEditor3DIcons.Renderer, ICadetScene, 1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( PhysicsProcess, "Physics Process", "Processes", CadetEditorIcons.Process, ICadetScene, 1, null, CadetEditorContext3D ) );	
			
			// Textures =======================================
			resourceManager.addResource( new ComponentFactory( BitmapTextureComponent, "Bitmap Texture", "Textures", CadetEditor3DIcons.Texture, null, -1, null, CadetEditorContext3D ) );
			resourceManager.addResource( new ComponentFactory( BitmapCubeTextureComponent, "Bitmap Cube Texture", "Textures", CadetEditor3DIcons.Texture, null, -1, null, CadetEditorContext3D ) );
		
			
			// Default settings
			FloxEditor.settingsManager.setBoolean( "cadetEditor.contexts.OutlinePanelContext.visible", true, true );
			FloxEditor.settingsManager.setBoolean( "flox.editor.contexts.PropertiesPanelContext.visible", true, true );
		}
	}
}