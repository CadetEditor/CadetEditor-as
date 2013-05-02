// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.operations
{
	import cadet.core.ICadetScene;
	import cadet.util.ComponentUtil;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.IWriteFileOperation;
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.ResourceSerializerPlugin;
	import core.app.core.serialization.Serializer;
	import core.app.entities.URI;
	import core.app.events.OperationProgressEvent;
	import core.app.managers.ResourceManager;
	import core.app.operations.CloneOperation;
	import core.appEx.operations.SerializeAndWriteFileOperation;
	import core.app.operations.SerializeOperation;
	import core.app.util.IntrospectionUtil;
	import core.editor.CoreEditor;
	import core.editor.contexts.IEditorContext;
	import core.editor.operations.SaveFileAsOperation;

	public class SerializeAndWriteCadetFileOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var scene				:ICadetScene;
		private var uri					:URI;
		private var fileSystemProvider	:IFileSystemProvider;
		private var resourceManager		:ResourceManager;
		
		public function SerializeAndWriteCadetFileOperation( scene:ICadetScene, uri:URI, fileSystemProvider:IFileSystemProvider, resourceManager:ResourceManager )
		{
			this.scene = scene;
			this.uri = uri;
			this.fileSystemProvider = fileSystemProvider;
			this.resourceManager = resourceManager;
		}
		
		public function execute():void
		{
			var plugins:Vector.<ISerializationPlugin> = new Vector.<ISerializationPlugin>();
			if ( resourceManager )
			{
				plugins.push( new ResourceSerializerPlugin( resourceManager ) );
			}
			
			var serializeOperation:SerializeOperation = new SerializeOperation(scene, plugins );
			serializeOperation.addEventListener( OperationProgressEvent.PROGRESS, serializeProgressHandler);
			serializeOperation.addEventListener( Event.COMPLETE, serializeCompleteHandler );
			serializeOperation.addEventListener( ErrorEvent.ERROR, passThroughHandler );
			serializeOperation.execute();
		}
		
		private function serializeProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.progress * 0.5 ) );
		}
		
		private function serializeCompleteHandler( event:Event ):void
		{
			var serializeOperation:SerializeOperation = SerializeOperation(event.target);
			var xml:XML = serializeOperation.getResult();
			
			// Delete any children of ComponentContainer nodes that have a templateID set.
			// This ensures we don't write out extraneous information that will be replaced upon load anyway (during the template merging process).
			// This process used to be done on the dom, rather than on the serialized XML representing the DOM.
			// To perform this stripping on the dom requires that we clone it first (as the editor will still be using it).
			// Cloning a whole DOM can be very sloooow. It turns out that doing the same thing on the XML is much faster.
			var x:Namespace = Serializer.x;
			var nodesWithTemplateID:XMLList = xml..*.(name() == "cadet.core::ComponentContainer" && String(attribute("templateID")) != "");
			
			for ( var i:int = 0; i < nodesWithTemplateID.length(); i++ )
			{
				var nodeWithTemplateID:XML = nodesWithTemplateID[i];
				
				var childrenContainer:XML = nodeWithTemplateID.children().(@x::name == "children")[0];
				
				for ( var j:int = 0; j < childrenContainer.children().length(); j++ )
				{
					var childNode:XML = childrenContainer.children()[j];
					var classPath:String = String(childNode.name()).replace("::", ".");
					var type:Class = Class(getDefinitionByName(classPath));
					
					var inheritFromTemplateValue:String = IntrospectionUtil.getMetadataByNameAndKey(type, "Cadet", "inheritFromTemplate");
					if ( inheritFromTemplateValue != "false" )
					{
						delete childrenContainer.children()[j];
						j--;
					}
				}
			}
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(xml.toXMLString());
			
			//TODO: Rob added try catch for when file is at a url but needs to be saved to a sharedObject
			try {
				var writeFileOperation:IWriteFileOperation = fileSystemProvider.writeFile(uri, bytes);
				writeFileOperation.addEventListener( OperationProgressEvent.PROGRESS, writeFileProgressHandler);
				writeFileOperation.addEventListener( Event.COMPLETE, writeFileCompleteHandler );
				writeFileOperation.addEventListener( ErrorEvent.ERROR, passThroughHandler );
				writeFileOperation.execute();
			} catch ( e:Error ) {
				dispatchEvent( new Event( Event.COMPLETE ) );
				var editorContext:IEditorContext = IEditorContext(CoreEditor.contextManager.getLatestContextOfType(IEditorContext));
				var operation:SaveFileAsOperation = new SaveFileAsOperation( editorContext );
				operation.execute();
			}
		}
		
		private function passThroughHandler( event:ErrorEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function writeFileProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, 0.5 + event.progress * 0.5 ) );
		}
		
		private function writeFileCompleteHandler( event:Event ):void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get label():String { return "Save Cadet File : " + uri.path; }
	}
}