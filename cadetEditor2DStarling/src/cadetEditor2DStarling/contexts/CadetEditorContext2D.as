// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DStarling.contexts
{
	import cadet.core.IComponent;
	import cadet.core.IRenderer;
	import cadet.events.ComponentEvent;
	import cadet.events.RendererEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	
	import cadetEditor.contexts.AbstractCadetEditorContext;
	import cadetEditor.contexts.AbstractTooledCadetEditorContext;
	import cadetEditor.controllers.ICadetContextController;
	import cadetEditor.controllers.ICadetEditorContextController;
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.events.CadetEditorViewEvent;
	import cadetEditor.managers.ToolManager;
	import cadetEditor.ui.views.IToolEditorView;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.controllers.CadetEditorViewPanController;
	import cadetEditor2D.managers.IComponentHighlightManager;
	import cadetEditor2D.managers.IPickingManager2D;
	import cadetEditor2D.managers.SnapManager2D;
	import cadetEditor2D.ui.controlBars.CadetEditorControlBar;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import cadetEditor2DStarling.managers.ComponentHighlightManager;
	import cadetEditor2DStarling.managers.PickingManager2D;
	import cadetEditor2DStarling.ui.overlays.SelectionOverlay;
	import cadetEditor2DStarling.ui.overlays.SnapOverlay;
	import cadetEditor2DStarling.ui.views.CadetEditorView2D;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import flox.app.FloxApp;
	import flox.app.events.OperationManagerEvent;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.IFactoryResource;
	import flox.app.resources.IResource;
	import flox.app.util.IntrospectionUtil;
	import flox.core.events.PropertyChangeEvent;
	import flox.editor.FloxEditor;
	import flox.ui.util.BindingUtil;
	
	[Event( type="flash.events.Event", name="change" )]
	
	public class CadetEditorContext2D extends AbstractTooledCadetEditorContext implements ICadetEditorContext2D
	{
		protected var _snapManager						:SnapManager2D;
		protected var _pickingManager					:PickingManager2D;
		protected var _highlightManager					:IComponentHighlightManager;
		
		protected var _view								:ICadetEditorView2D;
		protected var panController						:CadetEditorViewPanController;
		
		protected var _controllers						:Array;
		
		private var selectionOverlay					:SelectionOverlay;
		
		public function CadetEditorContext2D()
		{
			_view = new CadetEditorView2D();
			_view.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
			_view.addEventListener( CadetEditorViewEvent.RENDERER_CHANGED, rendererChangedHandler );
			
			// Init Managers
			_snapManager = new SnapManager2D();
			_pickingManager = new PickingManager2D();
//			_pickingManager.setContainer(_view.container);
			_pickingManager.snapManager = _snapManager;
			_highlightManager = new ComponentHighlightManager();
			
			// Init controllers
			panController = new CadetEditorViewPanController(this);
			
			// Init Selection Overlay
			selectionOverlay = new SelectionOverlay();
			selectionOverlay.selection = _selection;
			//_view.addOverlay(selectionOverlay);
			
			// Init Snap Overlap
			var snapOverlay:SnapOverlay = new SnapOverlay(_snapManager);
			_view.addOverlay( snapOverlay, CadetEditorView2D.TOP );
			
			_controllers = [];
			
			initTools(IToolEditorView(_view));
		}
		
		protected function addedToStageHandler( event:Event ):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			initControllers();
		}
		protected function rendererChangedHandler( event:CadetEditorViewEvent ):void
		{
			// Enable/Disable Grid controls depending on the availibility of a Renderer2D
			var gridEnabled:Boolean = _view.renderer is IRenderer2D;
			
			var controller:ICadetEditorContextController = ICadetEditorContextController(getControllerOfType(ICadetEditorContextController));
			if ( controller )
			{
				var controlBar:CadetEditorControlBar = CadetEditorControlBar(controller.controlBar);
				controlBar.gridToggle.enabled = gridEnabled;
				controlBar.gridSizeControl.enabled = gridEnabled;
				
				//_controlBar.gridToggle.enabled = gridEnabled;
				//_controlBar.gridSizeControl.enabled = gridEnabled;				
			}
		}
		
		protected function initControllers():void
		{
			// Find and add any Controller resources
			var resources:Vector.<IFactoryResource> = FloxApp.resourceManager.getFactoriesForType(ICadetContextController);
			for ( var i:int = 0; i < resources.length; i++ )
			{
				var factory:FactoryResource = FactoryResource(resources[i]);
				//if ( IntrospectionUtil.isRelatedTo(this, factory.target) == false ) continue;
				var controller:ICadetContextController = ICadetContextController(factory.getInstance());
				controller.init(this);
				_controllers.push(controller);
			}
		}
		
		override public function get view():DisplayObject { return DisplayObject(_view); }
		
		override public function dispose():void
		{
			disable();
			
			panController.disable();
			
			
			_pickingManager.dispose();
			_highlightManager.dispose();
			_snapManager.dispose();
						
			super.dispose();
		}
		
		override public function enable():void
		{
			super.enable();
			
			enableRenderer();
			
			_pickingManager.enable();
			_view.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		override public function disable():void
		{
			super.disable();
			
			disableRenderer();
			
			_pickingManager.disable();
			_view.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enableRenderer():void
		{
			if (!_view.renderer) return;
			
			_view.renderer.enable(DisplayObjectContainer(_view), 2);
		}
		
		private function disableRenderer():void
		{
			if (!_view.renderer) return;
			
			_view.renderer.disable(DisplayObjectContainer(_view));
		}
		
		override protected function disposeScene():void
		{
			// Dispose controllers
			for ( var i:uint = 0; i < _controllers.length; i ++ )
			{
				var controller:ICadetContextController = _controllers[i];
				if ( controller is ICadetEditorContextController ) {
					ICadetEditorContextController(controller).disposeScene();
				}
			}
			
			//BindingUtil.unbindTwoWay( CadetEditorControlBar(_view.controlBar).snapToggle, "selected", _snapManager, "snapEnabled"  );
			
			_scene.removeEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
			_scene.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
			
			_pickingManager.setScene(null);
		}
		
		override protected function initScene():void
		{
			updateCurrentRenderer();
			
			_pickingManager.setScene(_scene);
			_snapManager.setScene(_scene);
			
			_scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
			_scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
			
			// Parse user data
			_snapManager.snapEnabled = _scene.userData.snapEnabled == "0" ? false : true; 
			_snapManager.gridSizeX = _snapManager.gridSizeY = _scene.userData.gridSize == null ? 10 : Number(_scene.userData.gridSize);
			
			
			// Init controllers
			for ( var i:uint = 0; i < _controllers.length; i ++ )
			{
				var controller:ICadetContextController = _controllers[i];
				// Rename to IDefaultControlBarController?
				if ( controller is ICadetEditorContextController ) {
					ICadetEditorContextController(controller).initScene();
				}
			}
			
//			_view.showGrid = _scene.userData.showGrid == "0" ? false : true;
//			_view.zoom = _scene.userData.zoom == null ? 1 : Number(_scene.userData.zoom);
//			_view.panX = _scene.userData.panX == null ? _view.viewportWidth/2 : Number(_scene.userData.panX);
//			_view.panY = _scene.userData.panY == null ? _view.viewportHeight/2 : Number(_scene.userData.panY);
//			_view.gridSize = _scene.userData.gridSize == null ? 10 : Number(_scene.userData.gridSize);
//			
//			BindingUtil.bindTwoWay( _snapManager, "snapEnabled", CadetEditorControlBar(_view.controlBar).snapToggle, "selected" );
			
			// TODO: Hardcoded reference to selectedTool.
			if ( _toolManager.tools.length > 0 )
			{
				_toolManager.selectedTool = _toolManager.tools[0];
			}
			
			enable();
		}
		
		override public function save():void
		{
			// Save user data
			_scene.userData.snapEnabled = _snapManager.snapEnabled;
			
			_scene.userData.showGrid =_view.showGrid;
			_scene.userData.zoom = _view.zoom;
			_scene.userData.panX = _view.panX;
			_scene.userData.panY = _view.panY;
			_scene.userData.gridSize = _view.gridSize;
			
			super.save();
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			if (!_scene) return;
			scene.validateNow();
		}
		
		private function componentAddedHandler( event:ComponentEvent ):void
		{
			if ( event.component is IRenderer2D == false ) return;
			updateCurrentRenderer();
			var renderer:IRenderer2D = IRenderer2D(event.component);
			_view.renderer = renderer;
		}
		
		private function componentRemovedHandler( event:ComponentEvent ):void
		{
			if ( event.component is IRenderer == false ) return;
			updateCurrentRenderer();
			_view.renderer = null;
		}
		
		private function updateCurrentRenderer():void
		{
			var oldRenderer:Renderer2D = Renderer2D(_view.renderer);
			
			if ( oldRenderer )
			{
				_pickingManager.disableMouseListeners(oldRenderer.viewport);
				//_view.addOverlay(selectionOverlay);
				oldRenderer.removeOverlay(selectionOverlay);
				_view.renderer = null;
				_toolManager.disable();
			}
			
			var newRenderer:Renderer2D;
			var renderers:Vector.<IComponent> = ComponentUtil.getChildrenOfType(scene, Renderer2D, true);
			if ( renderers.length > 0 )
			{
				newRenderer = Renderer2D(renderers[0]);
				newRenderer.addOverlay(selectionOverlay);
				
				_view.renderer = newRenderer;
				_view.renderer.addEventListener( RendererEvent.INITIALISED, rendererInitialised );
				_toolManager.enable();
			} else {
				_toolManager.disable();
			}
						
			
//			var renderers:Vector.<IComponent> = ComponentUtil.getChildrenOfType(scene, IRenderer2D, true);
//			if ( renderers.length == 0 )
//			{
//				_view.renderer = null;
//				_toolManager.disable();
//			}
//			else
//			{
//				_toolManager.enable();
//				_view.renderer = IRenderer2D(renderers[0]);
//			}			
		}
		
		private function rendererInitialised( event:RendererEvent ):void
		{
			var renderer:Renderer2D = Renderer2D(_view.renderer);
			renderer.removeEventListener( RendererEvent.INITIALISED, rendererInitialised );
			_pickingManager.enableMouseListeners( renderer.viewport );
			renderer.addOverlay(selectionOverlay);
		}
		
		private function bindingChangeHandler( event:PropertyChangeEvent ):void
		{
			changed = true;
		}
		
		public function getControllerOfType( type:Class ):ICadetContextController
		{
			for ( var i:uint = 0; i < _controllers.length; i ++ )
			{
				var controller:ICadetContextController = _controllers[i];
				if ( controller is type ) return controller;
			}
			
			return null;
		}
		
		// Getters for  managers
		public function get view2D():ICadetEditorView2D { return _view; }
		public function get snapManager():SnapManager2D { return _snapManager; }
		public function get pickingManager():IPickingManager2D { return _pickingManager; }
		public function get highlightManager():IComponentHighlightManager { return _highlightManager; }
	}
}