// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

// The little X that sits in the top left of your drag box
package cadetEditor2DStarling.ui.overlays
{
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D;
	
	import cadetEditor2D.ui.overlays.ICadetEditorOverlay2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	import cadetEditor2D.util.FlashStarlingInteropUtil;
	import cadetEditor2D.util.SelectionUtil;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flox.core.data.ArrayCollection;
	import flox.core.events.ArrayCollectionEvent;
	
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Shape;
	
	public class SelectionOverlay extends Shape //implements ICadetEditorOverlay2D
	{
		private var _view					:ICadetEditorView2D;
		private var selectedSkins			:Array
		private var _selection				:ArrayCollection;
		
		private static var pt				:Point = new Point();
		
		private static const CROSS_SIZE		:int = 2;
		private static const BRACKET_SIZE	:int = 12;
		
		public function SelectionOverlay()
		{
//			blendMode = BlendMode.DIFFERENCE;
//			mouseEnabled = false;
//			mouseChildren = false;
			//blendMode = BlendMode.ERASE
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
			
			invalidate();
		}
		public function get selection():ArrayCollection { return _selection; }
		
		
		
		private function clearSelection():void
		{
			for each ( var skin:ISkin2D in selectedSkins )
			{
				skin.removeEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
			}
			selectedSkins = [];
		}
		
		private function invalidate():void
		{
			validate();
		}
		
		private function validate():void
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
				var displayObject:DisplayObject = skin.displayObjectContainer;
	
				if ( isVisible( displayObject ) == false ) continue;
					
				var bounds:Rectangle = displayObject.bounds;				
				
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
				
				graphics.lineStyle(2, 0x00FF00);
				graphics.moveTo( pt.x-CROSS_SIZE, pt.y-CROSS_SIZE );
				graphics.lineTo( pt.x+CROSS_SIZE, pt.y+CROSS_SIZE );
				graphics.moveTo( pt.x+CROSS_SIZE, pt.y-CROSS_SIZE );
				graphics.lineTo( pt.x-CROSS_SIZE, pt.y+CROSS_SIZE );
			}
		}
		
		private function invalidateSkinHandler( event:InvalidationEvent ):void
		{
			invalidate();
		}
		
		private function selectionChangedHandler(event:ArrayCollectionEvent):void
		{
			invalidate();
		}

		private static function isVisible( displayObject:DisplayObject ):Boolean
		{
			if ( displayObject.visible == false ) return false;
			if ( displayObject.parent == null ) return true;
			return isVisible( displayObject.parent );
		}

	}
}