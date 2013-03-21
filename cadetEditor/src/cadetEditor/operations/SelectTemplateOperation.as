// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.operations
{
	import cadet.core.ICadetScene;
	import cadet.core.IComponent;
	import cadet.util.ComponentUtil;
	
	import cadetEditor.ui.panels.SelectTemplatePanel;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import core.app.CoreApp;
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.ResourceSerializerPlugin;
	import core.app.entities.FileSystemNode;
	import core.app.entities.URI;
	import core.app.managers.ResourceManager;
	import core.app.operations.ReadFileAndDeserializeOperation;
	import core.app.util.VectorUtil;
	import core.data.ArrayCollection;
	import core.editor.CoreEditor;

	[Event(type="org.boneframework.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.ErrorEvent", name="error")]
	
	public class SelectTemplateOperation extends EventDispatcher implements IAsynchronousOperation
	{
		static private var panel				:SelectTemplatePanel;
		
		private var resourceManager				:ResourceManager;
		private var uri							:URI;
		private var result						:String;
		private var selectedScene				:ICadetScene;
		
		public var selectedTemplate				:IComponent;
		public var selectedFile					:URI;
		public var selectedTemplateID			:String;
		
		public function SelectTemplateOperation( resourceManager:ResourceManager, uri:URI = null )
		{
			this.resourceManager = resourceManager;
			this.uri = uri;
		}

		public function execute():void
		{
			openPanel();
			
			panel.fileSystemTree.fileSystemProvider = CoreApp.fileSystemProvider;
			panel.fileSystemTree.dataProvider = CoreApp.fileSystemProvider.fileSystem;
			
			if ( uri )
			{
				var node:FileSystemNode = CoreApp.fileSystemProvider.fileSystem.getChildWithPath(uri.path,true);
				panel.fileSystemTree.openToItem(node);
				panel.fileSystemTree.selectedFile = uri;
				panel.fileSystemTree.dispatchEvent( new Event( Event.CHANGE ) );
			}
		}
		
		public function get label():String
		{
			return "Select Template";
		}
		
		private function clickOkHandler( event:MouseEvent ):void
		{
			selectedFile = panel.fileSystemTree.selectedFile;
			selectedTemplate = IComponent(panel.list.selectedItem);
			selectedTemplateID = selectedFile.path + "#" + selectedTemplate.exportTemplateID;
			closePanel();
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function clickCancelHandler( event:MouseEvent ):void
		{
			selectedTemplate = null;
			selectedFile = null;
			selectedTemplateID = null;
			closePanel();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function changeFileSystemTreeHandler( event:Event ):void
		{
			var selectedFile:URI = panel.fileSystemTree.selectedFile;
			
			panel.list.dataProvider = null;
			panel.list.validateNow();
			
			if ( !selectedFile ) return;
			if ( selectedFile.isDirectory() )
			{
				return;
			}
			
			var plugins:Vector.<ISerializationPlugin> = new Vector.<ISerializationPlugin>();
			plugins.push( new ResourceSerializerPlugin( resourceManager ) );
			
			var operation:ReadFileAndDeserializeOperation = new ReadFileAndDeserializeOperation(selectedFile, CoreApp.fileSystemProvider, plugins);
			operation.addEventListener(Event.COMPLETE, readFileCompleteHandler);
			operation.addEventListener(ErrorEvent.ERROR, readFileErrorHandler);
			CoreEditor.operationManager.addOperation(operation);
		}
		
		private function readFileCompleteHandler( event:Event ):void
		{
			var operation:ReadFileAndDeserializeOperation = ReadFileAndDeserializeOperation(event.target);
			if ( operation.getResult() is ICadetScene == false ) return;
			
			selectedScene = ICadetScene(operation.getResult());
			
			var templates:Vector.<IComponent> = ComponentUtil.getChildren(selectedScene, true);
			templates = templates.filter( filterFunc );
			
			panel.list.dataProvider = new ArrayCollection(VectorUtil.toArray(templates));
		}
		
		private function filterFunc( item:*, index:int, array:Vector.<IComponent> ):Boolean
		{
			return IComponent(item).exportTemplateID != null;
		}
		
		private function readFileErrorHandler( event:ErrorEvent ):void
		{
			
		}
		
		private function openPanel():void
		{
			if ( !panel )
			{
				panel = new SelectTemplatePanel();
			}
			if ( panel.stage ) return;
			
			CoreEditor.viewManager.addPopUp(panel);
			
			panel.fileSystemTree.addEventListener(Event.CHANGE, changeFileSystemTreeHandler);
			panel.okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
		}
		
		private function closePanel():void
		{
			if ( !panel ) return;
			if ( !panel.stage ) return;
			
			panel.fileSystemTree.removeEventListener(Event.CHANGE, changeFileSystemTreeHandler);
			panel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
			panel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			
			CoreEditor.viewManager.removePopUp(panel);
		}
	}
}