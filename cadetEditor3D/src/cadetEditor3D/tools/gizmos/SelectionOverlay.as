// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools.gizmos
{
	import away3d.entities.Entity;
	
	import cadet3D.components.core.Object3DComponent;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	
	import flox.core.events.ArrayCollectionEvent;

	public class SelectionOverlay
	{
		private var context	:CadetEditorContext3D;
		
		private var selectedObject3DComponents	:Vector.<Object3DComponent>;
		
		public function SelectionOverlay( context:CadetEditorContext3D )
		{
			this.context = context;
			selectedObject3DComponents = new Vector.<Object3DComponent>();
			context.selection.addEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
		}
		
		public function dispose():void
		{
			context.selection.removeEventListener(ArrayCollectionEvent.CHANGE, selectionChangeHandler);
			selectedObject3DComponents = null;
		}
		
		private function selectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			for each ( var object3DComponent:Object3DComponent in selectedObject3DComponents )
			{
				if ( context.selection.contains(object3DComponent) ) continue;
				if ( object3DComponent.object3D is Entity == false ) continue;
				// Need try catch because not all entities currently support showing their bounds (Like lights)
				try
				{
					Entity(object3DComponent.object3D).showBounds = false;
				}
				catch ( e:Error )  {}
			}
			selectedObject3DComponents.length = 0;
			
			for ( var i:int = 0; i < context.selection.length; i++ )
			{
				object3DComponent = context.selection[i] as Object3DComponent;
				if ( object3DComponent == null ) continue;
				if ( object3DComponent.object3D is Entity == false ) continue;
				
				// Need try catch because not all entities currently support showing their bounds (Like lights)
				try
				{
					Entity(object3DComponent.object3D).showBounds = true;
				}
				catch( e:Error ) {}
				
				selectedObject3DComponents.push(object3DComponent);
			}
		}
	}
}