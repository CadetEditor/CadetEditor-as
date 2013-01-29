package
{
	import flash.display.Sprite;
	
	import cadet.core.ICadetScene;
	
	import cadet2D.components.core.Entity;
	
	import cadet2DBox2D.components.behaviours.DistanceJointBehaviour;
	import cadet2DBox2D.components.behaviours.MotorbikeBehaviour;
	import cadet2DBox2D.components.behaviours.PrismaticJointBehaviour;
	import cadet2DBox2D.components.behaviours.RevoluteJointBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyCollisionDetectBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyMouseDragBehaviour;
	import cadet2DBox2D.components.behaviours.SimpleVehicleBehaviour;
	import cadet2DBox2D.components.behaviours.SpringBehaviour;
	import cadet2DBox2D.components.behaviours.VehicleBehaviour;
	import cadet2DBox2D.components.processes.PhysicsProcess;
	
	import cadet.assets.CadetEngineIcons;
	import cadet.entities.ComponentFactory;
	
	import flox.app.FloxApp;
	import flox.app.managers.ResourceManager;
	
	public class CadetEditor_Ext_2DSBox2D extends Sprite
	{
		public function CadetEditor_Ext_2DSBox2D()
		{
			var resourceManager:ResourceManager = FloxApp.resourceManager;

			// Processes
			resourceManager.addResource( new ComponentFactory( PhysicsProcess, 				"Physics", 						"Processes", 	CadetEngineIcons.Process, 		ICadetScene, 	1 ) );
			
			// Behaviours - Physics
			resourceManager.addResource( new ComponentFactory( RigidBodyBehaviour, 			"Rigid Body", 					"Behaviours" ) );
			resourceManager.addResource( new ComponentFactory( RigidBodyMouseDragBehaviour, "Mouse Drag", 					"Behaviours",	CadetEngineIcons.Behaviour,	Entity,			1 ) );			
			resourceManager.addResource( new ComponentFactory( RigidBodyCollisionDetectBehaviour, "RB Collision Detect", 	"Behaviours",	CadetEngineIcons.Behaviour,	Entity,			1 ) );
			
			resourceManager.addResource( new ComponentFactory( DistanceJointBehaviour, 		"Distance Joint", 				"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( SpringBehaviour, 			"Spring Joint", 				"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( RevoluteJointBehaviour, 		"Revolute Joint", 				"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( PrismaticJointBehaviour, 	"Prismatic Joint", 				"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 		1 ) );
			
			resourceManager.addResource( new ComponentFactory( SimpleVehicleBehaviour, 		"Simple Vehicle", 				"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( VehicleBehaviour, 			"Vehicle", 						"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 		1 ) );
			resourceManager.addResource( new ComponentFactory( MotorbikeBehaviour, 			"Motorbike", 					"Behaviours", 	CadetEngineIcons.Behaviour,	Entity, 		1 ) );
			
		}
	}
}