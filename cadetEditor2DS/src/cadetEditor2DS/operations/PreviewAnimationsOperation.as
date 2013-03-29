// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DS.operations
{
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	
	import cadet2D.components.skins.IAnimatable;
	
	import core.app.core.operations.IOperation;

	public class PreviewAnimationsOperation implements IOperation
	{
		private var _label			:String = "PreviewAnimationsOperation";
		private var _components		:Array;
		
		public function PreviewAnimationsOperation( components:Array )
		{
			_components		= components;
		}
		
		public function execute():void
		{
			recurseChildren(_components);
		}
		
		private function recurseChildren( components:Array ):void
		{
			for ( var i:uint = 0; i < components.length; i ++ ) {
				var component:IComponent = components[i];
				if ( component is IAnimatable ) {
					var animatableComp:IAnimatable = IAnimatable(component);
					if ( !animatableComp.isAnimating ) {
						animatableComp.previewAnimation = true;
						animatableComp.addToJuggler();
					} else {
						animatableComp.previewAnimation = false;
						animatableComp.removeFromJuggler();
					}
				}
				if ( component is ComponentContainer ) {
					recurseChildren( ComponentContainer(component).children.source );
				}
			}
		}
		
		public function get label():String
		{
			return _label;
		}
	}
}

