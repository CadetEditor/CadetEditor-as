// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

// The little boxes that appear in the corners and middle of the sides of a shape when using the transform tool
package cadetEditor2DStarling.ui.overlays
{
	import cadet2D.overlays.Overlay;
	import cadet2D.components.renderers.Renderer2D;
	
	import cadetEditor2D.ui.overlays.ICadetEditorOverlay2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.display.BlendMode;
	import starling.display.Shape;
	import starling.display.Sprite;

	public class TransformOverlay extends Overlay
	{
		private var _view			:ICadetEditorView2D;
		
		public var translateArea	:Shape;
		public var rotationArea		:Shape;
			
		public var boxes			:Shape;
			public var topLeftBox		:Shape;
			public var topBox			:Shape;
			public var topRightBox		:Shape;
			public var rightBox			:Shape;
			public var bottomRightBox	:Shape;
			public var bottomBox		:Shape;
			public var bottomLeftBox	:Shape;
			public var leftBox			:Shape;
		
		public var boxesArray		:Array;
		
		// Formatting
		private var boxSize				:Number = 8;
		private var rotationThickness	:Number = 64;
		private var cornerRadius		:Number = 64;
		private var boxPadding			:Number = 0;
		
		// Data
		private var tBounds				:Rectangle;
		private var matrix				:Matrix;
		private var parentContainer		:Sprite;
		
		public var renderer				:Renderer2D;
		
		public function TransformOverlay()
		{
			init();
		}
		
		protected function init():void
		{
			boxesArray = [];
			//blendMode = BlendMode.INVERT;
			
			rotationArea = new Shape();
			addChild( rotationArea );
			
			translateArea = new Shape();
			addChild( translateArea );
			
			boxes = new Shape();
			addChild( boxes );
			
			topLeftBox 		= createBox();
			topBox 			= createBox();
			topRightBox 	= createBox();
			rightBox 		= createBox();
			bottomRightBox 	= createBox();
			bottomBox 		= createBox();
			bottomLeftBox 	= createBox();
			leftBox 		= createBox();
			
			boxes.addChild( topLeftBox );
			boxes.addChild( topBox );
			boxes.addChild( topRightBox );
			boxes.addChild( rightBox );
			boxes.addChild( bottomRightBox );
			boxes.addChild( bottomBox );
			boxes.addChild( bottomLeftBox );
			boxes.addChild( leftBox );
		}
		
		public function setData( bounds:Rectangle, matrix:Matrix ):void
		{
			this.tBounds = bounds;
			this.matrix = matrix.clone();
			invalidate("*");
			visible = true;
		}
		
		public function clear():void
		{
			tBounds = null;
			matrix = null;
			visible = false;
		}
		
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if ( isInvalid("*") )	validateNow();
		}
		
		override protected function validate():void
		{
			if ( !tBounds ) return;
			if ( !renderer ) return;
			
			var TL:Point = new Point(tBounds.x, tBounds.y);
			TL = matrix.transformPoint(TL);
			TL = renderer.worldToViewport(TL);
				
			var TR:Point = new Point(tBounds.right, tBounds.y);
			TR = matrix.transformPoint(TR);
			TR = renderer.worldToViewport(TR);
			
			var BR:Point = new Point(tBounds.right, tBounds.bottom);
			BR = matrix.transformPoint(BR);
			BR = renderer.worldToViewport(BR);
			
			var BL:Point = new Point(tBounds.x, tBounds.bottom);
			BL = matrix.transformPoint(BL);
			BL = renderer.worldToViewport(BL);
						
			rotationArea.graphics.clear();
			rotationArea.graphics.lineStyle( 40, 0x00FF00, 0.0 );//, false );
			rotationArea.graphics.moveTo(TL.x, TL.y);
			rotationArea.graphics.lineTo(TR.x, TR.y);
			rotationArea.graphics.lineTo(BR.x, BR.y);
			rotationArea.graphics.lineTo(BL.x, BL.y);
			rotationArea.graphics.lineTo(TL.x, TL.y);
			
			translateArea.graphics.clear();
			translateArea.graphics.beginFill( 0xFFFFFF, 0.0);
			translateArea.graphics.moveTo(TL.x, TL.y);
			translateArea.graphics.lineTo(TR.x, TR.y);
			translateArea.graphics.lineTo(BR.x, BR.y);
			translateArea.graphics.lineTo(BL.x, BL.y);
			translateArea.graphics.lineTo(TL.x, TL.y);
			
			
			topLeftBox.x = TL.x;
			topLeftBox.y = TL.y;
			
			topRightBox.x = TR.x;
			topRightBox.y = TR.y;
			
			bottomLeftBox.x = BL.x;
			bottomLeftBox.y = BL.y;
			
			bottomRightBox.x = BR.x;
			bottomRightBox.y = BR.y;
			
			topBox.x = TL.x * 0.5 + TR.x * 0.5;
			topBox.y = TL.y * 0.5 + TR.y * 0.5;
			
			bottomBox.x = BL.x * 0.5 + BR.x * 0.5;
			bottomBox.y = BL.y * 0.5 + BR.y * 0.5;
			
			leftBox.x = TL.x * 0.5 + BL.x * 0.5;
			leftBox.y = TL.y * 0.5 + BL.y * 0.5;
			
			rightBox.x = TR.x * 0.5 + BR.x * 0.5;
			rightBox.y = TR.y * 0.5 + BR.y * 0.5;
		}
		
		
		private function createBox():Shape
		{
			var spr:Shape = new Shape();
			spr.graphics.lineStyle(1, 0xFFFFFF);
			spr.graphics.beginFill( 0xFFFFFF, 0.0 );
			spr.graphics.drawRect( -boxSize*0.5, -boxSize*0.5, boxSize, boxSize );
			boxesArray.push( spr );
			return spr;
		}

/*
		public function get view():ICadetEditorView2D
		{
			return _view;
		}

		public function set view(value:ICadetEditorView2D):void
		{
			_view = value;
		}
*/
	}
}