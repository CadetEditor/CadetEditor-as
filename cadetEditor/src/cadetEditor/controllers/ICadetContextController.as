package cadetEditor.controllers
{
	import cadetEditor.contexts.ICadetEditorContext;

	public interface ICadetContextController
	{
		function init(context:ICadetEditorContext):void
		function dispose():void
	}
}