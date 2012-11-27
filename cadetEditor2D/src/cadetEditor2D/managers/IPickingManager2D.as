package cadetEditor2D.managers
{
	import cadet.core.ICadetScene;
	
	import flash.display.InteractiveObject;
	import flash.events.IEventDispatcher;

	public interface IPickingManager2D extends IEventDispatcher
	{
		function setScene( value:ICadetScene ):void
		//function setContainer( value:InteractiveObject ):void
		function set snapManager( value:SnapManager2D ):void
			
		function enable():void
		function disable():void
		function dispose():void
	}
}