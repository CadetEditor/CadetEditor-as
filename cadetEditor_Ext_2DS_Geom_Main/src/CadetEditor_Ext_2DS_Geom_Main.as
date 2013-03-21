package
{
	import flash.display.Sprite;
	
	import cadetEditor2DS.tools.BezierCurveTool;
	import cadetEditor2DS.tools.CircleTool;
	import cadetEditor2DS.tools.PolygonTool;
	import cadetEditor2DS.tools.RectangleTool;
	import cadetEditor2DS.tools.TriangleTool;
	
	import core.app.CoreApp;
	import core.app.managers.ResourceManager;
	
	public class CadetEditor_Ext_2DS_Geom_Main extends Sprite
	{
		public function CadetEditor_Ext_2DS_Geom_Main()
		{
			var resourceManager:ResourceManager = CoreApp.resourceManager;		
			
			// Geom Tools
			resourceManager.addResource( RectangleTool.getFactory() );
			resourceManager.addResource( TriangleTool.getFactory() );
			resourceManager.addResource( CircleTool.getFactory() );
			resourceManager.addResource( PolygonTool.getFactory() );
			resourceManager.addResource( BezierCurveTool.getFactory() );
		}
	}
}