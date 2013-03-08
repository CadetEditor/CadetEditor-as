// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.controllers
{
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cadet2D.components.skins.IRenderable;
	
	import cadetEditor.contexts.ICadetEditorContext;
	
	import cadetEditor2D.tools.ICadetEditorTool2D;
	
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.editor.FloxEditor;
	
	public class DragItemsController
	{
		protected var context				:ICadetEditorContext;
		protected var tool					:ICadetEditorTool2D;
		protected var skins					:Array
		protected var storedMatrices		:Dictionary;
		protected var matricesTable			:Dictionary;
		protected var mouseX				:Number;
		protected var mouseY				:Number;
		protected var _dragging				:Boolean = false;
		
		public function DragItemsController( context:ICadetEditorContext, tool:ICadetEditorTool2D )
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
			storedMatrices = null;
			matricesTable = null;
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
			
			storedMatrices = new Dictionary();
			matricesTable = new Dictionary();
			
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var skin:IRenderable = skins[i];
				//TODO: Assumption that every skin has an associated transform
				//at the correct index in storedTransforms. Perhaps a table would be better?
				if (skin.transform2D) {
					if (!matricesTable[skin.transform2D]) {
						storedMatrices[skin] = skin.transform2D.matrix.clone();
						matricesTable[skin.transform2D] = storedMatrices[skin];
					} else {
						storedMatrices[skin] = matricesTable[skin.transform2D];
					}
				} else {
					storedMatrices[skin] = skin.matrix.clone();
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
			
			// Store copies of the new matrices before doing the ChangePropertyOperations, as this resets the matrices first,
			// which causes problems if multiple skins are using the same Transform2D.
			var newMatrices:Vector.<Matrix> = new Vector.<Matrix>();
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var skin:IRenderable = skins[i];
				var newMatrix:Matrix;
				if (skin.transform2D) {
					newMatrix = skin.transform2D.matrix.clone();
				} else {
					newMatrix = skin.matrix.clone();
				}
				newMatrices.push(newMatrix);
			}
			
			for ( i = 0; i < skins.length; i++ )
			{
				skin = skins[i];
				var storedMatrix:Matrix = storedMatrices[skin];
				if (skin.transform2D) {
					newMatrix = newMatrices[i];
					skin.transform2D.matrix = storedMatrix.clone();
					compoundOperation.addOperation( new ChangePropertyOperation( skin.transform2D, "matrix", newMatrix.clone(), newMatrix.clone() ) );
				} else {
					newMatrix = skin.matrix.clone();
					skin.matrix = storedMatrix.clone();
					compoundOperation.addOperation( new ChangePropertyOperation( skin, "matrix", newMatrix.clone(), newMatrix.clone() ) );
				}
			}
			context.operationManager.addOperation( compoundOperation );
			_dragging = false;
			
			FloxEditor.stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			FloxEditor.stage.removeEventListener( MouseEvent.MOUSE_UP, mouseMoveHandler );
		}
		
		protected function updateDragPositions():void
		{
			var skin:IRenderable;
			
			var snappedPos:Point = tool.getSnappedWorldMouse();
			var dx:Number = snappedPos.x - mouseX;
			var dy:Number = snappedPos.y - mouseY;
			
			var i:int
			var globalBounds:Rectangle = new Rectangle();
			for ( i = 0; i < skins.length; i++ )
			{
				skin = skins[i];
				var storedMatrix:Matrix = storedMatrices[skin]; 
				if (storedMatrix) {
					if (skin.transform2D) {
						var newMatrix:Matrix = storedMatrix.clone();
						newMatrix.translate(dx,dy);
						skin.transform2D.matrix = newMatrix;						
					} else {
						newMatrix = storedMatrix.clone();
						newMatrix.translate(dx,dy);
						skin.matrix = newMatrix;						
					}
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