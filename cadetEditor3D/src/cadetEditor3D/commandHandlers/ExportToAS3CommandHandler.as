// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.commandHandlers
{
	import away3d.containers.View3D;
	//import away3d.tools.serialize.Serialize;
	//import away3d.tools.serialize.TraceSerializer;
	
	import cadet.util.ComponentUtil;
	
	import cadet3D.components.core.Renderer3D;
	import cadet3D.serialize.*;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.CadetEditorCommands;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.ui.panels.ExportToAS3Panel;
	import cadetEditor3D.ui.panels.TextOutputPanel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import flox.editor.FloxEditor;
	import flox.app.core.commandHandlers.ICommandHandler;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.resources.CommandHandlerFactory;
	import flox.app.util.StringUtil;
	import flox.app.validators.ContextValidator;
	
	public class ExportToAS3CommandHandler implements ICommandHandler
	{
		public static function getFactory():CommandHandlerFactory
		{
			var factory:CommandHandlerFactory = new CommandHandlerFactory( CadetEditorCommands.EXPORT, ExportToAS3CommandHandler, [new ContextValidator(FloxEditor.contextManager, CadetEditorContext3D)] );
			//factory.validators.push( new ContextValidator( BonesEditor.contextManager, ICadetEditorContext ) );
			return factory;
		}
		
		private var context					:ICadetEditorContext;
		private var view3D					:View3D;
		
		private var classStr				:String;
		
		private static var optionsPanel		:ExportToAS3Panel;
		private static var outputPanel		:TextOutputPanel;
		
		public function ExportToAS3CommandHandler() {}
		
		public function execute(parameters:Object):void
		{			
			context = FloxEditor.contextManager.getLatestContextOfType(ICadetEditorContext);
			
			var renderer3D	:Renderer3D	= Renderer3D(ComponentUtil.getChildOfType(context.scene, Renderer3D ));
			view3D						= renderer3D.view3D;
			
			if ( renderer3D ) {
				
				var changeSelectionOperation:ChangePropertyOperation = new ChangePropertyOperation( context.selection, "source", [] );
				changeSelectionOperation.label = "Change Selection";
				context.operationManager.addOperation( changeSelectionOperation );
				
				openOptionsPanel();
			} else {
				// display "there is no renderer3D message"
			}
		}
		
		private function openOptionsPanel():void
		{
			if ( !optionsPanel )
			{
				optionsPanel = new ExportToAS3Panel();
			}
			if ( optionsPanel.stage ) return;
			
			FloxEditor.viewManager.addPopUp(optionsPanel);
			optionsPanel.okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
			optionsPanel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
			optionsPanel.textArea.text = "Please Note: Exporters are currently experimental and haven't been extensively tested.";
			optionsPanel.buttonGroup.selectedIndex = 0;
			optionsPanel.hoverCamCheckBox.selected = true;
			//optionsPanel.buttonGroup.addEventListener(Event.CHANGE, radioButtonChangeHandler);
		}
		private function closeOptionsPanel():void
		{
			optionsPanel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
			optionsPanel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			//optionsPanel.buttonGroup.removeEventListener(Event.CHANGE, radioButtonChangeHandler);
			FloxEditor.viewManager.removePopUp(optionsPanel);
		}
		
//		private function radioButtonChangeHandler( event:Event ):void
//		{
//			
//		}
		
		private function openOutputPanel():void
		{
			if ( !outputPanel )
			{
				outputPanel = new TextOutputPanel();
				//outputPanel.addEventListener(FlexEvent.CREATION_COMPLETE, outputPanelCreatedHandler);
			}
			if ( outputPanel.stage ) return;
			
			outputPanel.textArea.text = classStr;
			outputPanel.textArea.editable = true;
			
			if ( optionsPanel.buttonGroup.selectedIndex == 0 )
				outputPanel.label = "Exported ActionScript";
			else if ( optionsPanel.buttonGroup.selectedIndex == 1 )
				outputPanel.label = "Exported HTML & JS";
			
			FloxEditor.viewManager.addPopUp(outputPanel);
			
			outputPanel.copyBtn.addEventListener(MouseEvent.CLICK, clickCopyHandler);
			outputPanel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCloseHandler);
		}
		private function closeOutputPanel():void
		{
			//outputPanel.removeEventListener(FlexEvent.CREATION_COMPLETE, outputPanelCreatedHandler);
			outputPanel.copyBtn.removeEventListener(MouseEvent.CLICK, clickCopyHandler);
			outputPanel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCloseHandler);
			FloxEditor.viewManager.removePopUp(outputPanel);
		}
		
		private function outputPanelCreatedHandler( event:Event ):void//event:FlexEvent ):void
		{
			outputPanel.textArea.text = classStr;
		}
		private function clickOkHandler( event:MouseEvent ):void
		{
			var renderer3D		:Renderer3D = ComponentUtil.getChildOfType(context.scene, Renderer3D, false);

			var addHoverCam:Boolean = false;
			if ( optionsPanel.hoverCamCheckBox.selected ) {
				addHoverCam = true;
			}
			
			var serializer:ISerializer;
			if ( optionsPanel.buttonGroup.selectedIndex == 0 ) {
				serializer	= new AS3Serializer(addHoverCam);
			} else if ( optionsPanel.buttonGroup.selectedIndex == 1 ) {
				serializer	= new ThreeJSSerializer(addHoverCam);
			}
			
			classStr = serializer.export( renderer3D.rootContainer );
			
			closeOptionsPanel();
			openOutputPanel();
		}
		private function clickCancelHandler( event:MouseEvent ):void
		{
			closeOptionsPanel();
		}
		private function clickCopyHandler( event:MouseEvent ):void
		{
			outputPanel.stage.focus = outputPanel.textArea;
			System.setClipboard( classStr );
		}
		private function clickCloseHandler( event:MouseEvent ):void
		{
			closeOutputPanel();
		}
		
//		private function exporterCompleteHandler( event:ExporterEvent ):void
//		{
//			classStr = String(event.data);
//			
//			closeOptionsPanel();
//			openOutputPanel();
//		}
	}
}










