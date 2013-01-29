package platformer.operations
{
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.transforms.Transform2D;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.operations.RemoveComponentOperation;
	
	import flox.app.FloxApp;
	import flox.app.core.operations.IUndoableOperation;
	import flox.app.managers.ResourceManager;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	
	import platformer.components.behaviours.TileBehaviour;
	import platformer.components.processes.GridProcess;
	
	public class AddTileOperation extends UndoableCompoundOperation implements IUndoableOperation
	{
		protected var entity				:Entity;
		protected var skin					:ImageSkin;
		protected var transform				:Transform2D;
		
		public function AddTileOperation(context:ICadetEditorContext, x:int, y:int, brush:XML)
		{
			_description = "Add Tile";

			entity = new Entity();
			entity.name = ComponentUtil.getUniqueName("Tile", context.scene);
			
			transform = new Transform2D();
			transform.x = x;
			transform.y = y;
			entity.children.addItem( transform );
			
			var gridProcess:GridProcess = ComponentUtil.getChildOfType(context.scene, GridProcess);
			if (gridProcess) {
				var previousTile:TileBehaviour = gridProcess.getTileAtPosition( x, y );
				if ( previousTile && previousTile.parentComponent && previousTile.parentComponent.scene ) {
					var removeComponentOperation:RemoveComponentOperation = new RemoveComponentOperation(previousTile.parentComponent);
					addOperation(removeComponentOperation);
				}
			}
			
			var resourceManager:ResourceManager = FloxApp.resourceManager;
			
			skin = new ImageSkin();
			entity.children.addItem( skin );
			
			var behaviour:TileBehaviour = new TileBehaviour();
			behaviour.brush = brush;
			behaviour.solid = brush.@solid == "true" ? true : false;
			behaviour.ignoreNeighbours = brush.@ignoreNeighbours == "true" ? true : false;
			behaviour.skinName = brush.@path;
			
			entity.children.addItem(behaviour);
			
			addOperation( new AddItemOperation( entity, context.scene.children ) );
			addOperation( new ChangePropertyOperation( context.selection, "source", [ entity ] ) );
						
		}
	}
}