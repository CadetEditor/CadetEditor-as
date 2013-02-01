// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.commandHandlers
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.library.assets.NamedAssetBase;
	import away3d.materials.ColorMaterial;
	
	import cadet.core.ICadetScene;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	
	import cadet3D.components.core.MeshComponent;
	import cadet3D.components.core.ObjectContainer3DComponent;
	import cadet3D.components.geom.GeometryComponent;
	import cadet3D.components.materials.AbstractMaterialComponent;
	import cadet3D.components.materials.ColorMaterialComponent;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.entities.CadetEditor3DCommands;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import flox.app.FloxApp;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.resources.IFactoryResource;
	import flox.app.resources.IResource;
	import flox.app.util.IntrospectionUtil;
	import flox.app.validators.ContextValidator;
	import flox.editor.FloxEditor;
	import flox.editor.operations.SelectResourceOperation;
	import flox.editor.ui.panels.SelectResourcePanel;
	
	public class ImportCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			return new CommandHandlerFactory( CadetEditor3DCommands.IMPORT, ImportCommandHandler, [new ContextValidator(FloxEditor.contextManager, CadetEditorContext3D)] );
		}
		
		private var context		:CadetEditorContext3D;
		
		private var compoundOperation	:UndoableCompoundOperation;
		private var componentDictionary	:Dictionary;
		private var panel		:SelectResourcePanel;
		private var defaultMaterialComponent	:AbstractMaterialComponent;
		
		private var resourceIDPrefix	:String;
		
		public function ImportCommandHandler()
		{
		}
		
		public function execute(parameters:Object):void
		{
			context = FloxEditor.contextManager.getLatestContextOfType(CadetEditorContext3D);
			
			var allowedTypes:Array = [ObjectContainer3D];
			var dissallowedTypes:Array = [Mesh];
			var operation:SelectResourceOperation = new SelectResourceOperation(FloxApp.resourceManager.getAllResources(), null, allowedTypes, dissallowedTypes);
			operation.addEventListener(Event.COMPLETE, selectResourceCompleteHandler);
			operation.execute();
		}
		
		private function selectResourceCompleteHandler( event:Event ):void
		{
			var operation:SelectResourceOperation = SelectResourceOperation(event.target);
			
			var resource:IResource = operation.selectedResource;
			
			
			resourceIDPrefix = resource.getID();
			
			var container3D:ObjectContainer3D;
			if ( resource is ObjectContainer3D )
			{
				container3D = ObjectContainer3D(resource);
			}
			else
			{
				container3D = ObjectContainer3D(IFactoryResource(resource).getInstance());
			}
			
			
			compoundOperation = new UndoableCompoundOperation();
			compoundOperation.label = "Import";
			
			componentDictionary = new Dictionary();
			parseAway3DAsset(container3D, context.scene, context.scene);
			componentDictionary = null;
			
			context.operationManager.addOperation( compoundOperation );
		}
		
		private function parseAway3DAsset( asset:NamedAssetBase, parent:IComponentContainer, scene:ICadetScene ):IComponent
		{
			var assetType:Class = IntrospectionUtil.getType(asset);
			var i:int;
			
			switch (assetType)
			{
				case Mesh :
					
					var mesh:Mesh = Mesh(asset);
					var meshComponent:MeshComponent = new MeshComponent();
					meshComponent.name = mesh.name;
					meshComponent.transform = mesh.transform;
					meshComponent.geometryComponent = parseAway3DAsset(mesh.geometry, parent, scene) as GeometryComponent;
					
					// If there's no material on the mesh, assign it a default rey color, so at least we can see something.
					if ( mesh.material == null )
					{
						if ( defaultMaterialComponent == null )
						{
							defaultMaterialComponent = new ColorMaterialComponent();
							compoundOperation.addOperation( new AddItemOperation( defaultMaterialComponent, parent.children ) );
						}
						meshComponent.materialComponent = defaultMaterialComponent;
					}
					else
					{
						meshComponent.materialComponent = parseAway3DAsset(mesh.material, parent, scene) as AbstractMaterialComponent;
						
						// If we're unable to convert the material to a component, then assign it a grey material with the same name
						// (so at least it makes it a little easier to create and re-assign manually created materials.
						if ( meshComponent.materialComponent == null  )
						{
							var materialComponent:ColorMaterialComponent = new ColorMaterialComponent();
							materialComponent.name = mesh.material.name;
							meshComponent.materialComponent = materialComponent;
							compoundOperation.addOperation( new AddItemOperation( materialComponent, parent.children ) );
						}
					}
					
					compoundOperation.addOperation( new AddItemOperation( meshComponent, parent.children ) );
					
					for ( i = 0; i < mesh.numChildren; i++ )
					{
						parseAway3DAsset( objectContainer3D.getChildAt(i), meshComponent, scene );
					}
					
					return meshComponent;
					
				case ObjectContainer3D :
					
					var objectContainer3D:ObjectContainer3D = ObjectContainer3D(asset);
					var object3DComponent:ObjectContainer3DComponent = new ObjectContainer3DComponent();
					object3DComponent.name = objectContainer3D.name == "null" ? resourceIDPrefix : objectContainer3D.name;
					object3DComponent.transform = objectContainer3D.transform;
					compoundOperation.addOperation( new AddItemOperation( object3DComponent, parent.children ) );
					
					for ( i = 0; i < objectContainer3D.numChildren; i++ )
					{
						parseAway3DAsset( objectContainer3D.getChildAt(i), object3DComponent, scene );
					}
					
					return object3DComponent;
					
				case Geometry :
					
					// If we've already parsed this geometry, do nothing and return it.
					var geometry:Geometry = Geometry(asset);
					var geometryComponent:GeometryComponent = componentDictionary[geometry];
					if ( geometryComponent ) return geometryComponent;
					
					// Otherwise we need to wrap it in a new component, bind it to the resourceFactory for this geometry
					// add it to the scene, and return it.
					geometryComponent = new GeometryComponent();
					geometryComponent.name = geometry.name;
					FloxApp.resourceManager.bindResource( resourceIDPrefix + "." + asset.name, geometryComponent, "geometry" );
					componentDictionary[geometry] = geometryComponent;
					compoundOperation.addOperation( new AddItemOperation( geometryComponent, parent.children ) );
					return geometryComponent;

				
				case ColorMaterial :
					
					// If we've already parsed this material, do nothing and return it.
					var colorMaterial:ColorMaterial = ColorMaterial(asset);
					var colorMaterialComponent:ColorMaterialComponent = componentDictionary[colorMaterial];
					if ( colorMaterialComponent ) return colorMaterialComponent;
					
					colorMaterialComponent = new ColorMaterialComponent( colorMaterial );
					colorMaterialComponent.name = colorMaterial.name;
					componentDictionary[colorMaterial] = colorMaterialComponent;
					compoundOperation.addOperation( new AddItemOperation( colorMaterialComponent, parent.children ) );
					
					return colorMaterialComponent
			}
			
			return null;
		}
	}
}