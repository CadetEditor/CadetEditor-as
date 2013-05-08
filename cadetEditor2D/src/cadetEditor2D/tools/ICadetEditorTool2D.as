package cadetEditor2D.tools
{
	import cadetEditor.tools.ITool;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.geom.Point;

	public interface ICadetEditorTool2D extends ITool
	{
		function get context():ICadetEditorContext2D;
		function set context(value:ICadetEditorContext2D):void;
		
		function get view():ICadetEditorView2D;
		function set view(value:ICadetEditorView2D):void;
			
		function getSnappedWorldMouse():Point;
	}
}