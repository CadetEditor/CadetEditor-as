package cadetEditor2D.controllers
{
	public interface IDragSelectionController
	{
		function dispose():void;
		function beginDrag():void;
		function get dragging():Boolean;
	}
}