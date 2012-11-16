// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers
{
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet.util.ComponentUtil;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor2D.operations.MakeConvexOperation;
	
	import flox.editor.FloxEditor;
	import flox.editor.utils.FloxEditorUtil;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.validators.ContextSelectionValidator;

	public class MakeConvexCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.MAKE_CONVEX, MakeConvexCommandHandler );
			factory.validators.push( new ContextSelectionValidator( FloxEditor.contextManager, ICadetEditorContext, true, IComponentContainer ) );
			return factory;
		}
		
		public function MakeConvexCommandHandler() {}
		
		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			var components:Array = FloxEditorUtil.getCurrentSelection(ICadetEditorContext, IComponentContainer);
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Make convex";
			
			for each ( var component:IComponentContainer in components )
			{
				var polygons:Vector.<IComponent> = ComponentUtil.getChildrenOfType(component, PolygonGeometry);
				if ( polygons.length == 0 ) continue;
				
				for each ( var polygon:PolygonGeometry in polygons )
				{
					var makeConvexOperation:MakeConvexOperation = new MakeConvexOperation(polygon);
					operation.addOperation(makeConvexOperation);
				}
			}
			
			if ( operation.operations.length == 0 ) return;
			
			context.operationManager.addOperation(operation);
		}
	}
}