// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import cadet.core.CadetScene;
	import cadet.core.ICadetScene;
	import cadet.operations.ReadCadetFileAndDeserializeOperation;
	
	import cadetEditor.operations.SerializeAndWriteCadetFileOperation;
	import cadetEditor.util.UserDataUtil;
	
	import core.app.CoreApp;
	import core.app.controllers.ExternalResourceController;
	import core.app.core.contexts.IContext;
	import core.app.entities.URI;
	import core.app.events.OperationManagerEvent;
	import core.app.managers.OperationManager;
	import core.data.ArrayCollection;
	import core.editor.CoreEditor;
	import core.editor.contexts.AbstractEditorContext;
	import core.editor.utils.FileSystemProviderUtil;
	import core.events.ArrayCollectionEvent;
	import core.ui.components.Alert;
	
	public class AbstractCadetEditorContext extends AbstractEditorContext implements IContext
	{
		private var _storedUserData		:Object;
		protected var _scene			:ICadetScene;
		protected var _selection		:ArrayCollection;
		protected var _operationManager	:OperationManager;
		protected var _enabled			:Boolean = false;
		
		private var _publishURI			:URI;
		
		public function AbstractCadetEditorContext()
		{
			_selection = new ArrayCollection();
			_selection.addEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			
			_operationManager = new OperationManager();
			_operationManager.addEventListener( OperationManagerEvent.CHANGE, operationManagerChangedHandler );
		}
		
		////////////////////////////////////////////
		// Public
		////////////////////////////////////////////
		
		/* Implement IContext */
		
		public function dispose():void
		{
			_selection.removeEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			_selection = null;
			
			_operationManager.removeEventListener( OperationManagerEvent.CHANGE, operationManagerChangedHandler );
			_operationManager.dispose();
			
			disposeScene();
			_scene.dispose();
		}
		
		/* Implement IVisualContext */
		public function get view():DisplayObject
		{
			// Must be overriden;
			return null;
		}
		
		/* Implement IEditorContext */
		public function load():void
		{
			if ( _scene )
			{
				disposeScene();
				_scene.dispose();
			}
			
			var operation:ReadCadetFileAndDeserializeOperation = new ReadCadetFileAndDeserializeOperation( _uri, CoreApp.fileSystemProvider, CoreApp.resourceManager );
			operation.addEventListener(Event.COMPLETE, loadCompleteHandler);
			operation.addEventListener(ErrorEvent.ERROR, loadErrorHandler);
			CoreEditor.operationManager.addOperation(operation);
		}
		
		private function loadErrorHandler( event:ErrorEvent ):void
		{
			_scene = new CadetScene();
			initScene();
			changed = false;
			dispatchEvent( new Event( Event.CHANGE ) );
			_scene.validateNow();
			
			throw( new Error( "Load failed : " + event.text ) );
		}
		
		private function loadCompleteHandler( event:Event ):void
		{
			var operation:ReadCadetFileAndDeserializeOperation = ReadCadetFileAndDeserializeOperation( event.target );
			
			_scene = ICadetScene(operation.getResult());
			
			// Provide hook for subclasses
			initScene();
			
			changed = false;
			dispatchEvent( new Event( Event.CHANGE ) );
			_scene.validateNow();
			
			initResourceController();
		}
		
		public function save():void
		{
			var operation:SerializeAndWriteCadetFileOperation = new SerializeAndWriteCadetFileOperation( _scene, uri, CoreApp.fileSystemProvider, CoreApp.resourceManager );
			operation.addEventListener(Event.COMPLETE, saveCompleteHandler);
			CoreEditor.operationManager.addOperation(operation);
		}
		
		public function publish():void
		{
			// Clear User Data
			_storedUserData = UserDataUtil.copyUserData(_scene.userData);
			_scene.userData = null;
			
			_publishURI = new URI();
			_publishURI.copyURI(uri);
			var publishURL:String = uri.path;
			//var extIndex:int = publishURL.indexOf(".");
			publishURL = publishURL.replace(".cdt2d", ".cdt");
			_publishURI = new URI(publishURL);
			
			var operation:SerializeAndWriteCadetFileOperation = new SerializeAndWriteCadetFileOperation( _scene, _publishURI, CoreApp.fileSystemProvider, CoreApp.resourceManager );
			operation.addEventListener(Event.COMPLETE, publishCompleteHandler);
			CoreEditor.operationManager.addOperation(operation);
		}
		
		private function initResourceController():void
		{
			//var assetsURI:URI = CoreEditor.getAssetsDirectoryURI();
			var assetsURI:URI = new URI(FileSystemProviderUtil.getProjectDirectoryURI(CoreEditor.currentEditorContextURI).path+CoreApp.externalResourceFolderName);
			
			if (!CoreApp.externalResourceControllers[assetsURI.path]) {
				CoreApp.externalResourceControllers[assetsURI.path] = new ExternalResourceController( CoreApp.resourceManager, assetsURI, CoreApp.fileSystemProvider );
			}
		}
		
		/* Implement ICadetContext */
		
		public function get scene():ICadetScene
		{
			return _scene;
		}
		
		/* Implement IOperationManagerContext */
		
		public function get operationManager():OperationManager
		{
			return _operationManager;
		}
		
		/* Implement ISelectionContext */
		
		public function get selection():ArrayCollection
		{
			return _selection;
		}
		
		////////////////////////////////////////////
		// Protected 'virtual' methods
		////////////////////////////////////////////
		
		protected function initScene():void {}
		protected function disposeScene():void {}
		
		////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////
		
		/**
		 * set changed is a setter inherited from IEditorContext.
		 * We consider a file to have 'changed' ( and therefore ellegible for a fresh save ) when
		 * the operation manager has changed in any way.
		 */		
		protected function operationManagerChangedHandler( event:OperationManagerEvent ):void
		{
			changed = true;
		}
		
		protected function selectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			
		}
		
		private function publishCompleteHandler( event:Event ):void
		{
			_scene.userData = _storedUserData;
			Alert.show(	"Publish Success", "The file '" + _publishURI.path + "' was successfully published.", 
				["Ok"], "Ok",
				null, true,
				closeAlertHandler );			
		}
		
		private function saveCompleteHandler( event:Event ):void
		{
			changed = false;
		}
		
		private function closeAlertHandler( event:Event ):void
		{
			
		}
	}
}