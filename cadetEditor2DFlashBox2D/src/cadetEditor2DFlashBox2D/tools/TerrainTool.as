// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlashBox2D.tools
{
	import cadet.core.ComponentContainer;
	import cadet.core.IComponent;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.TerrainGeometry;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.renderPipeline.flash.components.skins.TerrainSkin;
	
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	
	import cadetEditor2D.events.PickingManagerEvent;
	
	import cadetEditor2DFlash.tools.CadetEditorTool2D;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	
	public class TerrainTool extends CadetEditorTool2D
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, TerrainTool, "Terrain Tool", CadetEditorIcons.Terrain );
		}
		
		private var terrainGeometry		:TerrainGeometry;
		private var transform			:Transform2D;
		
		private var mouseIsDown			:Boolean = false;
		private var previousIndex		:int = -1;
		private var previousHeight		:Number;
		
		// This var stores a copy of the terrain samples before painting, so undo can be implemented.
		private var storedSamples		:Array;
		
		public function TerrainTool()
		{
			
		}
		
		override public function enable():void
		{
			super.enable();
			updateFromSelection();
		}
		
		override public function disable():void
		{
			endPaint();
			super.disable();
		}
		
		private function updateFromSelection():void
		{
			endPaint();
			
			terrainGeometry = null;
			transform = null;
			
			var selectedItems:Array = context.selection.source;
			if ( selectedItems.length != 0 )
			{
				var selectedItem:IComponent = selectedItems[0];
				
				var container:IComponentContainer;
				if ( selectedItem is IComponentContainer )
				{
					container = IComponentContainer(selectedItem);
				}
				else
				{
					container = selectedItem.parentComponent;
				}
				
				terrainGeometry = ComponentUtil.getChildOfType( container, TerrainGeometry );
				transform = ComponentUtil.getChildOfType( container, Transform2D );
			}
		}
		
		private function createComponent():void
		{
			var entity:Entity = new Entity();
			entity.name = "Terrain";
			
			var bottomRightWorld:Point = new Point( context.view2D.viewportWidth, context.view2D.viewportHeight );
			bottomRightWorld = context.view2D.renderer.viewportToWorld(bottomRightWorld);
			
			var transform:Transform2D = new Transform2D( view.worldMouse.x, bottomRightWorld.y );
			entity.children.addItem( transform );
			entity.children.addItem( new TerrainSkin() );
			entity.children.addItem( new TerrainGeometry() );
			var rigidBodyBehaviour:RigidBodyBehaviour = new RigidBodyBehaviour();
			rigidBodyBehaviour.fixed = true;
			entity.children.addItem( rigidBodyBehaviour );
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Create Terrain";
			
			operation.addOperation( new AddItemOperation( entity, context.scene.children ) );
			operation.addOperation( new ChangePropertyOperation( context.selection, "source", [entity] ) );
			
			context.operationManager.addOperation( operation );
		}
		
		override protected function onMouseDownContainer(event:PickingManagerEvent):void
		{
			beginPaint();
		}
		
		override protected function onMouseUpStage(event:PickingManagerEvent):void
		{
			endPaint();
		}
		
		private function beginPaint():void
		{
			if ( !terrainGeometry )
			{
				createComponent();
				updateFromSelection();
			}
			mouseIsDown = true;
			storedSamples = terrainGeometry.samples.slice();
		}
		
		private function endPaint():void
		{
			if ( !mouseIsDown ) return;
			mouseIsDown = false;
			previousIndex = -1;
			
			// Revert the terrain back to using the samples before painting,
			// then apply a ChangePropertyOperation to re-apply the change so
			// it can be undone.
			var newSamples:Array = terrainGeometry.samples.slice();
			terrainGeometry.samples = storedSamples;
			var operation:ChangePropertyOperation = new ChangePropertyOperation( terrainGeometry, "samples", newSamples );
			operation.label = "Paint Terrain";
			context.operationManager.addOperation(operation);
		}
		
		override protected function onMouseMoveContainer(event:PickingManagerEvent):void
		{
			if ( !mouseIsDown ) return;
			
			var m:Matrix = transform.matrix.clone();
			m.invert();
			
			var pt:Point = view.worldMouse;
			pt = m.transformPoint(pt);
			
			var index:int = (pt.x+terrainGeometry.sampleWidth*0.5) / terrainGeometry.sampleWidth;
			var height:Number = -pt.y;
			
			height = height;
			
			terrainGeometry.setHeight( index, height );
			
			// If the terrain has been painted on a mousemove before this,
			// interpolate the mouse position between the last update and this one
			// to ensure a smooth paint.
			if ( previousIndex != -1 )
			{
				var diff:int = index-previousIndex;
				for ( var i:int = 1; i <= Math.abs(diff); i++ )
				{
					var ratio:Number = i/Math.abs(diff);
					if ( isNaN(ratio) ) ratio = 1;
					
					var newIndex:int = previousIndex + i * (diff < 0 ? -1 : 1);
					var interpolatedHeight:Number = (1-ratio) * previousHeight + ratio * height;
					terrainGeometry.setHeight( newIndex, interpolatedHeight );
				}
			}
			
			previousIndex = index;
			previousHeight = height;
		}
	}
}