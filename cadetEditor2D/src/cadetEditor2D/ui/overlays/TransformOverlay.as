// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.ui.overlays
{
	import cadetEditor2D.ui.overlays.ICadetEditorOverlay2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flox.ui.components.UIComponent;

	public class TransformOverlay extends UIComponent implements ICadetEditorOverlay2D
	{
		private var _view			:ICadetEditorView2D;
		
		public var translateArea	:Sprite;
		public var rotationArea		:Sprite;
			
		public var boxes			:Sprite;
			public var topLeftBox		:Sprite;
			public var topBox			:Sprite;
			public var topRightBox		:Sprite;
			public var rightBox			:Sprite;
			public var bottomRightBox	:Sprite;
			public var bottomBox		:Sprite;
			public var bottomLeftBox	:Sprite;
			public var leftBox			:Sprite;
		
		public var boxesArray		:Array;
		
		// Formatting
		private var boxSize				:Number = 8;
		private var rotationThickness	:Number = 64;
		private var cornerRadius		:Number = 64;
		private var boxPadding			:Number = 0;
		
		// Data
		private var bounds				:Rectangle;
		private var matrix				:Matrix;
		private var parentContainer		:Sprite;
		
		public function TransformOverlay()
		{
			
		}
		
		override protected function init():void
		{
			boxesArray = [];
			blendMode = BlendMode.INVERT;
			
			rotationArea = new Sprite();
			addChild( rotationArea );
			
			translateArea = new Sprite();
			addChild( translateArea );
			
			boxes = new Sprite();
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
			this.bounds = bounds;
			this.matrix = matrix.clone();
			invalidate();
			visible = true;
		}
		
		public function clear():void
		{
			bounds = null;
			matrix = null;
			visible = false;
		}
		
		
		override protected function validate():void
		{
			if ( !bounds ) return;
			if ( !view ) return;
			if ( !view.renderer ) return;
			
			var TL:Point = new Point(bounds.x, bounds.y);
			TL = matrix.transformPoint(TL);
			TL = view.renderer.worldToViewport(TL);
				
			var TR:Point = new Point(bounds.right, bounds.y);
			TR = matrix.transformPoint(TR);
			TR = view.renderer.worldToViewport(TR);
			
			var BR:Point = new Point(bounds.right, bounds.bottom);
			BR = matrix.transformPoint(BR);
			BR = view.renderer.worldToViewport(BR);
			
			var BL:Point = new Point(bounds.x, bounds.bottom);
			BL = matrix.transformPoint(BL);
			BL = view.renderer.worldToViewport(BL);
						
			rotationArea.graphics.clear();
			rotationArea.graphics.lineStyle( 40, 0x00FF00, 0.0, false );
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
		
		
		private function createBox():Sprite
		{
			var spr:Sprite = new Sprite();
			spr.graphics.lineStyle(1, 0xFFFFFF);
			spr.graphics.beginFill( 0xFFFFFF, 0.0 );
			spr.graphics.drawRect( -boxSize*0.5, -boxSize*0.5, boxSize, boxSize );
			boxesArray.push( spr );
			return spr;
		}

		public function get view():ICadetEditorView2D
		{
			return _view;
		}

		public function set view(value:ICadetEditorView2D):void
		{
			_view = value;
		}

	}
}