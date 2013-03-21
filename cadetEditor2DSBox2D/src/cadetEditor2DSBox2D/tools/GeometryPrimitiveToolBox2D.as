// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DSBox2D.tools
{
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.transforms.Transform2D;
	
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	
	import cadetEditor2D.events.PickingManagerEvent;
	
	import core.app.operations.AddItemOperation;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import cadetEditor2DS.tools.GeometryPrimitiveTool;

	public class GeometryPrimitiveToolBox2D extends GeometryPrimitiveTool
	{
		public function GeometryPrimitiveToolBox2D()
		{
		}
		
		override protected function onMouseDownContainer( event:PickingManagerEvent ):void
		{
			dragging = true;
			
			mouseDownPoint = context.snapManager.snapPoint(view.worldMouse).snapPoint;
			
			var compoundOperation:UndoableCompoundOperation = new UndoableCompoundOperation();
			compoundOperation.label = getOperationDescription();
			
			entity = new Entity();
			entity.name = ComponentUtil.getUniqueName(getName(),context.scene);
			
			transform = new Transform2D();
			transform.x = mouseDownPoint.x;
			transform.y = mouseDownPoint.y;
			entity.children.addItem( transform );
			
			geometry = new GeometryType();
			entity.children.addItem(geometry);
			
			if ( geometry is PolygonGeometry )
			{
				context.snapManager.setVerticesToIgnore(PolygonGeometry(geometry).vertices);
			}
			else
			{
				context.snapManager.setVerticesToIgnore(null);
			}
			
			skin = new SkinType();
			entity.children.addItem( skin );
			
			initializeComponent();
			
			compoundOperation.addOperation( new AddItemOperation( entity, context.scene.children ) );
			compoundOperation.addOperation( new ChangePropertyOperation( context.selection, "source", [ entity ] ) );
			
			context.operationManager.addOperation( compoundOperation );
			
			onMouseMoveContainer(null);
		}		
	}
}