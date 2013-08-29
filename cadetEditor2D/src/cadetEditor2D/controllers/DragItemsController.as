// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.controllers
{
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.IRenderable;
	import cadet2D.components.skins.TransformableSkin;
	import cadet2D.components.transforms.ITransform2D;
	import cadet2D.components.transforms.Transform2D;
	
	import cadetEditor.contexts.ICadetEditorContext;
	
	import cadetEditor2D.tools.ICadetEditorTool2D;
	
	import core.app.operations.ChangePropertyOperation;
	import core.app.operations.UndoableCompoundOperation;
	import core.editor.CoreEditor;
	
	import starling.utils.MatrixUtil;
	
	public class DragItemsController
	{
		protected var context				:ICadetEditorContext;
		protected var tool					:ICadetEditorTool2D;
		protected var skins					:Array;
		protected var storedMatrices		:Dictionary;
		protected var matricesTable			:Dictionary;
		protected var mouseX				:Number;
		protected var mouseY				:Number;
		protected var _dragging				:Boolean = false;
		
		protected var topLevelTransform		:Transform2D;
		
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
			
			var renderer2D:Renderer2D = ComponentUtil.getChildOfType(context.scene, Renderer2D, true);
			var matrix:Matrix = renderer2D.viewport.transformationMatrix;
			topLevelTransform = new Transform2D(20, 20);
			//topLevelTransform.matrix = matrix;
			
			storedMatrices = new Dictionary();
			matricesTable = new Dictionary();
			var skinsWithParentTransforms:Array = [];
			
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var renderable:IRenderable = skins[i];
				if ( renderable is AbstractSkin2D ) {
					var skin:AbstractSkin2D = AbstractSkin2D(renderable);
					// If a skin has a transform2D set, this overrides its own transform2D (if it has one)
					if (skin.transform2D) {
						// WHEN ADDING a transform to the tables:
						// If the transform2D has a parentTransform and that parentTransform is added, remove references
						// to its child transforms from the tables: We're only interested in dragging the topmost transform
						
						//if (!matricesTable[skin.transform2D]) {
							storedMatrices[skin] = skin.transform2D.matrix.clone();
							matricesTable[skin.transform2D] = storedMatrices[skin];
							
							if ( skin.transform2D.parentTransform ) {
								skinsWithParentTransforms.push(skin);
							}
							
						// What's the point of this clause? Dictionaries are cleared at start of the function...
//						} else {
//							storedMatrices[skin] = matricesTable[skin.transform2D];
//						}
					} 
					// Else, if the skin is transformable, fall back on its own transform2D.
					else if (skin is TransformableSkin ) {
						var tSkin:TransformableSkin = TransformableSkin(skin);
						storedMatrices[skin] = tSkin.matrix.clone();
					}					
				} 
				// ParticleSystems or non-skin related renderables
				else {
					storedMatrices[renderable] = renderable.matrix.clone();
				}
			}
			
			trace("skinsWithParentTransforms "+skinsWithParentTransforms);
			
			for ( i = 0; i < skinsWithParentTransforms.length; i ++ ) {
				skin = skinsWithParentTransforms[i];
				var childTransform:ITransform2D = skin.transform2D;
				// If the transform's parent is being transformed, remove the reference to
				// the child transform
				if ( matricesTable[childTransform.parentTransform] ) {
					trace("parent in table");
					storedMatrices[skin] = null;
					matricesTable[skin.transform2D] = null;
				}
			}
			
			var snappedPos:Point = tool.getSnappedWorldMouse();
			mouseX = snappedPos.x;
			mouseY = snappedPos.y;
			
			CoreEditor.stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			CoreEditor.stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
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
				var renderable:IRenderable = skins[i];
				var newMatrix:Matrix;
				if ( renderable is AbstractSkin2D ) {
					var skin:AbstractSkin2D = AbstractSkin2D(renderable);
					
					if (skin.transform2D) {
						newMatrix = skin.transform2D.matrix.clone();
					} else if (skin is TransformableSkin ) {
						var tSkin:TransformableSkin = TransformableSkin(skin);
						newMatrix = tSkin.matrix.clone();
					}					
				} else {
					newMatrix = renderable.matrix.clone();
				}

				newMatrices.push(newMatrix);
			}
			
			for ( i = 0; i < skins.length; i++ )
			{
				renderable = skins[i];
				var storedMatrix:Matrix = storedMatrices[skin];
				// Not all skins will have storedMatrices (child transform's skins are removed)
				if (!storedMatrix) 	continue;
				
				if ( renderable is AbstractSkin2D ) {
					skin = AbstractSkin2D(renderable);
					if (skin.transform2D) {
						newMatrix = newMatrices[i];
						skin.transform2D.matrix = storedMatrix.clone();
						compoundOperation.addOperation( new ChangePropertyOperation( skin.transform2D, "matrix", newMatrix.clone(), storedMatrix.clone() ) );
					} else if (skin is TransformableSkin) {
						tSkin = TransformableSkin(skin);
						newMatrix = tSkin.matrix.clone();
						tSkin.matrix = storedMatrix.clone();
						compoundOperation.addOperation( new ChangePropertyOperation( skin, "matrix", newMatrix.clone(), storedMatrix.clone() ) );
					}
				} else {
					newMatrix = renderable.matrix.clone();
					renderable.matrix = storedMatrix.clone();
					compoundOperation.addOperation( new ChangePropertyOperation( renderable, "matrix", newMatrix.clone(), storedMatrix.clone() ) );					
				}
			}
			context.operationManager.addOperation( compoundOperation );
			_dragging = false;
			
			CoreEditor.stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			CoreEditor.stage.removeEventListener( MouseEvent.MOUSE_UP, mouseMoveHandler );
		}
		
		protected function updateDragPositions():void
		{
			var renderable:IRenderable;
			
			// mouseX & mouseY are fixed from beginDrag
			//
			var snappedPos:Point = tool.getSnappedWorldMouse();
			//TODO: need to translate into common parentTransform coord space
//			var dx:Number = snappedPos.x - mouseX;
//			var dy:Number = snappedPos.y - mouseY;
			
			trace("mouseX "+mouseX+" mouseY "+mouseY);
			trace("snappedPos.x "+snappedPos.x+" .y "+snappedPos.y);
			
			var i:int;
			var globalBounds:Rectangle = new Rectangle();
			for ( i = 0; i < skins.length; i++ )
			{
				renderable = skins[i];
				var storedMatrix:Matrix = storedMatrices[renderable];
				
				if ( renderable is AbstractSkin2D ) {
					var skin:AbstractSkin2D = AbstractSkin2D(renderable);
					if (storedMatrix) {
						if (skin.transform2D) {
							var m:Matrix = skin.transform2D.globalMatrix.clone(); // clone local-to-global matrix before inverting
							m.invert(); // invert and get global-to-local
							
							// this is from Starling, but you can copy this method code as well - it's just 2 lines
							var localPoint:Point = MatrixUtil.transformCoords(m, snappedPos.x, snappedPos.y);
							var mousePoint:Point = MatrixUtil.transformCoords(m, mouseX, mouseY);
							
							var dx:Number = localPoint.x - mousePoint.x;
							var dy:Number = localPoint.y - mousePoint.y;
							
							var newMatrix:Matrix = storedMatrix.clone();
							newMatrix.translate(dx,dy);
							skin.transform2D.matrix = newMatrix;						
						} else if (skin is TransformableSkin) {
							var tSkin:TransformableSkin = TransformableSkin(skin);
							newMatrix = storedMatrix.clone();
							newMatrix.translate(dx,dy);
							tSkin.matrix = newMatrix;						
						}
					}
				} else {
					newMatrix = storedMatrix.clone();
					newMatrix.translate(dx,dy);
					renderable.matrix = newMatrix;		
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