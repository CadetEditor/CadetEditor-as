// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.commandHandlers
{
	import cadet.core.IComponent;
	
	import cadet2D.components.skins.IAnimatable;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.validators.ContextComponentSelectionValidator;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.entities.CadetEditorCommands2D;
	
	import cadetEditor2DS.operations.PreviewAnimationsOperation;
	
	import core.appEx.core.commandHandlers.ICommandHandler;
	import core.appEx.resources.CommandHandlerFactory;
	import core.editor.CoreEditor;
	import core.editor.utils.CoreEditorUtil;

	public class PreviewAnimationCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands2D.PREVIEW_ANIMATION, PreviewAnimationCommandHandler );
			factory.validators.push( new ContextComponentSelectionValidator( CoreEditor.contextManager, ICadetEditorContext2D, true, IAnimatable ) );
			return factory;
		}
		
		public function PreviewAnimationCommandHandler() {}

		public function execute(parameters:Object):void
		{
			var context:ICadetEditorContext2D = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext2D);
			var components:Array = CoreEditorUtil.getCurrentSelection( ICadetEditorContext, IComponent );
			var operation:PreviewAnimationsOperation = new PreviewAnimationsOperation( components );
			operation.execute();
		}
	}
}