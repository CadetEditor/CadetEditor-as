// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.commandHandlers 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import flox.editor.FloxEditor;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.validators.ContextValidator;
	
	/**
	 * ...
	 * @author Jon
	 */
	public class EditSnapSettingsCommandHandler implements ICommandHandler
	{
		import cadetEditor2D.ui.panels.SnapSettingsPanel;
		
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.EDIT_SNAP_SETTINGS, EditSnapSettingsCommandHandler );
			factory.validators.push( new ContextValidator( FloxEditor.contextManager, ICadetEditorContext ) );
			return factory;
		}
		
		private var context		:ICadetEditorContext;
		private var panel		:SnapSettingsPanel;
		
		public function EditSnapSettingsCommandHandler() 
		{
			
		}
		
		public function execute( parameters:Object ):void
		{
			context = ICadetEditorContext(FloxEditor.contextManager.getLatestContextOfType( ICadetEditorContext ));
			openPanel();
		}
		
		private function clickOkHandler( event:MouseEvent ):void
		{
			context.scene.userData.gridSnapEnabled = panel.gridSnapToggle.selected;
			context.scene.userData.vertexSnapEnabled = panel.vertexSnapToggle.selected;
			context.scene.userData.centerPointSnapEnabled = panel.centerPointSnapToggle.selected;
			context.scene.userData.snapRadius = panel.snapRadiusControl.value;
			
			closePanel();
		}
		
		private function clickCancelHandler( event:MouseEvent ):void
		{
			closePanel();
		}
		
		private function openPanel():void
		{
			if ( panel ) return;
			
			panel = new SnapSettingsPanel();
			FloxEditor.viewManager.addPopUp( panel );
			
			panel.okBtn.addEventListener( MouseEvent.CLICK, clickOkHandler );
			panel.cancelBtn.addEventListener( MouseEvent.CLICK, clickCancelHandler );
			
			panel.gridSnapToggle.selected = context.scene.userData.gridSnapEnabled;
			panel.vertexSnapToggle.selected = context.scene.userData.vertexSnapEnabled;
			panel.centerPointSnapToggle.selected = context.scene.userData.centerPointSnapEnabled;
			panel.snapRadiusControl.value = context.scene.userData.snapRadius;
		}
		
		private function closePanel():void
		{
			if ( !panel ) return;
			
			panel.okBtn.removeEventListener( MouseEvent.CLICK, clickOkHandler );
			panel.cancelBtn.removeEventListener( MouseEvent.CLICK, clickCancelHandler );
			
			FloxEditor.viewManager.removePopUp(panel);
			panel = null;
		}
	}

}