// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DStarling.tools
{
	import cadet.components.geom.IGeometry;
	import cadet.core.ComponentContainer;
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.renderPipeline.starling.components.skins.GeometrySkin;
	
	import cadetEditor.tools.ITool;
	
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	
	public class GeometryPrimitiveTool extends CadetEditorTool2D implements ITool
	{
		protected var dragging				:Boolean = false;
		protected var mouseDownPoint		:Point;
		
		protected var entity				:Entity;
		protected var geometry				:IGeometry;
		protected var skin					:ISkin2D;
		protected var transform				:Transform2D;
		
		protected var SkinType				:Class;
		protected var GeometryType			:Class;
		
		public function GeometryPrimitiveTool()
		{
			SkinType = GeometrySkin;
		}
		
		override public function enable():void
		{
			super.enable();
		}
		
		override public function disable():void
		{ 
			super.disable();
		}
		
		override protected function onMouseDownContainer( event:PickingManagerEvent ):void
		{
			dragging = true;
			
			mouseDownPoint = context.snapManager.snapPoint(view.worldMouse).snapPoint;
			
			trace("GeomPrimitive mouse x "+mouseDownPoint.x+" y "+mouseDownPoint.y);
			
			var compoundOperation:UndoableCompoundOperation = new UndoableCompoundOperation();
			compoundOperation.label = getOperationDescription();
			
			entity = new Entity();
			entity.name = ComponentUtil.getUniqueName(getName(),context.scene);
			
			transform = new Transform2D();
			transform.x = mouseDownPoint.x;
			transform.y = mouseDownPoint.y;
			entity.children.addItem( transform );
			
			geometry = new GeometryType();
			entity.children.addItem(geometry);
			
			var rect:Rectangle = new Rectangle( mouseDownPoint.x, mouseDownPoint.y, 0, 0 );
			var normalizedRect:Rectangle = rect.clone();
			updateShape( rect, normalizedRect, event )
			
			if ( geometry is PolygonGeometry ) {
				context.snapManager.setVerticesToIgnore(PolygonGeometry(geometry).vertices);
			} else {
				context.snapManager.setVerticesToIgnore(null);
			}
			
			skin = new SkinType();
			entity.children.addItem( skin );
			
			initializeComponent();
			
			compoundOperation.addOperation( new AddItemOperation( entity, context.scene.children ) );
			compoundOperation.addOperation( new ChangePropertyOperation( context.selection, "source", [ entity ] ) );
			
			context.operationManager.addOperation( compoundOperation );
			
			onMouseMoveContainer(null);
		}
		
		//override protected function onMouseUpStage(event:PickingManagerEvent):void
		override protected function onClickBackground(event:PickingManagerEvent):void
		{
			if ( !dragging ) return;
			dragging = false;
			
			if ( isShapeValid() == false )
			{
				context.operationManager.gotoPreviousOperation();
			}
		}
		
		//override protected function onMouseMoveContainer(event:PickingManagerEvent):void
		override protected function onMouseDragContainer(event:PickingManagerEvent):void
		{
			if ( !dragging ) return;
			
			var snappedMousePos:Point = context.snapManager.snapPoint( ICadetEditorView2D(view).worldMouse ).snapPoint;
			
			var dx:Number = snappedMousePos.x - mouseDownPoint.x;
			var dy:Number = snappedMousePos.y - mouseDownPoint.y;
			
			var rect:Rectangle = new Rectangle( mouseDownPoint.x, mouseDownPoint.y, dx, dy );
			var normalizedRect:Rectangle = new Rectangle( Math.min( mouseDownPoint.x, snappedMousePos.x ), Math.min( mouseDownPoint.y, snappedMousePos.y ), Math.abs( dx ), Math.abs( dy ) );
			updateShape( rect, normalizedRect, event )
		}
		
		// Abstract functions
		protected function initializeComponent():void {}
		protected function updateShape( rect:Rectangle, normalizedRect:Rectangle, event:MouseEvent ):void {}
		protected function isShapeValid():Boolean { return false; }
		protected function getOperationDescription():String { return "Create shape"; }
		protected function getName():String { return "Shape"; }
	}
}