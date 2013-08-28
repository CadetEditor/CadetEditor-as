// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.input
{
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.EntityCollector;
	import away3d.entities.Entity;
	
	import cadetEditor3D.events.DetailedMouse3DEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	[Event(name="mouseOver", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	[Event(name="mouseOut", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	[Event(name="mouseUp", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	[Event(name="mouseDown", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	[Event(name="mouseMove", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	[Event(name="click", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	[Event(name="doubleClick", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	[Event(name="mouseWheel", type="cadetEditor3D.events.DetailedMouse3DEvent")]
	public class DetailedMouse3DManager extends EventDispatcher
	{
		private static var _mouseClick:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.CLICK );
		private static var _mouseDoubleClick:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.DOUBLE_CLICK );
		private static var _mouseMove:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.MOUSE_MOVE );
		private static var _mouseOver:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.MOUSE_OVER );
		private static var _mouseOut:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.MOUSE_OUT );
		private static var _mouseUp:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.MOUSE_UP );
		private static var _mouseDown:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.MOUSE_DOWN );
		private static var _mouseWheel:DetailedMouse3DEvent = new DetailedMouse3DEvent( DetailedMouse3DEvent.MOUSE_WHEEL );
		
		private var _oldLocalX:Number;
		private var _oldLocalY:Number;
		private var _oldLocalZ:Number;
		private var _opaqueCollider:Object;//DetailedMouseRaycast;
		private var _blendedCollider:Object;//DetailedMouseRaycast;
		private var _previouslyActiveEntities:Vector.<Entity>;
		private var _activeEntities:Vector.<Entity>;
		private var _view:View3D;
		private var _queuedEvents:Vector.<DetailedMouse3DEvent> = new Vector.<DetailedMouse3DEvent>();
		private var _mouseMoveEvent:MouseEvent = new MouseEvent( MouseEvent.MOUSE_MOVE );
		private var _forceMouseMove:Boolean;
		private var _proxy:Stage3DProxy;
		
		/**
		 * Creates a Mouse3DManager object.
		 * @param view The View3D object for which the mouse will be detected.
		 * @param hitTestRenderer The hitTestRenderer that will perform hit-test rendering.
		 */
		public function DetailedMouse3DManager( view:View3D = null ) 
		{
			setView(view);
			_opaqueCollider = new Object();//DetailedMouseRaycast();
			_blendedCollider = new Object();//DetailedMouseRaycast();
			_activeEntities = new Vector.<Entity>();
		}
		
		/**
		 * Clear all resources and listeners used by this Mouse3DManager.
		 */
		public function dispose():void
		{
			setView(null);
		}
		
		
		public function setView( view:View3D ):void
		{
			if ( _view )
			{
				_view.removeEventListener( MouseEvent.CLICK, onClick );
				_view.removeEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
				_view.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
				_view.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
				_view.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
				_view.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			}
			
			_view = view;
			
			if ( _view )
			{
				_view.addEventListener( MouseEvent.CLICK, onClick );
				_view.addEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
				_view.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
				_view.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
				_view.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
				_view.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			}
			
			_activeEntities = new Vector.<Entity>();
			_previouslyActiveEntities = new Vector.<Entity>();
		}

		public function get forceMouseMove():Boolean {
			return _forceMouseMove;
		}

		public function set forceMouseMove( value:Boolean ):void {
			_forceMouseMove = value;
		}
		
		public function get stage3DProxy():Stage3DProxy {
			return _proxy;
		}
		
		public function set stage3DProxy( value:Stage3DProxy ):void {
			_proxy = value;
		}

		public function isMouseOver( entity:Entity ):Boolean
		{
			return _activeEntities.indexOf(entity) != -1;
		}
		
		public function get activeEntities():Vector.<Entity>
		{
			return _activeEntities.slice();
		}
		
		public function updateHitData():void 
		{
			if( !_forceMouseMove && _queuedEvents.length == 0 )
				return;
			
			var collector:EntityCollector = _view.entityCollector;
			_previouslyActiveEntities = _activeEntities.slice();
			_activeEntities = new Vector.<Entity>();
			if( collector.numMouseEnableds > 0 && mouseInView() ) 
			{
				var rayPosition:Vector3D = _view.camera.position;
				var rayDirection:Vector3D = _view.unproject( _view.mouseX, _view.mouseY, 0 );
				_opaqueCollider.updateRay( rayPosition, rayDirection );
				_blendedCollider.updateRay( rayPosition, rayDirection );
				_opaqueCollider.updateTarget(collector.opaqueRenderableHead)
				_opaqueCollider.evaluate();
				_blendedCollider.updateTarget(collector.blendedRenderableHead);
				_blendedCollider.evaluate();
				_activeEntities = _activeEntities.concat(_opaqueCollider.entityCollisions);
				_activeEntities = _activeEntities.concat(_blendedCollider.entityCollisions);
			}
		}
		
		public function getCollisionPoint( entity:Entity ):Vector3D
		{
			return _opaqueCollider.getCollisionPoint(entity) || _blendedCollider.getCollisionPoint(entity);
		}
		
		public function getCollisionUV( entity:Entity ):Point
		{
			return _opaqueCollider.getCollisionUV(entity) || _blendedCollider.getCollisionUV(entity);
		}
		
		public function fireMouseEvents():void 
		{
			// Determine mouse over events
			var mousedOverEntities:Vector.<Entity> = new Vector.<Entity>();
			for each ( var activeEntity:Entity in _activeEntities )
			{
				if ( _previouslyActiveEntities.indexOf(activeEntity) == -1 )
				{
					mousedOverEntities.push(activeEntity);
				}
			}
			if ( mousedOverEntities.length > 0 )
			{
				queueDispatch(_mouseOver, _mouseMoveEvent, mousedOverEntities);
			}
			
			// Determine mouse out events
			var mousedOutEntities:Vector.<Entity> = new Vector.<Entity>();
			for each ( var previouslyActiveEntity:Entity in _previouslyActiveEntities )
			{
				if ( _activeEntities.indexOf(previouslyActiveEntity) == -1 )
				{
					mousedOutEntities.push(previouslyActiveEntity);
				}
			}
			if ( mousedOutEntities.length > 0 )
			{
				queueDispatch(_mouseOut, _mouseMoveEvent, mousedOutEntities);
			}
			
			var len:uint = _queuedEvents.length;
			for( var i:uint = 0; i < len; ++i )
				dispatchEvent( _queuedEvents[i] );
			_queuedEvents.length = 0;
		}
		
		///////////////////////////////////////////////
		// Private
		///////////////////////////////////////////////

		private function mouseInView():Boolean 
		{
			var mx:Number = _view.mouseX;
			var my:Number = _view.mouseY;
			return mx >= 0 && my >= 0 && mx < _view.width && my < _view.height;
		}

		/**
		 * Sends out a MouseEvent3D based on the MouseEvent that triggered it on the Stage.
		 * @param event3D The MouseEvent3D that will be dispatched.
		 * @param sourceEvent The MouseEvent that triggered the dispatch.
		 * @param renderable The IRenderable object that is the subject of the MouseEvent3D.
		 */
		/*
		private function dispatch( event3D:MouseEvent3D ):void 
		{
			var renderable:IRenderable;
			// assign default renderable if it wasn't provide on queue time
			if( !(renderable = (event3D.renderable ||= _activeRenderable)) ) return;
			
			var local:Vector3D;
			var scene:Vector3D;
			
			event3D.material = renderable.material;
			event3D.object = renderable.sourceEntity;
			
			if( _activeCollider && renderable.mouseHitMethod == MouseHitMethod.MESH_CLOSEST_HIT ) {
				event3D.uv = _activeCollider.collisionUV;
			}
			else {
				event3D.uv = null;
			}
			
			if( _activeCollider ) {
				local = _activeCollider.collisionPoint;
				event3D.localX = local.x;
				event3D.localY = local.y;
				event3D.localZ = local.z;
				scene = _activeCollider.entity.transform.transformVector(local);
				event3D.sceneX = scene.x;
				event3D.sceneY = scene.y;
				event3D.sceneZ = scene.z;
			}
			else {
				event3D.localX = -1;
				event3D.localY = -1;
				event3D.localZ = -1;
				event3D.sceneX = -1;
				event3D.sceneY = -1;
				event3D.sceneZ = -1;
			}
			
			// only dispatch from first implicitly enabled object (one that is not a child of a mouseChildren=false hierarchy)
			var dispatcher:ObjectContainer3D = renderable.sourceEntity;
			
			while(dispatcher && !dispatcher._implicitMouseEnabled) dispatcher = dispatcher.parent;
			dispatcher.dispatchEvent( event3D );
		}
		*/
		
		
		private function queueDispatch( event:DetailedMouse3DEvent, sourceEvent:MouseEvent, entities:Vector.<Entity> ):void 
		{
			event.ctrlKey = sourceEvent.ctrlKey;
			event.altKey = sourceEvent.altKey;
			event.shiftKey = sourceEvent.shiftKey;
			event.entities = entities;
			event.delta = sourceEvent.delta;
			event.screenX = _view.stage.mouseX;
			event.screenY = _view.stage.mouseY;
			_queuedEvents.push( event );
		}
		
		/////////////////////////////////////////
		// Event Handlers
		/////////////////////////////////////////
		
		private function onMouseMove( event:MouseEvent ):void {
			if( !_forceMouseMove )
				queueDispatch( _mouseMove, event, _activeEntities );
		}
		
		/**
		 * Called when the mouse clicks on the stage.
		 */
		private function onClick( event:MouseEvent ):void {
			if( mouseInView() )
				queueDispatch( _mouseClick, event, _activeEntities );
		}
		
		/**
		 * Called when the mouse double-clicks on the stage.
		 */
		private function onDoubleClick( event:MouseEvent ):void {
			if( mouseInView() )
				queueDispatch( _mouseDoubleClick, event,_activeEntities );
		}

		/**
		 * Called when a mouseDown event occurs on the stage
		 */
		private function onMouseDown( event:MouseEvent ):void {
			if( mouseInView() )
				queueDispatch( _mouseDown, event, _activeEntities );
		}

		/**
		 * Called when a mouseUp event occurs on the stage
		 */
		private function onMouseUp( event:MouseEvent ):void {
			if( mouseInView() )
				queueDispatch( _mouseUp, event, _activeEntities );
		}

		/**
		 * Called when a mouseWheel event occurs on the stage
		 */
		private function onMouseWheel( event:MouseEvent ):void {
			if( mouseInView() )
				queueDispatch( _mouseWheel, event, _activeEntities );
		}
	}
}