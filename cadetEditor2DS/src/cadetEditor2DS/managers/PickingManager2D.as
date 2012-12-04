// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.managers
{
	import cadet.core.ICadetScene;
	import cadet.core.IComponent;
	import cadet.core.IRenderer;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.managers.IPickingManager2D;
	import cadetEditor2D.managers.SnapInfo;
	import cadetEditor2D.managers.SnapManager2D;
	import cadetEditor2D.util.BitmapHitTest;
	import cadetEditor2D.util.BitmapHitTestStarling;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flox.editor.FloxEditor;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseDownBackground" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="clickBackground" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseDownSkins" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="clickSkins" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseMoveContainer" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseDownContainer" )]
	
	public class PickingManager2D extends EventDispatcher implements IPickingManager2D
	{
		private var _snapManager	:SnapManager2D;
		
		private var scene			:ICadetScene;
		private var skinsUnderMouse	:Array;
		private var enabled			:Boolean = false;
		
		private var _view			:DisplayObjectContainer;
		
		private var allSkins		:Vector.<IComponent>;
		private var renderer		:Renderer2D;
		
		private var _mouseX			:Number;
		private var _mouseY			:Number;
		
		public function PickingManager2D()
		{
			allSkins = new Vector.<IComponent>();
		}
		
		public function enable():void
		{
			if ( enabled ) return;
			enabled = true;
		}
		
		public function disable():void
		{
			if ( !enabled ) return;
			enabled = false;
			
			//setView(null);
		}
		
		public function dispose():void
		{
			disable();
			setScene(null);
		}
		
		
		public function setScene( value:ICadetScene ):void
		{
			if ( scene )
			{
				scene.removeEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
				scene.removeEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
				allSkins = new Vector.<IComponent>();
				renderer = null;
			}
			
			scene = value;
			
			if ( scene )
			{
				scene.addEventListener(ComponentEvent.ADDED_TO_SCENE, componentAddedHandler);
				scene.addEventListener(ComponentEvent.REMOVED_FROM_SCENE, componentRemovedHandler);
				
				renderer = ComponentUtil.getChildOfType(scene, Renderer2D, true) as Renderer2D;
				
				allSkins = ComponentUtil.getChildrenOfType(scene, ISkin2D, true);
			}
		}
		
		public function setView( value:DisplayObjectContainer ):void
		{
			if ( _view ) {
				_view.stage.removeEventListener(TouchEvent.TOUCH, onTouchHandler);
			}
			_view = value;
			
			if ( _view ) {
				_view.stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			}
		}
		
		private function onTouchHandler( event:TouchEvent ):void
		{
			if ( !enabled ) return;
			
			var dispObj:DisplayObject = DisplayObject(_view.stage);
			var touches:Vector.<Touch> = event.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				var location:Point = touch.getLocation(dispObj);
				if ( touch.phase == TouchPhase.BEGAN ) {
					mouseDownHandler( event, touch );
				} else if ( touch.phase == TouchPhase.ENDED ) {
					clickHandler( event, touch );
				} else if ( touch.phase == TouchPhase.HOVER ) {
					mouseMoveHandler( event, touch );
				} else if ( touch.phase == TouchPhase.MOVED ) {
					mouseDragHandler( event, touch );
				} else if ( touch.phase == TouchPhase.STATIONARY ) {
					
				}
				
				_mouseX = location.x //- _viewportX;
				_mouseY = location.y //- _viewportY;
				
				var local:Point = _view.globalToLocal(location);
				
				//trace("onTouch x "+_mouseX+" y "+_mouseY+" phase "+touch.phase);
				//trace("local x "+local.x+" y "+local.y);
				//trace("parent x "+_parent.x+" y "+_parent.y);
				break;
			}
		}
		
		public function getSkinsUnderLoc( x:Number, y:Number ):Array
		{
			if ( renderer == null ) return [];
			
			var skinsUnderLoc:Array = [];
			var L:int = 0;
			for each ( var skin:AbstractSkin2D in allSkins)
			{
				
				var pt:Point = new Point(x, y);
				//pt = renderer.viewport.localToGlobal( pt );
				pt = renderer.viewportToWorld(pt);
				if (!skin.displayObjectContainer.bounds.containsPoint(pt)) continue;
				
				skinsUnderLoc[L++] = skin;
			}
			return skinsUnderLoc;
		}
		
		public function getSkinsUnderMouse():Array
		{
			if ( renderer == null ) return [];
			if ( _snapManager )
			{
				var pt:Point = new Point( renderer.mouseX, renderer.mouseY );
				//pt = renderer.viewportToWorld(pt);
				//trace("PM2D getSkinsUnderMouse rX "+pt.x+" rY "+pt.y);
				
				//TODO: maybe shouldn't cop out here due to Starling...
				if (!pt) return [];
				
				var snapInfo:SnapInfo = _snapManager.snapPoint( pt );
				//pt = renderer.worldToViewport( snapInfo.snapPoint );
				return getSkinsUnderLoc( pt.x, pt.y );
			}
			return getSkinsUnderLoc( renderer.mouseX, renderer.mouseY );
		}
		
		
		private function componentAddedHandler( event:ComponentEvent ):void
		{
			if ( event.component is IRenderer )
			{
				renderer = Renderer2D(event.component);
				return;
			}
			if ( event.component is ISkin2D == false ) return;
			if ( skinFilterFunc(event.component) == false ) return;
			allSkins.push(event.component);
		}
		
		private function componentRemovedHandler( event:ComponentEvent ):void
		{
			if ( event.component == renderer )
			{
				renderer = null;
				renderer = ComponentUtil.getChildOfType(scene, Renderer2D, true) as Renderer2D;
				return;
			}
			if ( event.component is ISkin2D == false ) return;
			if ( skinFilterFunc(event.component) == false ) return;
			allSkins.splice(allSkins.indexOf(event.component),1);
		}
		
		private function sendEvent( type:String, skinsUnderMouse:Array, skin:ISkin2D = null, touchEvent:TouchEvent = null, touch:Touch = null ):void
		{
			var altKey:Boolean = false;
			var buttonDown:Boolean = false;
			
			if ( touchEvent ) {
				var ctrlKey:Boolean = touchEvent.ctrlKey;
				var shiftKey:Boolean = touchEvent.shiftKey;
			}
			if ( touch ) {
				var globalX:Number = touch.globalX;
				var globalY:Number = touch.globalY;
			}
			
			dispatchEvent( new PickingManagerEvent( type, skinsUnderMouse, skin, globalX, globalY, ctrlKey, altKey, shiftKey, buttonDown ) );
		}
		
		private function mouseDownHandler(event:TouchEvent, touch:Touch):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			
			if ( currentSkinsUnderMouse.length == 0 )
			{
				sendEvent( PickingManagerEvent.MOUSE_DOWN_BACKGROUND, currentSkinsUnderMouse, null, event, touch );
			}
			else
			{
				sendEvent( PickingManagerEvent.MOUSE_DOWN_SKINS, currentSkinsUnderMouse, null, event, touch );
			}
			sendEvent( PickingManagerEvent.MOUSE_DOWN_CONTAINER, currentSkinsUnderMouse, null, event, touch );
		}
		
		private function clickHandler(event:TouchEvent, touch:Touch):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			
			if ( currentSkinsUnderMouse.length == 0 )
			{
				sendEvent( PickingManagerEvent.CLICK_BACKGROUND, currentSkinsUnderMouse, null, event, touch );
			}
			else
			{
				sendEvent( PickingManagerEvent.CLICK_SKINS, currentSkinsUnderMouse, null, event, touch );
			}
		}
		
		private function mouseMoveHandler( event:TouchEvent, touch:Touch ):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			if ( skinsUnderMouse == null )
			{
				skinsUnderMouse = [];
			}
			
			sendEvent( PickingManagerEvent.MOUSE_MOVE_CONTAINER, currentSkinsUnderMouse, null, event, touch );
			skinsUnderMouse = currentSkinsUnderMouse;
		}
		
		private function mouseDragHandler( event:TouchEvent, touch:Touch ):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			if ( skinsUnderMouse == null )
			{
				skinsUnderMouse = [];
			}
			
			sendEvent( PickingManagerEvent.MOUSE_DRAG_CONTAINER, currentSkinsUnderMouse, null, event, touch );
			skinsUnderMouse = currentSkinsUnderMouse;
		}
		
		private function skinFilterFunc( item:* ):Boolean
		{
			if ( item.displayObjectContainer == null ) return false;
			
//			if ( item.displayObjectContainer is InteractiveObject )
//			{
//				if ( InteractiveObject(item.displayObjectContainer).mouseEnabled == false ) return false;
//			}
			return true;
		}
		
		public function get snapManager():SnapManager2D
		{
			return _snapManager;
		}
		public function set snapManager( value:SnapManager2D ):void
		{
			_snapManager = value;
		}
	}
}