// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.contexts
{
	import cadet.core.CadetScene;
	import cadet.core.ICadetScene;
	import cadet.core.IRenderer;
	import cadet.operations.ReadCadetFileAndDeserializeOperation;
	
	import cadetEditor.operations.SerializeAndWriteCadetFileOperation;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import flox.app.FloxApp;
	import flox.app.controllers.ExternalResourceController;
	import flox.app.core.contexts.IContext;
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.entities.URI;
	import flox.app.events.OperationManagerEvent;
	import flox.app.managers.OperationManager;
	import flox.app.managers.fileSystemProviders.local.LocalFileSystemProvider;
	import flox.app.managers.fileSystemProviders.memory.MemoryFileSystemProvider;
	import flox.core.data.ArrayCollection;
	import flox.core.events.ArrayCollectionEvent;
	import flox.editor.FloxEditor;
	import flox.editor.contexts.AbstractEditorContext;
	import flox.editor.contexts.IEditorContext;
	import flox.editor.core.FloxEditorEnvironment;
	
	public class AbstractCadetEditorContext extends AbstractEditorContext implements IContext
	{
		protected var _scene			:ICadetScene;
		protected var _selection		:ArrayCollection;
		protected var _operationManager	:OperationManager;
		protected var _enabled			:Boolean = false;
		
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
			
			var operation:ReadCadetFileAndDeserializeOperation = new ReadCadetFileAndDeserializeOperation( _uri, FloxApp.fileSystemProvider, FloxApp.resourceManager );
			operation.addEventListener(Event.COMPLETE, loadCompleteHandler);
			operation.addEventListener(ErrorEvent.ERROR, loadErrorHandler);
			FloxEditor.operationManager.addOperation(operation);
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
			var operation:SerializeAndWriteCadetFileOperation = new SerializeAndWriteCadetFileOperation( _scene, uri, FloxApp.fileSystemProvider, FloxApp.resourceManager );
			operation.addEventListener(Event.COMPLETE, saveCompleteHandler);
			FloxEditor.operationManager.addOperation(operation);
		}
		
		private function initResourceController():void
		{
			//var assetsURI:URI = FloxEditor.getAssetsDirectoryURI();
			var assetsURI:URI = new URI(FloxEditor.getProjectDirectoryURI().path+FloxApp.externalResourceFolderName);
			
			if (!FloxApp.externalResourceControllers[assetsURI.path]) {
				FloxApp.externalResourceControllers[assetsURI.path] = new ExternalResourceController( FloxApp.resourceManager, assetsURI, FloxApp.fileSystemProvider );
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
		
		private function saveCompleteHandler( event:Event ):void
		{
			changed = false;
		}
	}
}