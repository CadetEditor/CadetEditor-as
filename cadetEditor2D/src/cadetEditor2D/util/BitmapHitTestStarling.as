// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.util
{
	import flash.filters.BlurFilter;
	import flash.geom.Point
		
	import starling.display.DisplayObject;
	
	public class BitmapHitTestStarling
	{
		private static const blurFilter		:BlurFilter = new BlurFilter(4,4,1);
		
		private static const QUALITY		:Number = 0.25;
		
		public static function hitTestPoint( x:Number, y:Number, dispObj:DisplayObject, relativeTo:DisplayObject ):Boolean
		{
			// Early rejection on bounds
			var pt:Point = relativeTo.localToGlobal(new Point(x,y));
			//if ( dispObj.hitTestPoint(pt.x,pt.y,false ) == false ) return false;
			
			return dispObj.hitTest( pt );
			
			/*
			if ( dispObj.hitTest( pt ) == false ) return false;
			
			try
			{
				var bmpData:BitmapData = getBitmap( dispObj, relativeTo );
			}
			catch( e:Error )
			{
				return false;
			}
			
			var bounds:Rectangle = getFilteredBounds( dispObj, relativeTo );
			var hitPoint:Point = new Point( (x-bounds.x) * QUALITY, (y-bounds.y) * QUALITY );
			var result:Boolean = bmpData.hitTest( new Point( 0, 0 ), 1, hitPoint );
			bmpData.dispose();
			return result;
			*/
		}
		/*
		public static function hitTestRect( rect:Rectangle, dispObj:DisplayObject, relativeTo:DisplayObject ):Boolean
		{
			var bmpData:BitmapData = getBitmap( dispObj, relativeTo );
			var bounds:Rectangle = getFilteredBounds( dispObj, relativeTo );
			var hitRect:Rectangle = rect.clone();
			hitRect.x -= bounds.x;
			hitRect.y -= bounds.y;
			hitRect.x *= QUALITY;
			hitRect.y *= QUALITY;
			hitRect.width *= QUALITY;
			hitRect.height *= QUALITY;
			var result:Boolean = bmpData.hitTest( new Point( 0, 0 ), 1, hitRect );
			bmpData.dispose();
			return result;
		}
		
		public static function hitTestDisplayObject( dispObjA:DisplayObject, dispObjB:DisplayObject, relativeTo:DisplayObject = null ):Boolean
		{
			if ( !relativeTo ) 
			{
				relativeTo = dispObjA.parent == null ? dispObjA : dispObjA.parent;
			}
			
			var bmpDataA:BitmapData = getBitmap( dispObjA, relativeTo );
			var boundsA:Rectangle = getFilteredBounds( dispObjA, relativeTo );
			
			var bmpDataB:BitmapData = getBitmap( dispObjB, relativeTo );
			var boundsB:Rectangle = getFilteredBounds( dispObjB, relativeTo );
			
			var offset:Point = new Point( (boundsB.x - boundsA.x)*QUALITY, (boundsB.y - boundsA.y)*QUALITY );
			return bmpDataA.hitTest( new Point( 0, 0 ), 1, bmpDataB, offset );
		}
		
		private static function getBitmap( dispObj:DisplayObject, relativeTo:DisplayObject ):BitmapData
		{
			var bounds:Rectangle = getFilteredBounds( dispObj, relativeTo );
			
			var bmpData:BitmapData = new BitmapData( Math.max(1,bounds.width*QUALITY), Math.max(1,bounds.height*QUALITY), true, 0 );
			
			var m:Matrix = DisplayListUtilStarling.getConcatenatedMatrix(dispObj,relativeTo);
			m.translate(-bounds.x,-bounds.y);
			m.scale( QUALITY, QUALITY );
			bmpData.draw(dispObj., m);
			bmpData.applyFilter(bmpData, bmpData.rect, new Point(0,0), blurFilter);
			
			return bmpData;
		}
		
		private static function getFilteredBounds( dispObj:DisplayObject, relativeTo:DisplayObject ):Rectangle
		{
			var bounds:Rectangle = dispObj.getBounds( relativeTo );
			bounds.x -= blurFilter.blurX;
			bounds.width += (blurFilter.blurX << 1);
			bounds.y -= blurFilter.blurY;
			bounds.height += (blurFilter.blurY << 1);
			return bounds;
		}
		*/
	}
}

