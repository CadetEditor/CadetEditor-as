package
{
	import flash.display.Sprite;
	
	import cadetEditor2DSBox2D.controllers.PhysicsControlBarController;
	
	import flox.app.FloxApp;
	import flox.app.managers.ResourceManager;
	import flox.app.resources.FactoryResource;
	
	public class CadetEditor_Ext_2DSBox2D_Tools extends Sprite
	{
		public function CadetEditor_Ext_2DSBox2D_Tools()
		{
			var resourceManager:ResourceManager = FloxApp.resourceManager;
			
			// Controllers
			resourceManager.addResource( new FactoryResource( PhysicsControlBarController, "Physics Control Bar" ) );
						
		}
	}
}