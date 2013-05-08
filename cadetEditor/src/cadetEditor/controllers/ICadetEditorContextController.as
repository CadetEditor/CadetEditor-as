package cadetEditor.controllers
{
	
	import core.ui.components.HBox;
	
	public interface ICadetEditorContextController extends ICadetContextController
	{
		function initScene():void;
		function disposeScene():void;

		function get controlBar():HBox;
	}
}