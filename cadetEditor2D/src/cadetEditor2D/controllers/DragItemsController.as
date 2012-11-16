// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.controllers
{
	import cadet2D.components.skins.ISkin2D;
	
	import cadetEditor.contexts.ICadetEditorContext;
	
	import cadetEditor2D.tools.CadetEditorTool2D;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flox.editor.FloxEditor;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	
	public class DragItemsController
	{
		protected var context				:ICadetEditorContext;
		protected var tool					:CadetEditorTool2D
		protected var skins					:Array
		protected var storedTransforms		:Array;
		protected var mouseX				:Number;
		protected var mouseY				:Number;
		protected var _dragging				:Boolean = false;
		
		public function DragItemsController( context:ICadetEditorContext, tool:cadetEditor2D.tools.CadetEditorTool2D )
		{
			this.context = context;
			this.tool = tool;
		}
		
		public function dispose():void
		{
			if ( _dragging ) 
			{
				endDrag();
			}
			context = null;
			tool = null;
			storedTransforms = null;
			skins = null;
		}
		
		public function beginDrag( skins:Array ):void
		{
			if ( _dragging ) 
			{
				endDrag();
			}
			_dragging = true;
			
			this.skins = skins;
			if ( skins.length == 0 ) return;
			
			storedTransforms = [];
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var skin:ISkin2D = skins[i];
				//TODO: Assumption that every skin has an associated transform
				//at the correct index in storedTransforms. Perhaps a table would be better?
				if (skin.transform2D) {
					storedTransforms[i] = skin.transform2D.matrix.clone();
				}
			}
			
			var snappedPos:Point = tool.getSnappedWorldMouse();
			mouseX = snappedPos.x;
			mouseY = snappedPos.y;
			
			FloxEditor.stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			FloxEditor.stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
		}
		
		public function endDrag():void
		{
			if ( !_dragging ) return;
			
			var compoundOperation:UndoableCompoundOperation = new UndoableCompoundOperation();
			compoundOperation.label = "Transform Object(s)";
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var skin:ISkin2D = skins[i];
				var storedTransform:Matrix = storedTransforms[i];
				//TODO: Assumption that every skin has an associated transform
				//at the correct index in storedTransforms. Perhaps a table would be better?
				if (skin.transform2D) {
					var newTransform:Matrix = skin.transform2D.matrix.clone();
					skin.transform2D.matrix = storedTransform;
					compoundOperation.addOperation( new ChangePropertyOperation( skin.transform2D, "matrix", newTransform ) );
				}
			}
			context.operationManager.addOperation( compoundOperation );
			_dragging = false;
			
			FloxEditor.stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			FloxEditor.stage.removeEventListener( MouseEvent.MOUSE_UP, mouseMoveHandler );
		}
		
		protected function updateDragPositions():void
		{
			var skin:ISkin2D;
			
			var snappedPos:Point = tool.getSnappedWorldMouse();
			var dx:Number = snappedPos.x - mouseX;
			var dy:Number = snappedPos.y - mouseY;
			
			var i:int
			var globalBounds:Rectangle = new Rectangle();
			for ( i = 0; i < skins.length; i++ )
			{
				skin = skins[i];
				//TODO: Assumption that every skin has an associated transform
				//at the correct index in storedTransforms. Perhaps a table would be better?
				if (storedTransforms[i]) {
					var newMatrix:Matrix = storedTransforms[i].clone();
					newMatrix.translate(dx,dy);
					skin.transform2D.matrix = newMatrix;
				}
			}
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			updateDragPositions();
		}
		
		private function mouseUpHandler( event:MouseEvent ):void
		{
			endDrag();
		}

		public function get dragging():Boolean { return _dragging; }
	}
}