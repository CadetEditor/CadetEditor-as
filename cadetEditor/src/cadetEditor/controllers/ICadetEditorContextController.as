package cadetEditor.controllers
{
	
	import flox.ui.components.HBox;
	
	public interface ICadetEditorContextController extends ICadetContextController
	{
		function initScene():void
		function disposeScene():void

		function get controlBar():HBox
	}
}