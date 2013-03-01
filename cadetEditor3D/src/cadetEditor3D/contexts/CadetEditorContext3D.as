// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.contexts
{
	import cadet.core.IComponent;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	import cadet3D.components.renderers.Renderer3D;
	import cadet3D.events.Renderer3DEvent;
	
	import cadetEditor.contexts.AbstractTooledCadetEditorContext;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.controllers.ICadetContextController;
	
	import cadetEditor3D.events.CadetEditorContext3DEvent;
	import cadetEditor3D.events.RendererChangeEvent;
	import cadetEditor3D.input.Mouse3DManagerEx;
	import cadetEditor3D.ui.views.CadetEditorView3D;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import flox.app.FloxApp;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.IFactoryResource;
	import flox.editor.FloxEditor;
	
	[Event(name="rendererChange", type="cadetEditor3D.events.RendererChangeEvent")]
	public class CadetEditorContext3D extends AbstractTooledCadetEditorContext implements ICadetEditorContext
	{
		public static const COORDINATE_SPACE_WORLD	:String = "world";
		public static const COORDINATE_SPACE_LOCAL	:String = "local";
		public static const COORDINATE_SPACE_SCREEN	:String = "screen";
		
		private var _view				:CadetEditorView3D;
		
		protected var _pickingManager		:Mouse3DManagerEx;
		private var _coordinateSpace		:String = COORDINATE_SPACE_WORLD;
		
		protected var _controllers			:Array;
		
		public function CadetEditorContext3D()
		{
			_view = new CadetEditorView3D(this);
			_view.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
			
			_pickingManager = new Mouse3DManagerEx();
			
			_controllers = [];
			
			initTools(_view);
		}
		
		protected function addedToStageHandler( event:Event ):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			initControllers();
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
		
		override public function dispose():void
		{
			_view.dispose();
			super.dispose();
		}
		
		////////////////////////////////////////////
		// Public
		////////////////////////////////////////////
		
		public function set coordinateSpace( value:String ):void
		{
			if ( value == _coordinateSpace ) return;
			if ( 	value != COORDINATE_SPACE_WORLD &&
					value != COORDINATE_SPACE_LOCAL &&
					value != COORDINATE_SPACE_SCREEN )
			{
				throw( new Error( "Invalid coordinate space" ) ) ;
			}
			
			_coordinateSpace = value;
			dispatchEvent( new CadetEditorContext3DEvent( CadetEditorContext3DEvent.COORDINATE_SPACE_CHANGE ) );
		}
		
		/* Implement IVisualContext */
		
		override public function get view():DisplayObject
		{
			return _view;
		}
		
		/* Implement IEditorContext */
		override public function enable():void
		{
			super.enable();
			_view.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			if ( renderer ) {
				FloxEditor.stage.stage3Ds[renderer.view3D.stage3DProxy.stage3DIndex].visible = true;
			}
		}
		
		override public function disable():void
		{
			super.disable();
			_view.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			if ( renderer ) {
				FloxEditor.stage.stage3Ds[renderer.view3D.stage3DProxy.stage3DIndex].visible = false;
			}
		}
		
		public function get view3D():CadetEditorView3D
		{
			return _view;
		}
		
		public function get renderer():Renderer3D
		{
			return _view.renderer;
		}
		
		////////////////////////////////////////////
		// Event handlers
		////////////////////////////////////////////
		
		private function enterFrameHandler( event:Event ):void
		{
			if ( !_scene ) return;
			// Only validate scene if view is on the stage (or the Away3DRenderer will error).
			if ( _view.stage == null ) return;
			_scene.validateNow();
		}
		
		private function componentAddedHandler( event:ComponentEvent ):void
		{
			if ( event.component is Renderer3D == false ) return;
			updateCurrentRenderer();
			var renderer:Renderer3D = Renderer3D(event.component);
			_view.renderer = renderer;
		}
		
		private function componentRemovedHandler( event:ComponentEvent ):void
		{
			if ( event.component is Renderer3D == false ) return;
			updateCurrentRenderer();
			_view.renderer = null;
		}
		
		private function preRenderHandler( event:Renderer3DEvent ):void
		{
//			_detailedMouse3DManager.updateHitData();
//			_detailedMouse3DManager.fireMouseEvents();
			
			// update picking
			if (_view.renderer) {
				_pickingManager.updateCollider(_view.renderer.view3D);
			}
		}
		private function postRenderHandler( event:Renderer3DEvent ):void
		{
			// fire collected mouse events
			_pickingManager.fireMouseEvents();			
		}
		
		////////////////////////////////////////////
		// Base class overrides
		////////////////////////////////////////////
		
		override protected function initScene():void
		{
			updateCurrentRenderer();
			
			_scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
			_scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
		}
		
		override protected function disposeScene():void
		{
			_scene.removeEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
			_scene.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
		}
		
		////////////////////////////////////////////
		// Private
		////////////////////////////////////////////
		
		private function updateCurrentRenderer():void
		{
			var oldRenderer:Renderer3D = _view.renderer;
			
			if ( oldRenderer )
			{
				oldRenderer.removeEventListener(Renderer3DEvent.PRE_RENDER, preRenderHandler);
				newRenderer.removeEventListener(Renderer3DEvent.POST_RENDER, postRenderHandler);
				
				//_pickingManager.setView(null);
				_pickingManager.disableMouseListeners(oldRenderer.view3D);
				_view.renderer = null;
			}
			
			var newRenderer:Renderer3D
			var renderers:Vector.<IComponent> = ComponentUtil.getChildrenOfType(scene, Renderer3D, true);
			if ( renderers.length > 0 )
			{
				newRenderer = Renderer3D(renderers[0]);
				_view.renderer = newRenderer;
				
				_pickingManager.enableMouseListeners(newRenderer.view3D);
				//_pickingManager.setView(newRenderer.view3D);
				
				newRenderer.addEventListener(Renderer3DEvent.PRE_RENDER, preRenderHandler);
				newRenderer.addEventListener(Renderer3DEvent.POST_RENDER, postRenderHandler);
			}
			
			dispatchEvent( new RendererChangeEvent( RendererChangeEvent.RENDERER_CHANGE, oldRenderer, newRenderer ) );
		}
		
		// Getters for  managers
		public function get pickingManager():Mouse3DManagerEx { return _pickingManager; }
	}
}







