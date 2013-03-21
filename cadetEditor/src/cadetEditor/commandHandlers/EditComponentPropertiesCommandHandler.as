// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.commandHandlers
{
	import cadet.core.IComponent;
	import cadet.util.ComponentUtil;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	import cadet.operations.GetTemplateAndMergeOperation;
	import cadetEditor.operations.SelectTemplateOperation;
	import cadetEditor.ui.panels.ComponentPropertiesPanel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import core.app.CoreApp;
	import core.app.core.commandHandlers.ICommandHandler;
	import core.app.entities.URI;
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.app.resources.CommandHandlerFactory;
	import core.app.util.StringUtil;
	import core.app.validators.ContextSelectionValidator;
	import core.editor.CoreEditor;
	import core.editor.utils.CoreEditorUtil;

	public class EditComponentPropertiesCommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.EDIT_COMPONENT_PROPERTIES, EditComponentPropertiesCommandHandler );
			factory.validators.push( new ContextSelectionValidator( CoreEditor.contextManager, ICadetEditorContext, true, IComponent, 1, 1 ) );
			return factory;
		}
		
		public function EditComponentPropertiesCommandHandler() {}
		
		private var context			:ICadetEditorContext;
		private var component		:IComponent;
		private var panel			:ComponentPropertiesPanel;
		
		public function execute(parameters:Object):void
		{
			context = CoreEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			component = CoreEditorUtil.getCurrentSelection(null, IComponent)[0];
			
			openPanel();
			updatePanelFromComponent();
			validateOkBtn();
		}
		
		private function clickOkHandler(event:MouseEvent):void
		{
			commitChanges();
			closePanel();
		}
		
		private function clickCancelHandler(event:MouseEvent):void
		{
			closePanel();
		}
		
		private function commitChanges():void
		{
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Change Component Properties";
			
			if ( panel.exportToggle.selected )
			{
				if ( component.exportTemplateID != panel.exportTemplateIDField.text )
				{
					operation.addOperation( new ChangePropertyOperation( component, "exportTemplateID", panel.exportTemplateIDField.text ) );
				}
			}
			else
			{
				if ( component.exportTemplateID != null )
				{
					operation.addOperation( new ChangePropertyOperation( component, "exportTemplateID", null ) );
				}
			}
			
			if ( panel.importToggle.selected )
			{
				if ( component.templateID != panel.templateIDField.text )
				{
					operation.addOperation( new ChangePropertyOperation( component, "templateID", panel.templateIDField.text ) );
					operation.addOperation( new GetTemplateAndMergeOperation( panel.templateIDField.text, component, CoreApp.fileSystemProvider, {local:context.scene} ) );
				}
			}
			else
			{
				if ( component.templateID != null )
				{
					operation.addOperation( new ChangePropertyOperation( component, "templateID", null ) );
				}
			}
			
			if ( operation.operations.length == 0 ) return;
			
			context.operationManager.addOperation(operation);
		}
		
		private function validateExportID():void
		{
			panel.exportTemplateIDField.removeEventListener(Event.CHANGE, changeExportTemplateIDHandler);
			panel.exportTemplateIDField.text = StringUtil.trim(panel.exportTemplateIDField.text);
			panel.exportTemplateIDField.addEventListener(Event.CHANGE, changeExportTemplateIDHandler);
			var desiredID:String = panel.exportTemplateIDField.text;
			
			if ( desiredID == "" )
			{
				panel.feedbackLabel.text = " ";
				return;
			}
			
			var existingComponent:IComponent = ComponentUtil.getChildWithExportTemplateID(context.scene, desiredID, true);
			if ( existingComponent != null && existingComponent != component )
			{
				panel.feedbackLabel.text = "Another component already owns this ID.";
				return;
			}
			
			panel.feedbackLabel.text = "";
		}
		
		private function validateOkBtn():void
		{
			panel.okBtn.enabled = false;
			
			if ( panel.feedbackLabel.text != "" ) return;
			
			if ( panel.exportToggle.selected )
			{
				if ( panel.exportTemplateIDField.text == "" ) return;
			}
			
			if ( panel.importToggle.selected )
			{
				if ( panel.templateIDField.text == "" ) return;
			}
			
			panel.okBtn.enabled = true;
		}
		
		private function changeExportToggleHandler(event:Event):void
		{
			if ( panel.exportToggle.selected )
			{
				panel.exportTemplateIDField.enabled = true;
				panel.importToggle.enabled = false;
				
				if ( component.exportTemplateID )
				{
					panel.exportTemplateIDField.text = component.exportTemplateID;
				}
				else
				{
					panel.exportTemplateIDField.text = "";
				}
				
				validateExportID();
			}
			else
			{
				panel.exportTemplateIDField.text = "";
				panel.exportTemplateIDField.enabled = false;
				panel.importToggle.enabled = true;
				
				panel.feedbackLabel.text = "";
			}
			
			validateOkBtn();
		}
		
		private function changeImportToggleHandler(event:Event):void
		{
			if ( panel.importToggle.selected )
			{
				panel.templateIDField.enabled = true;
				panel.browseBtn.enabled = true;
				panel.exportToggle.enabled = false;
				
				if ( component.templateID )
				{
					panel.templateIDField.text = component.templateID;
				}
				else
				{
					panel.templateIDField.text = "";
				}
			}
			else
			{
				panel.templateIDField.enabled = false;
				panel.templateIDField.text = "";
				panel.browseBtn.enabled = false;
				panel.exportToggle.enabled = true;
			}
			panel.feedbackLabel.text = "";
			validateOkBtn();
		}
		
		private function changeExportTemplateIDHandler(event:Event):void
		{
			validateExportID();
			validateOkBtn();
		}
		
		private function clickBrowseHandler( event:MouseEvent ):void
		{
			var templatePath:String = panel.templateIDField.text;
			
			var uri:URI;
			if ( templatePath != "" )
			{
				uri = new URI( templatePath.split("#")[0] );
			}
			
			var operation:SelectTemplateOperation = new SelectTemplateOperation(CoreApp.resourceManager, uri);
			operation.addEventListener(Event.COMPLETE, selectTemplateCompleteHandler);
			operation.execute();
		}
		
		private function selectTemplateCompleteHandler( event:Event ):void
		{
			var operation:SelectTemplateOperation = SelectTemplateOperation(event.target);
			if ( operation.selectedTemplateID == null ) return;			
			panel.templateIDField.text = operation.selectedTemplateID;
			validateOkBtn();
		}
		
		private function openPanel():void
		{
			if ( panel ) return;
			panel = new ComponentPropertiesPanel();
			CoreEditor.viewManager.addPopUp(panel);
			
			panel.okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
			panel.exportToggle.addEventListener(Event.CHANGE, changeExportToggleHandler);
			panel.importToggle.addEventListener(Event.CHANGE, changeImportToggleHandler);
			panel.exportTemplateIDField.addEventListener(Event.CHANGE, changeExportTemplateIDHandler);
			panel.browseBtn.addEventListener(MouseEvent.CLICK, clickBrowseHandler);
		}
		
		private function closePanel():void
		{
			if ( !panel ) return;
			
			CoreEditor.viewManager.removePopUp(panel);
			
			panel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			panel.exportToggle.removeEventListener(Event.CHANGE, changeExportToggleHandler);
			panel.importToggle.removeEventListener(Event.CHANGE, changeImportToggleHandler);
			panel.exportTemplateIDField.removeEventListener(Event.CHANGE, changeExportTemplateIDHandler);
			panel.browseBtn.removeEventListener(MouseEvent.CLICK, clickBrowseHandler);
			
			panel = null;
		}
		
		private function updatePanelFromComponent():void
		{
			panel.exportToggle.selected = component.exportTemplateID != null;
			panel.importToggle.selected = component.templateID != null;
			
			if ( panel.exportToggle.selected )
			{
				panel.exportTemplateIDField.text = component.exportTemplateID;
				panel.importToggle.enabled = false;
			}
			else
			{
				panel.exportTemplateIDField.enabled = false;
				panel.importToggle.enabled = true;
			}
			
			if ( panel.importToggle.selected )
			{
				panel.templateIDField.text = component.templateID;
				panel.templateIDField.enabled = true;
				panel.exportToggle.enabled = false;
				panel.browseBtn.enabled = true;
			}
			else
			{
				panel.templateIDField.enabled = false;
				panel.exportToggle.enabled = true;
				panel.browseBtn.enabled = false;
			}
		}
		
	}
}