// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.geom.CircleGeometry;
	import cadet2D.components.geom.CompoundGeometry;
	import cadet2D.components.geom.IGeometry;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.util.VertexUtil;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flox.ui.components.Alert;
	
	import flox.editor.FloxEditor;
	import flox.editor.utils.FloxEditorUtil;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.core.serialization.Serializer;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.RemoveItemOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.validators.ContextSelectionValidator;

	/**
	 * Given a selection of ComponentContainer, this CommandHandler finds all the geometry associated with them and combines them into a single
	 * CompoundGeomtry Component. All original Geometry is removed, and only the first selected ComponentContainer is left in the scene - as this
	 * is the new owner of the CompoundGeometry.
	 * @author Jonathan
	 * 
	 */	
	public class CombineCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.COMBINE, CombineCommandHandler );
			factory.validators.push( new ContextSelectionValidator( FloxEditor.contextManager, ICadetEditorContext, true, IComponentContainer, 2) );
			return factory;
		}
		
		public function CombineCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext = FloxEditor.contextManager.getLatestContextOfType( ICadetEditorContext );
			var selection:Array = FloxEditorUtil.getCurrentSelection( ICadetEditorContext, IComponentContainer );
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Combine";
			
			var compoundGeometry:CompoundGeometry = new CompoundGeometry();
			var childGeometries:Array = [];
			var targetMatrix:Matrix;
			var serializer:Serializer = new Serializer();
			var geometry2:IGeometry;
			for ( var i:int = 0; i < selection.length; i++ )
			{
				var container:IComponentContainer = selection[i];
				
				var transform:Transform2D = ComponentUtil.getChildOfType(container, Transform2D);
				
				if ( !transform )
				{
					Alert.show( "Error", "One of the selected components does not have a transform", ["OK"] );
					return;
				}
				
				var geometry:IGeometry = ComponentUtil.getChildOfType(container, IGeometry);
				if ( !geometry )
				{
					Alert.show( "Error", "One of the selected components does not have any geometry", ["OK"] );
					return;
				}
				
				var geometries:Array = flattenGeometries(geometry);
				if ( i == 0 )
				{
					operation.addOperation( new RemoveItemOperation( geometry, container.children ) );
					operation.addOperation( new AddItemOperation( compoundGeometry, container.children ) );
					
					for each ( geometry2 in geometries )
					{
						operation.addOperation( new AddItemOperation( geometry2, compoundGeometry.children ) );
					}
					
					targetMatrix = transform.matrix.clone();
					targetMatrix.invert();
				}
				else
				{
					operation.addOperation( new RemoveItemOperation( container, container.parentComponent.children ) );
					
					for each ( geometry2 in geometries )
					{
						geometry2 = IGeometry(serializer.clone(geometry2));
						if ( geometry2 is PolygonGeometry )
						{
							var polygonGeometry:PolygonGeometry = new PolygonGeometry();
							polygonGeometry.vertices = PolygonGeometry(geometry2).vertices;
							VertexUtil.transform(polygonGeometry.vertices, transform.matrix);
							VertexUtil.transform(polygonGeometry.vertices, targetMatrix);
							geometry2 = polygonGeometry;
						}
						else if ( geometry2 is CircleGeometry )
						{
							var circleGeometry:CircleGeometry = CircleGeometry(geometry2);
							var pt:Point = new Point(circleGeometry.x, circleGeometry.y);
							pt = transform.matrix.transformPoint(pt);
							pt = targetMatrix.transformPoint(pt);
							circleGeometry.x = pt.x;
							circleGeometry.y = pt.y;
						}
						compoundGeometry.children.addItem(geometry2);
					}
				}
				
			}
			
			operation.addOperation( new ChangePropertyOperation( context.selection, "source", [selection[0]] ) );
			
			context.operationManager.addOperation(operation);
		}
		
		
		private function flattenGeometries( geometry:IGeometry, geometries:Array = null ):Array
		{
			if ( !geometries )
			{
				geometries = [];
			}
			
			if ( geometry is CompoundGeometry )
			{
				var compoundGeometry:CompoundGeometry = CompoundGeometry(geometry);
				for each ( var child:IGeometry in compoundGeometry.children )
				{
					flattenGeometries(child, geometries);
				}
			}
			else
			{
				geometries.push(geometry);
			}
			return geometries;
		}
	}
}