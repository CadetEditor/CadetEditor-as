// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.ui.overlays
{
	import flash.geom.Point;
	
	import cadet.events.ValidationEvent;
	
	import cadet2D.components.geom.BezierCurve;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.geom.QuadraticBezier;
	import cadet2D.overlays.Overlay;
	
	import cadetEditor2DS.tools.CadetEditorTool2D;
	
	import starling.core.RenderSupport;

	public class BezierCurveToolOverlay extends Overlay
	{
		private var tool		:CadetEditorTool2D;
		private var _curve		:BezierCurve;
		private var _transform2D:Transform2D;
		
		private const BOX_SIZE	:int = 10;
		
		private var start		:Point;
		private var control		:Point;
		private var end			:Point;
		
		public function BezierCurveToolOverlay( tool:CadetEditorTool2D )
		{
			this.tool = tool;
			start = new Point();
			control = new Point();
			end = new Point();
		}
		
		public function set curve( value:BezierCurve ):void
		{
			if ( _curve )
			{
				_curve.removeEventListener(ValidationEvent.INVALIDATE, invalidatePathHandler);
			}
			_curve = value;
			if ( _curve )
			{
				_curve.addEventListener(ValidationEvent.INVALIDATE, invalidatePathHandler);
			}
			invalidate("*");
		}
		public function get curve():BezierCurve { return _curve; }
		
		public function set transform2D( value:Transform2D ):void
		{
			if ( _transform2D )
			{
				_transform2D.removeEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			_transform2D = value;
			if ( _transform2D )
			{
				_transform2D.addEventListener(ValidationEvent.INVALIDATE, invalidateTransformHandler);
			}
			invalidate("*");
		}
		public function get transform2D():Transform2D { return _transform2D; }
		
		private function invalidatePathHandler( event:ValidationEvent ):void
		{
			invalidate("*");
		}
		
		private function invalidateTransformHandler( event:ValidationEvent ):void
		{
			invalidate("*");
		}
		
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			if ( isInvalid("*") )	validateNow();
		}
		
		override protected function validate():void
		{
			graphics.clear();
			
			if ( !_curve ) return;
			
			var L:int = _curve.segments.length;
			
			for ( var i:int = 0; i < L; i++ )
			{
				var segment:QuadraticBezier = _curve.segments[i];
				
				start.x = segment.startX;
				start.y = segment.startY;
				start = _transform2D.matrix.transformPoint(start);
				start = tool.view.renderer.worldToViewport(start);
				
				control.x = segment.controlX;
				control.y = segment.controlY;
				control = _transform2D.matrix.transformPoint(control);
				control = tool.view.renderer.worldToViewport(control);
				
				end.x = segment.endX;
				end.y = segment.endY;
				end = _transform2D.matrix.transformPoint(end);
				end = tool.view.renderer.worldToViewport(end);
				
				if ( i % 2 == 0 )
				{
					drawCircle(start);
					drawBox(control);
				}
				else
				{
					drawCircle(end);
					drawBox(control);
				}
				
				drawCircle( start, 0xFF0000, 2 );
				drawCircle( control, 0xFF0000, 2 );
				drawCircle( end, 0xFF0000, 2 );
				
				
				
				//graphics.lineStyle(1, 0xFFFFFF, 0.5 );
				//graphics.moveTo(c1.x,c1.y);
				//graphics.lineTo(c2.x,c2.y);
			}
		}
		
		private function drawCircle( pos:Point, color:uint = 0xFFFFFF, size:Number = 5 ):void
		{
			graphics.beginFill(color);
			graphics.drawCircle(pos.x, pos.y, size);
			graphics.endFill();
		}
		
		private function drawBox( pos:Point ):void
		{
			graphics.beginFill(0xFFFFFF,0);
			graphics.lineStyle(1,0xFFFFFF);
			graphics.drawRect(pos.x-BOX_SIZE*0.5, pos.y-BOX_SIZE*0.5, BOX_SIZE, BOX_SIZE);
			graphics.endFill();
		}
	}
}