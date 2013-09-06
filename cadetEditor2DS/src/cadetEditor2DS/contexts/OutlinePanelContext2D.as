package cadetEditor2DS.contexts
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.transforms.Transform2D;
	
	import cadetEditor.contexts.OutlinePanelContext;
	
	import core.app.operations.AddItemOperation;
	import core.app.operations.RemoveItemOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.appEx.core.contexts.IOperationManagerContext;
	import core.data.ArrayCollection;
	import core.ui.events.DragAndDropEvent;
	
	import starling.utils.MatrixUtil;
	
	public class OutlinePanelContext2D extends OutlinePanelContext
	{
		public function OutlinePanelContext2D()
		{
			super();
		}
		
		override protected function dragDropHandler( event:DragAndDropEvent ):void
		{
			if ( context is IOperationManagerContext == false )
			{
				return;
			}
			
			event.preventDefault();
			
			var component:IComponent = IComponent(event.item);
			var container:IComponentContainer = _view.getParent(event.targetCollection) as IComponentContainer;
			if ( container == null )
			{
				container = context.scene;
			}
			if ( component == container ) return;
			
			var dropIndex:int = event.index;
			var sourceCollection:ArrayCollection = component.parentComponent.children;
			var sourceIndex:int = sourceCollection.getItemIndex(component);
			
			if ( sourceCollection == container.children && sourceIndex < dropIndex )
			{
				dropIndex--;
			}
			
			// Get the childTransform's globalMatrix before it's removed from the scene so that
			// it retains a sense of screen space, rather than just working off it's x & y coords
			if ( component is ComponentContainer ) {
				var childTransform:Transform2D = ComponentUtil.getChildOfType( ComponentContainer( component ), Transform2D );
				var m2:Matrix = childTransform.globalMatrix.clone();
			}
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			if ( component.parentComponent )
			{
				operation.addOperation( new RemoveItemOperation( component, component.parentComponent.children ) );
			}
			
			// Check if the component being added to the container has a child Transform2D and whether the container
			// itself has a child Transform2D. If both are true, the child transform's position should be 'globalToLocalled'
			// within the parent transform, in order to maintain the same position on screen.
			//TODO: This probably won't work for multiple nested transforms...
			var parentTransform:Transform2D = ComponentUtil.getChildOfType(container, Transform2D );
			
			if ( childTransform ) {
				// GlobalToLocal - Adding to a ComponentContainer
				if ( parentTransform ) {

					trace("parent: "+container.name);
					var m:Matrix = parentTransform.globalMatrix.clone(); // clone local-to-global matrix before inverting
					trace("parent globalMatrix "+m);
					trace("child globalMatrix "+m2);
					m.invert(); // invert and get global-to-local
				
					// this is from Starling, but you can copy this method code as well - it's just 2 lines
					var pt:Point = MatrixUtil.transformCoords(m, m2.tx, m2.ty);
					trace("globalToLocal point x "+pt.x+" y "+pt.y);
				} 
				// LocalToGlobal - Adding to root of scene
				else {
					//m = childTransform.globalMatrix.clone();
					m = childTransform.globalMatrix.clone();
					//m.invert(); // invert and get global-to-local
					
					pt = MatrixUtil.transformCoords(m, 0, 0);
				}
				
				childTransform.x = pt.x;
				childTransform.y = pt.y;
			}
			
			operation.addOperation( new AddItemOperation( component, container.children, dropIndex ) );
			IOperationManagerContext(context).operationManager.addOperation(operation);
		}
	}
}