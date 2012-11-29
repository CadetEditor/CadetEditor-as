// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.managers
{
	import cadet.core.ICadetScene;
	import cadet.core.IComponent;
	import cadet.core.IRenderer;
	import cadet.events.ComponentEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.renderPipeline.flash.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D;
	
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.managers.IPickingManager2D;
	import cadetEditor2D.managers.SnapInfo;
	import cadetEditor2D.managers.SnapManager2D;
	import cadetEditor2D.util.BitmapHitTest;
	import cadetEditor2D.util.BitmapHitTestStarling;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flox.editor.FloxEditor;
	
	import starling.display.DisplayObject;

	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseDownBackground" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseUpBackground" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="clickBackground" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="doubleClickBackground" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseDownSkins" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseUpSkins" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="clickSkins" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="doubleClickSkins" )]	
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="rollOverSkin" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="rollOutSkin" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseUpStage" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseMoveContainer" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseDownContainer" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="mouseUpContainer" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="clickContainer" )]
	[Event( type="cadetEditor2D.events.PickingManagerEvent", name="doubleClickContainer" )]
	
	public class PickingManager2D extends EventDispatcher implements IPickingManager2D
	{
		private var _snapManager	:SnapManager2D;
		
		private var container		:InteractiveObject;
		private var scene			:ICadetScene;
		private var skinsUnderMouse	:Array;
		private var enabled			:Boolean = false;
		
		private var allSkins		:Vector.<IComponent>;
		private var renderer		:Renderer2D;
		
		public function PickingManager2D()
		{
			allSkins = new Vector.<IComponent>();
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
		
		public function setContainer( value:InteractiveObject ):void
		{
			var wasEnabled:Boolean = enabled;
			if ( container )
			{
				disable();
			}
			
			container = value;
			
			if ( wasEnabled )
			{
				enable();
			}
		}
				
		public function enable():void
		{
			if ( enabled ) return;
			enabled = true;
			
			if ( container )
			{
				container.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true)
				container.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true)
				container.addEventListener(MouseEvent.CLICK, clickHandler, true)
				container.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler, true );
				container.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			}
			
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
		}
		
		public function disable():void
		{
			if ( !enabled ) return;
			enabled = false;
			
			if ( container )
			{
				container.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true)
				container.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true)
				container.removeEventListener(MouseEvent.CLICK, clickHandler, true)
				container.removeEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler, true );
				container.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			}
			
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
		}
		
		public function dispose():void
		{
			disable();
			setScene(null);
			setContainer(null);
		}
		
		public function getSkinsUnderLoc( x:Number, y:Number ):Array
		{
			if ( renderer == null ) return [];
			
			var skinsUnderLoc:Array = [];
			var L:int = 0;
			for each ( var skin:AbstractSkin2D in allSkins)
			{
				if ( !BitmapHitTest.hitTestPoint( x, y, skin.displayObjectContainer, renderer.viewport ) ) continue;
				
				
				skinsUnderLoc[L++] = skin;
			}
			return skinsUnderLoc;
		}
		
		public function getSkinsUnderMouse():Array
		{
			if ( renderer == null ) return [];
			if ( _snapManager )
			{
				trace("PM2D getSkinsUnderMouse rX "+renderer.mouseX+" rY "+renderer.mouseY);
				var pt:Point = new Point( renderer.mouseX, renderer.mouseY );
				pt = renderer.viewportToWorld(pt);
				
				//TODO: maybe shouldn't cop out here due to Starling...
				if (!pt) return [];
				
				var snapInfo:SnapInfo = _snapManager.snapPoint( pt );
				pt = renderer.worldToViewport( snapInfo.snapPoint );
				return getSkinsUnderLoc( pt.x, pt.y );
			}
			return getSkinsUnderLoc( renderer.mouseX, renderer.mouseY );
		}
		
		
		private function componentAddedHandler( event:ComponentEvent ):void
		{
			if ( event.component is Renderer2D )
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
		
		private function sendEvent( type:String, skinsUnderMouse:Array, skin:ISkin2D, mouseEvent:MouseEvent ):void
		{
			dispatchEvent( new PickingManagerEvent( type, skinsUnderMouse, skin, mouseEvent.localX, mouseEvent.localY, mouseEvent.ctrlKey, mouseEvent.altKey, mouseEvent.shiftKey, mouseEvent.buttonDown ) );
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			
			if ( currentSkinsUnderMouse.length == 0 )
			{
				sendEvent( PickingManagerEvent.MOUSE_DOWN_BACKGROUND, currentSkinsUnderMouse, null, event );
			}
			else
			{
				sendEvent( PickingManagerEvent.MOUSE_DOWN_SKINS, currentSkinsUnderMouse, null, event );
			}
			sendEvent( PickingManagerEvent.MOUSE_DOWN_CONTAINER, currentSkinsUnderMouse, null, event );
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			
			if ( currentSkinsUnderMouse.length == 0 )
			{
				sendEvent( PickingManagerEvent.MOUSE_UP_BACKGROUND, currentSkinsUnderMouse, null, event );
			}
			else
			{
				sendEvent( PickingManagerEvent.MOUSE_UP_SKINS, currentSkinsUnderMouse, null, event );
			}
			sendEvent( PickingManagerEvent.MOUSE_UP_CONTAINER, currentSkinsUnderMouse, null, event );
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			
			if ( currentSkinsUnderMouse.length == 0 )
			{
				sendEvent( PickingManagerEvent.CLICK_BACKGROUND, currentSkinsUnderMouse, null, event );
			}
			else
			{
				sendEvent( PickingManagerEvent.CLICK_SKINS, currentSkinsUnderMouse, null, event );
			}
			sendEvent( PickingManagerEvent.CLICK_CONTAINER, currentSkinsUnderMouse, null, event );
		}
		
		private function doubleClickHandler(event:MouseEvent):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			
			if ( currentSkinsUnderMouse.length == 0 )
			{
				sendEvent( PickingManagerEvent.DOUBLE_CLICK_BACKGROUND, currentSkinsUnderMouse, null, event );
			}
			else
			{
				sendEvent( PickingManagerEvent.DOUBLE_CLICK_SKINS, currentSkinsUnderMouse, null, event );
			}
			sendEvent( PickingManagerEvent.DOUBLE_CLICK_CONTAINER, currentSkinsUnderMouse, null, event );
		}
		
		private function mouseUpStageHandler( event:MouseEvent ):void
		{			
			sendEvent( PickingManagerEvent.MOUSE_UP_STAGE, getSkinsUnderMouse(), null, event );
		}
		
		
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			var currentSkinsUnderMouse:Array = getSkinsUnderMouse();
			if ( skinsUnderMouse == null )
			{
				skinsUnderMouse = [];
			}
			
			// Compare this raycast to previous raycasts to simulate rollover's and rollout's
			var skin:ISkin2D;
			for each ( skin in currentSkinsUnderMouse )
			{
				if ( skinsUnderMouse.indexOf( skin ) == -1 )
				{
					sendEvent( PickingManagerEvent.ROLL_OVER_SKIN, currentSkinsUnderMouse, skin, event );
				}
			}
			
			for each ( skin in skinsUnderMouse )
			{
				if ( currentSkinsUnderMouse.indexOf( skin ) == -1 )
				{
					sendEvent( PickingManagerEvent.ROLL_OUT_SKIN, currentSkinsUnderMouse, skin, event );
				}
			}
			
			sendEvent( PickingManagerEvent.MOUSE_MOVE_CONTAINER, currentSkinsUnderMouse, null, event );
			skinsUnderMouse = currentSkinsUnderMouse;
		}
		
		
		
		private function skinFilterFunc( item:* ):Boolean
		{
			if ( item.displayObjectContainer == null ) return false;
			
			if ( item.displayObjectContainer is InteractiveObject )
			{
				if ( InteractiveObject(item.displayObjectContainer).mouseEnabled == false ) return false;
			}
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