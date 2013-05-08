package cadetEditor2D.contexts
{
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.controllers.ICadetContextController;
	import cadetEditor.managers.ToolManager;
	
	import cadetEditor2D.managers.IComponentHighlightManager;
	import cadetEditor2D.managers.IPickingManager2D;
	import cadetEditor2D.managers.SnapManager2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;

	public interface ICadetEditorContext2D extends ICadetEditorContext
	{
		function get view2D():ICadetEditorView2D;
		function get toolManager():ToolManager;
		function get snapManager():SnapManager2D;
		function get pickingManager():IPickingManager2D;
		function get highlightManager():IComponentHighlightManager;
		function getControllerOfType( type:Class ):ICadetContextController;
	}
}