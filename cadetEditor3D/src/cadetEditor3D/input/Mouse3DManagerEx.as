package cadetEditor3D.input
{
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.pick.IPicker;
	import away3d.core.pick.PickingCollisionVO;
	import away3d.core.pick.PickingType;
	import away3d.entities.Entity;
	
	import cadetEditor3D.events.MouseEvent3DEx;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	use namespace arcane;

	/**
	 * Mouse3DManager enforces a singleton pattern and is not intended to be instanced.
	 * it provides a manager class for detecting 3D mouse hits on View3D objects and sending out 3D mouse events.
	 */
	public class Mouse3DManagerEx extends EventDispatcher
	{
		private var _activeView : View3D;
		private var _updateDirty : Boolean;
		private var _nullVector : Vector3D = new Vector3D();
		protected var _collidingObject : PickingCollisionVO;
		private var _previousCollidingObject : PickingCollisionVO;
		private var _queuedEvents : Vector.<MouseEvent3DEx> = new Vector.<MouseEvent3DEx>();

		private var _mouseMoveEvent : MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);

		private static var _mouseUp : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.MOUSE_UP);
		private static var _mouseClick : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.CLICK);
		private static var _mouseOut : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.MOUSE_OUT);
		private static var _mouseDown : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.MOUSE_DOWN);
		private static var _mouseMove : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.MOUSE_MOVE);
		private static var _mouseOver : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.MOUSE_OVER);
		private static var _mouseWheel : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.MOUSE_WHEEL);
		private static var _mouseDoubleClick : MouseEvent3DEx = new MouseEvent3DEx(MouseEvent3DEx.DOUBLE_CLICK);
		private var _forceMouseMove : Boolean;
		//private var _mousePicker : IPicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
		private var _mousePicker:RaycastPicker = new RaycastPicker( true );
		
		//TODO: Rob added
		private var _previouslyActiveEntities:Vector.<Entity>;
		private var _activeEntities:Vector.<Entity>;
		private var _view:View3D;
		
		/**
		 * Creates a new <code>Mouse3DManager</code> object.
		 */
		public function Mouse3DManagerEx()
		{
			_activeEntities = new Vector.<Entity>();
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function updateCollider(view : View3D) : void
		{
			_previousCollidingObject = _collidingObject;

			//TODO: Rob added
			_previouslyActiveEntities = _activeEntities.slice();
			
			if (view == _activeView && (_forceMouseMove || _updateDirty)) { // If forceMouseMove is off, and no 2D mouse events dirtied the update, don't update either.
				_collidingObject = _mousePicker.getViewCollision(view.mouseX, view.mouseY, view);
				
				_activeEntities = new Vector.<Entity>();
				_activeEntities = _activeEntities.concat(_mousePicker.entityCollisions); //Rob added
			}

			_updateDirty = false;
		}

		public function fireMouseEvents() : void
		{
			var i : uint;
			var len : uint;
			var event : MouseEvent3DEx;
			//TODO: Rob changed so that Mouse3DManager fires all events
			//var dispatcher : ObjectContainer3D;
			var dispatcher : Mouse3DManagerEx = this;
			
			//TODO: Rob added - Determine mouse over events
			var mousedOverEntities:Vector.<Entity> = new Vector.<Entity>();
			for each ( var activeEntity:Entity in _activeEntities ) 
			{
				if ( _previouslyActiveEntities.indexOf(activeEntity) == -1 ) {
					mousedOverEntities.push(activeEntity);
				}
			}
			if ( mousedOverEntities.length > 0 ) {
				queueDispatch(_mouseOver, _mouseMoveEvent, mousedOverEntities);
			}
			
			// TODO: Rob added - Determine mouse out events
			var mousedOutEntities:Vector.<Entity> = new Vector.<Entity>();
			for each ( var previouslyActiveEntity:Entity in _previouslyActiveEntities )
			{
				if ( _activeEntities.indexOf(previouslyActiveEntity) == -1 ) {
					mousedOutEntities.push(previouslyActiveEntity);
				}
			}
			if ( mousedOutEntities.length > 0 ) {
				queueDispatch(_mouseOut, _mouseMoveEvent, mousedOutEntities);
			}
			
			// If colliding object has changed, queue over/out events.
//			if (_collidingObject != _previousCollidingObject) {
//				if (_previousCollidingObject) queueDispatch(_mouseOut, _mouseMoveEvent, _previousCollidingObject);
//				if (_collidingObject) queueDispatch(_mouseOver, _mouseMoveEvent, _collidingObject);
//			}

			// Fire mouse move events here if forceMouseMove is on.
			if (_forceMouseMove && _collidingObject) {
				//queueDispatch(_mouseMove, _mouseMoveEvent, _collidingObject);
				queueDispatch(_mouseMove, _mouseMoveEvent, _activeEntities);
			}

			// Dispatch all queued events.
			len = _queuedEvents.length;
			for (i = 0; i < len; ++i) {
				// Only dispatch from first implicitly enabled object ( one that is not a child of a mouseChildren = false hierarchy ).
				event = _queuedEvents[i];
//				dispatcher = event.object;
//
//				while (dispatcher && !dispatcher._ancestorsAllowMouseEnabled)
//					dispatcher = dispatcher.parent;
//
//				if (dispatcher)
					dispatcher.dispatchEvent(event);
			}
			_queuedEvents.length = 0;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function queueDispatch(event : MouseEvent3DEx, sourceEvent : MouseEvent, entities:Vector.<Entity> = null):void// collider : PickingCollisionVO = null) : void
		{
			// 2D properties.
			event.ctrlKey = sourceEvent.ctrlKey;
			event.altKey = sourceEvent.altKey;
			event.shiftKey = sourceEvent.shiftKey;
			event.delta = sourceEvent.delta;
			event.screenX = sourceEvent.localX;
			event.screenY = sourceEvent.localY;

			if (!entities) entities = new Vector.<Entity>();
			event.entities = entities;
			
			//trace("EVENT "+event.type+" entities "+entities);
			
			//collider ||= _collidingObject;
			var collider:PickingCollisionVO = _collidingObject;
			
			// 3D properties.
			if( collider ) {
				// Object.
				event.object = collider.entity;
				event.renderable = collider.renderable;
				// UV.
				event.uv = collider.uv;
				// Position.
				event.localPosition = collider.localPosition.clone();
				// Normal.
				event.localNormal = collider.localNormal.clone();
			}
			else {
				// Set all to null.
				event.uv = null;
				event.object = null;
				event.localPosition = _nullVector;
				event.localNormal = _nullVector;
			}
			
			// Store event to be dispatched later.
			_queuedEvents.push(event);
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onMouseMove(event : MouseEvent) : void
		{
//			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseMove, _mouseMoveEvent = event, _activeEntities);
			_updateDirty = true;
		}

		private function onMouseOut(event : MouseEvent) : void
		{
			_activeView = null;
//			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseOut, event, _activeEntities);//, _collidingObject);
			_updateDirty = true;
		}

		private function onMouseOver(event : MouseEvent) : void
		{
			_activeView = (event.currentTarget as View3D);
//			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseOver, event, _activeEntities);//, _collidingObject);
			_updateDirty = true;
		}

		private function onClick(event : MouseEvent) : void
		{
			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseClick, event, _activeEntities);
			_updateDirty = true;
		}

		private function onDoubleClick(event : MouseEvent) : void
		{
			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseDoubleClick, event, _activeEntities);
			_updateDirty = true;
		}

		private function onMouseDown(event : MouseEvent) : void
		{
			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseDown, event, _activeEntities);
			_updateDirty = true;
		}

		private function onMouseUp(event : MouseEvent) : void
		{
			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseUp, event, _activeEntities);
			_updateDirty = true;
		}

		private function onMouseWheel(event : MouseEvent) : void
		{
			//if (_collidingObject) 
			if (mouseInView())		queueDispatch(_mouseWheel, event, _activeEntities);
			_updateDirty = true;
		}

		public function enableMouseListeners(view : View3D) : void
		{
			_view = view; //Rob added
			view.addEventListener(MouseEvent.CLICK, onClick);
			view.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			view.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			view.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			view.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			view.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}

		public function disableMouseListeners(view : View3D) : void
		{
			_view = null; //Rob added
			view.removeEventListener(MouseEvent.CLICK, onClick);
			view.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			view.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			view.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			view.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			view.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			view.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			view.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}

		public function get forceMouseMove() : Boolean
		{
			return _forceMouseMove;
		}

		public function set forceMouseMove(value : Boolean) : void
		{
			_forceMouseMove = value;
		}

		public function get mousePicker() : IPicker
		{
			return _mousePicker;
		}

		public function set mousePicker(value : IPicker) : void
		{
			//_mousePicker = value;
		}
		
		//TODO: Rob added
		public function get activeEntities():Vector.<Entity>
		{
			return _activeEntities.slice();
		}
		//TODO: Rob added
		private function mouseInView():Boolean 
		{
			var mx:Number = _view.mouseX;
			var my:Number = _view.mouseY;
			return mx >= 0 && my >= 0 && mx < _view.width && my < _view.height;
		}
	}
}