package
{
	import flash.display.Sprite;
	
	import cadetEditor2DSBox2D.controllers.PhysicsControlBarController;
	import cadetEditor2DSBox2D.tools.ConnectionTool;
	import cadetEditor2DSBox2D.tools.PinTool;
	import cadetEditor2DSBox2D.tools.TerrainTool;
	
	import core.app.CoreApp;
	import core.app.managers.ResourceManager;
	import core.app.resources.FactoryResource;
	
	public class CadetEditor_Ext_2DS_Box2D_Main extends Sprite
	{
		public function CadetEditor_Ext_2DS_Box2D_Main()
		{
			var resourceManager:ResourceManager = CoreApp.resourceManager;
			
			// Controllers
			resourceManager.addResource( new FactoryResource( PhysicsControlBarController, "Physics Control Bar" ) );
		
			// Tools
			resourceManager.addResource( ConnectionTool.getFactory() );
			resourceManager.addResource( PinTool.getFactory() );
			resourceManager.addResource( TerrainTool.getFactory() );
		}
	}
}