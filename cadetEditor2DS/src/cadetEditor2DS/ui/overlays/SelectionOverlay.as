// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

// The curved selection box corners and the little X that sits in the top left of your drag box
package cadetEditor2DS.ui.overlays
{
	import cadet.events.InvalidationEvent;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.skins.IRenderable;
	import cadet2D.overlays.Overlay;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	
	import cadetEditor2D.util.SelectionUtil;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import core.data.ArrayCollection;
	import core.events.ArrayCollectionEvent;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class SelectionOverlay extends Overlay
	{
		private var selectedSkins			:Array
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
				skin.removeEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
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
			
			for each ( var skin:AbstractSkin2D in selectedSkins )
			{
				var displayObject:DisplayObject = skin.displayObject;
	
				if ( isVisible( displayObject ) == false ) continue;
					
				//var bounds:Rectangle = displayObject.bounds;				
				var bounds:Rectangle = displayObject.getBounds(this);
				
				bounds.inflate( 8,8 );
				graphics.lineStyle(2, 0xFFFFFF, 1);
				
				skin.addEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
				
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
		
		private function invalidateSkinHandler( event:InvalidationEvent ):void
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