package cadetEditor2D.managers
{
	import cadet.core.IComponentContainer;

	public interface IComponentHighlightManager
	{
		function highlightComponent( component:IComponentContainer ):void;
		function unhighlightComponent( component:IComponentContainer ):void;
		function unhighlightAllComponents():void;
			
		function dispose():void;
	}
}