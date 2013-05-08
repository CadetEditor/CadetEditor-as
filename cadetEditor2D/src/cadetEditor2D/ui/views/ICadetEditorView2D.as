package cadetEditor2D.ui.views
{
	import cadet2D.components.renderers.IRenderer2D;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;

	public interface ICadetEditorView2D extends IEventDispatcher
	{
		function set showGrid(value:Boolean):void;
		function get showGrid():Boolean;
		
		function set gridSize(value:Number):void;
		function get gridSize():Number;
		
		function set zoom(value:Number):void;
		function get zoom():Number;
		
		function set panX(value:Number):void;
		function get panX():Number;
		
		function set panY(value:Number):void;
		function get panY():Number;
		
		function invalidate():void;
		
		function get container():DisplayObjectContainer;
		
		function set renderer( value:IRenderer2D ):void;
		function get renderer():IRenderer2D;
			
		//function get controlBar():DisplayObjectContainer
			
		function getContent():Sprite;
//		function getOverlayOfType( type:Class ):DisplayObject
			
		function get viewportWidth():Number;
		function get viewportHeight():Number;
		//function get viewport():Sprite
		function get viewportMouse():Point;
		function get worldMouse():Point;
			
//		function addOverlay( overlay:DisplayObject, location:int = 0 ):void
//		function removeOverlay( overlay:DisplayObject ):void
			
		function get parent():DisplayObjectContainer;
	}
}