// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

// The curved selection box corners and the little X that sits in the top left of your drag box
package cadetEditor2DS.ui.overlays
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cadet.events.RendererEvent;
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.IRenderable;
	import cadet2D.overlays.Overlay;
	
	import cadetEditor2D.util.SelectionUtil;
	
	import core.data.ArrayCollection;
	import core.events.ArrayCollectionEvent;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class SelectionOverlay extends Overlay
	{
		private var selectedSkins			:Array;
		private var _selection				:ArrayCollection;
		
		private static var pt				:Point = new Point();
		
		private static const CROSS_SIZE		:int = 2;
		private static const BRACKET_SIZE	:int = 12;
		
		private var _renderer				:Renderer2D;
		
		public function SelectionOverlay()
		{
//			blendMode = BlendMode.DIFFERENCE;
			touchable = false;
		}
		
		public function set selection( value:ArrayCollection ):void
		{
			if ( _selection )
			{
				_selection.removeEventListener( ArrayCollectionEvent.CHANGE, selectionChangedHandler );
			}
			_selection = value;
			if ( _selection )
			{
				_selection.addEventListener( ArrayCollectionEvent.CHANGE, selectionChangedHandler );
			}
			
			invalidate("*");
		}
		public function get selection():ArrayCollection { return _selection; }
		
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if ( isInvalid("*") )	validateNow();
		}
		
		private function clearSelection():void
		{
			for each ( var skin:IRenderable in selectedSkins )
			{
				skin.removeEventListener(ValidationEvent.INVALIDATE, invalidateSkinHandler);
			}
			selectedSkins = [];
		}
		
		override protected function validate():void
		{
			clearSelection();
			graphics.clear();
			
			if ( !_selection ) return;
			selectedSkins = SelectionUtil.getSkinsFromComponents( _selection.source );
			
			// Validate the whole scene before updating the bounds
			if ( selectedSkins.length > 0 )
			{
				if ( selectedSkins[0].scene )
				{
					selectedSkins[0].scene.validateNow();
				}
			}
			
			for each ( var renderable:IRenderable in selectedSkins )
			{
				var displayObject:DisplayObject = renderable.displayObject;
	
				if ( isVisible( displayObject ) == false ) continue;
				// Added to avoid intermittent Starling RTE when closing run time editor window 	
				if (!commonParentCheck(displayObject, this)) continue;
				
				//var bounds:Rectangle = displayObject.bounds;				
				var bounds:Rectangle = displayObject.getBounds(this);
				
				bounds.inflate( 8,8 );
				graphics.lineStyle(2, 0xFFFFFF, 1);
				
				renderable.addEventListener(ValidationEvent.INVALIDATE, invalidateSkinHandler);
				
				graphics.moveTo( bounds.x, bounds.y+BRACKET_SIZE );
				graphics.curveTo( bounds.x, bounds.y, bounds.x+BRACKET_SIZE, bounds.y );
				
				graphics.moveTo( bounds.right, bounds.y+BRACKET_SIZE );
				graphics.curveTo( bounds.right, bounds.y, bounds.right-BRACKET_SIZE, bounds.y );
				
				graphics.moveTo( bounds.x, bounds.bottom-BRACKET_SIZE );
				graphics.curveTo( bounds.x, bounds.bottom, bounds.x+BRACKET_SIZE, bounds.bottom );
				
				graphics.moveTo( bounds.right, bounds.bottom-BRACKET_SIZE );
				graphics.curveTo( bounds.right, bounds.bottom, bounds.right-BRACKET_SIZE, bounds.bottom );
				
				pt.x = 0;
				pt.y = 0;
				
				pt = displayObject.localToGlobal(pt);				
				pt = globalToLocal(pt);
				
				graphics.lineStyle(2, 0xFFFFFF);
				graphics.moveTo( pt.x-CROSS_SIZE, pt.y-CROSS_SIZE );
				graphics.lineTo( pt.x+CROSS_SIZE, pt.y+CROSS_SIZE );
				graphics.moveTo( pt.x+CROSS_SIZE, pt.y-CROSS_SIZE );
				graphics.lineTo( pt.x-CROSS_SIZE, pt.y+CROSS_SIZE );
			}
		}
		
		private function commonParentCheck(currentObject:DisplayObject, targetSpace:DisplayObject):Boolean
		{
			// 1. find a common parent of this and the target space
			var commonParent:DisplayObject = null;
			var sAncestors:Vector.<DisplayObject> = new Vector.<DisplayObject>();

			while (currentObject)
			{
				sAncestors.push(currentObject);
				currentObject = currentObject.parent;
			}
			
			currentObject = targetSpace;
			while (currentObject && sAncestors.indexOf(currentObject) == -1)
				currentObject = currentObject.parent;
			
			sAncestors.length = 0;
			
			if (currentObject) {
				commonParent = currentObject;
				return true;
			}
			
			return false;
		}
		
		private function invalidateSkinHandler( event:ValidationEvent ):void
		{
			invalidate("*");
		}
		
		private function selectionChangedHandler(event:ArrayCollectionEvent):void
		{
			invalidate("*");
		}

		private static function isVisible( displayObject:DisplayObject ):Boolean
		{
			if ( displayObject.visible == false ) return false;
			if ( displayObject.parent == null ) return true;
			return isVisible( displayObject.parent );
		}
		
		public function get renderer():Renderer2D
		{
			return _renderer;
		}
		public function set renderer( value:Renderer2D ):void
		{
			if ( _renderer ) {
				_renderer.viewport.stage.removeEventListener(TouchEvent.TOUCH, onTouchHandler);
			}
			_renderer = value;
			
			if (!value) return;
			
			if ( _renderer && _renderer.viewport ) {
				_renderer.viewport.stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			} else {
				_renderer.addEventListener(RendererEvent.INITIALISED, rendererInitialised);
			}
		}
		
		private function rendererInitialised( event:RendererEvent ):void
		{
			_renderer.viewport.stage.addEventListener(TouchEvent.TOUCH, onTouchHandler);
		}
		
		private function onTouchHandler( event:TouchEvent ):void
		{
			var dispObj:DisplayObject = DisplayObject(_renderer.viewport.stage);
			var touches:Vector.<Touch> = event.getTouches(dispObj);
			
			for each (var touch:Touch in touches)
			{
				if ( touch.phase == TouchPhase.HOVER ) {
					invalidate("*");
					break;
				}
			}
		}

	}
}