// =================================================================================================
//
//	CadetEngine Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package cadet2DFlash.components.skins
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import cadet2D.components.connections.Connection;
	import cadet2DFlash.components.renderers.Renderer2D;
	import cadet.events.InvalidationEvent;

	public class SpringSkin extends AbstractSkin2D
	{
		// Invalidation types
		protected static const DISPLAY	:String = "display";
		
		private var _lineThickness:Number;
		private var _lineColor:Number;
		private var _lineAlpha:Number;
		private var _numZigZags:Number;
		private var _width:Number;
		
		private var _connection		:Connection;
		private var _renderer		:Renderer2D;
		
		public function SpringSkin( lineThickness:Number = 1, lineColor:uint = 0xFFFFFF, lineAlpha:Number = 0.5, numZigZags:int = 20, width:Number = 10 )
		{
			name = "SpringSkin";
			this.lineThickness = lineThickness;
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;
			this.numZigZags = numZigZags;
			this.width = width;
		}
		
		override protected function addedToScene():void
		{
			super.addedToScene();
			addSiblingReference(Connection, "connection");
			addSceneReference( Renderer2D, "renderer" );
		}
		
		public function set renderer( value:Renderer2D ):void
		{
			_renderer = value;
			invalidate(DISPLAY);
		}
		public function get renderer():Renderer2D { return _renderer; }
		
		public function set connection( value:Connection ):void
		{
			if ( _connection )
			{
				_connection.removeEventListener(InvalidationEvent.INVALIDATE, invalidateConnectionHandler);
			}
			_connection = value;
			if ( _connection )
			{
				_connection.addEventListener(InvalidationEvent.INVALIDATE, invalidateConnectionHandler);
			}
			invalidate(DISPLAY);
		}
		public function get connection():Connection { return _connection; }
		
		private function invalidateConnectionHandler( event:InvalidationEvent ):void
		{
			invalidate(DISPLAY);
		}
		
		override public function validateNow():void
		{
			if ( isInvalid( DISPLAY ) )
			{
				validateDisplay();
			}
			
			super.validateNow();
		}
		
		public function validateDisplay():void
		{
			if (!_connection) return;
			if (!_renderer) return;
			if (!_connection.transformA) return;
			if (!_connection.transformB) return;
			
			var graphics:Graphics = sprite.graphics
			graphics.clear();
			graphics.lineStyle( lineThickness, lineColor, lineAlpha );
						
			var pt1:Point = _connection.transformA.matrix.transformPoint( _connection.localPosA.toPoint() );
			pt1 = _renderer.worldToViewport(pt1);
			pt1 = _renderer.viewport.localToGlobal(pt1);
			pt1 = sprite.globalToLocal(pt1);
			
			var pt2:Point = _connection.transformB.matrix.transformPoint( _connection.localPosB.toPoint() );
			pt2 = _renderer.worldToViewport(pt2);
			pt2 = _renderer.viewport.localToGlobal(pt2);
			pt2 = sprite.globalToLocal(pt2);
			
			graphics.moveTo( pt1.x, pt1.y );
			
			var switcher:int = 1;
			var nx:Number = pt2.x-pt1.x;
			var ny:Number = pt2.y-pt1.y;
			var m:Number = Math.sqrt( nx*nx + ny*ny );
			var n:Point = new Point( (ny/m)*width*0.5, -(nx/m)*width*0.5 );
			for ( var i:int = 0; i < numZigZags; i++ )
			{
				var ratio:Number = (i+1) / (numZigZags+1);
				var ptx:Number = pt1.x + ratio * nx
				var pty:Number = pt1.y + ratio * ny
				ptx += n.x * switcher;
				pty += n.y * switcher;
				graphics.lineTo( ptx, pty );
				switcher *= -1;
			}
			
			graphics.lineTo( pt2.x, pt2.y );
		}
		
		// Getters / Setters ////////////////////////////////////////////////////////////////////////////
		
		[Serializable][Inspectable]
		public function set lineThickness( value:Number ):void
		{
			_lineThickness = value;
			invalidate(DISPLAY);
		}
		public function get lineThickness():Number { return _lineThickness; }
		
		[Serializable][Inspectable]
		public function set lineColor( value:uint ):void
		{
			_lineColor = value;
			invalidate(DISPLAY);
		}
		public function get lineColor():uint { return _lineColor; }
		
		
		[Serializable][Inspectable]
		public function set lineAlpha( value:Number ):void
		{
			_lineAlpha = value;
			invalidate(DISPLAY);
		}
		public function get lineAlpha():Number { return _lineAlpha; }
		
		
		[Serializable][Inspectable]
		public function set numZigZags( value:Number ):void
		{
			_numZigZags = value;
			invalidate(DISPLAY);
		}
		public function get numZigZags():Number { return _numZigZags; }
		
		
		[Serializable][Inspectable]
		public function set width( value:Number ):void
		{
			_width = value;
			invalidate(DISPLAY);
		}
		public function get width():Number { return _width; }
	}
}