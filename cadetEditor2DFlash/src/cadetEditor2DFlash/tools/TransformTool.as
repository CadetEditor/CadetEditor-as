// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.tools
{
	import cadet.core.IComponent;
	import cadet.events.InvalidationEvent;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.geom.PolygonGeometry;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.renderPipeline.flash.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.tools.ITool;
	
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	import cadetEditor2D.util.SelectionUtil;
	
	import cadetEditor2DFlash.ui.overlays.SelectionOverlay;
	import cadetEditor2DFlash.ui.overlays.TransformOverlay;
	import cadetEditor2DFlash.ui.views.CadetEditorView2D;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flox.app.events.OperationManagerEvent;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.util.IntrospectionUtil;
	import flox.core.events.ArrayCollectionEvent;
	import flox.ui.managers.CursorManager;
	
	import starling.display.Sprite;
	
	public class TransformTool extends SelectionTool //implements ITool
	{
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, TransformTool, "Transform Tool", CadetEditorIcons.TransformTool );
		}
		
		private var cursorID				:int;
		private var overBoxes				:Boolean = false;
		private var overRotationArea		:Boolean = false;
		
		private var skins					:Array;
		private var additionalSnapPoints	:Array;
		
		private var bounds					:Rectangle;
		private var currentTransform		:Matrix;
		private var startTransform			:Matrix;
		private var startTransforms			:Array;
		private var storedTransform			:Matrix;
		private var storedTransforms		:Array;
		
		private var overlay					:TransformOverlay;
		
		private var interactMode			:int;
		private var scaleMode				:int;
		private var mouseDownX				:Number;
		private var mouseDownY				:Number;
		
		private static const TRANSLATE_MODE	:int = 1;
		private static const ROTATE_MODE	:int = 2;
		private static const SCALE_MODE		:int = 3;
		private static const MOVE_ORIGIN_MODE:int = 4;
		private static const LEFT			:int = 1;
		private static const RIGHT			:int = 2;
		private static const TOP			:int = 4;
		private static const BOTTOM			:int = 8;
		
		public function TransformTool()
		{
			overlay = new TransformOverlay();
			overlay.visible = false;
			allowDrag = false;
			
			additionalSnapPoints = [];
			for ( var i:int = 0; i < 8; i++ )
			{
				additionalSnapPoints.push(new Point());
			}
			
			skins = [];
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		override public function enable():void
		{
			super.enable();
			
			try
			{
				view.getOverlayOfType(SelectionOverlay).visible = false;
			}
			catch (e:Error) {}
			
			view.addOverlay(overlay, CadetEditorView2D.TOP);
			
			overlay.boxes.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownBoxHandler );
			overlay.rotationArea.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownRotationAreaHandler );
			overlay.translateArea.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownTranslateAreaHandler );
			
			
			context.selection.addEventListener( ArrayCollectionEvent.CHANGE, selectionChangedHandler );
			context.operationManager.addEventListener(OperationManagerEvent.CHANGE, operationManagerChangeHandler);
			updateFromSelection();
		}
		
		override public function disable():void
		{
			super.disable();
			
			try
			{
				view.getOverlayOfType(SelectionOverlay).visible = true;
			}
			catch (e:Error) {}
			
			view.removeOverlay(overlay);
			
			if ( overlay.boxes )
			{
				overlay.boxes.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownBoxHandler );
				overlay.rotationArea.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownRotationAreaHandler );
				overlay.translateArea.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownTranslateAreaHandler );
			}
			
			context.selection.removeEventListener( ArrayCollectionEvent.CHANGE, selectionChangedHandler );
			context.operationManager.removeEventListener(OperationManagerEvent.CHANGE, operationManagerChangeHandler);
			
			for each ( var skin:ISkin2D in skins )
			{
				skin.removeEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
			}
			skins = [];
			currentTransform = null;
		}
		
		protected function operationManagerChangeHandler( event:OperationManagerEvent ):void
		{
			updateDisplay();
		}
		
		protected function selectionChangedHandler( event:ArrayCollectionEvent ):void
		{
			updateFromSelection();
		}
		
		private function updateDisplay():void
		{
			if ( skins == null )
			{
				context.snapManager.setAdditionalSnapPoints(null);
				overlay.clear();
			}
			else
			{
				overlay.setData( bounds, currentTransform );
				overlay.validateNow();
				
				for ( var i:int = 0; i < additionalSnapPoints.length; i++ )
				{
					var ptA:Point = additionalSnapPoints[i];
					ptA.x = 0;
					ptA.y = 0;
					var box:flash.display.Sprite = overlay.boxesArray[i];
					var pt:Point = box.localToGlobal(ptA);
					
					pt = Renderer2D(view.renderer).viewport.globalToLocal(pt);
					
					pt = view.renderer.viewportToWorld(pt);
					ptA.x = pt.x;
					ptA.y = pt.y;
				}
				
				context.snapManager.setAdditionalSnapPoints( additionalSnapPoints );
			}
		}
		
		private function updateFromSelection():void
		{
			var skin:ISkin2D;
			for each ( skin in skins )
			{
				skin.removeEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
			}
			
			skins = SelectionUtil.getSkinsFromComponents( context.selection.source );
			
			skins = skins.filter(
			function( item:*, index:int, array:Array ):Boolean 
			{ 
				var value:String = IntrospectionUtil.getMetadataByNameAndKey(item, "CadetBuilder", "transformable");
				if ( value == "false" ) return false;
				return true;
			} );
			
			if ( skins.length == 0 )
			{
				skins = null;
				currentTransform = null;
			}
			else
			{
				var selectedVertices:Array = [];
				for each ( skin in skins )
				{
					skin.addEventListener(InvalidationEvent.INVALIDATE, invalidateSkinHandler);
					
					var polygonGeometries:Vector.<IComponent> = ComponentUtil.getChildrenOfType(skin.parentComponent, PolygonGeometry, true);
					for each ( var polygonGeometry:PolygonGeometry in polygonGeometries )
					{
						selectedVertices = selectedVertices.concat(polygonGeometry.vertices);
					}
				}
				context.snapManager.setVerticesToIgnore(selectedVertices);
				
				beginTransform();
				updateDisplay();
			}
		}
		
		private var suppressInvalidateSkinHandler:Boolean = false;
		private function invalidateSkinHandler( event:InvalidationEvent ):void
		{
			if ( suppressInvalidateSkinHandler ) return;
			updateFromSelection();
		}
				
		private function storeTransforms():void
		{
			storedTransform = currentTransform.clone();
			
			storedTransforms = [];
			for ( var i:int = 0; i < skins.length; i++ )
			{
				storedTransforms.push( skins[i].transform2D.matrix.clone() );
			}
		}
		
		
		private function beginTransform():void
		{
			var skin:ISkin2D;
			var displayObject:DisplayObject;
			
			startTransforms = [];
			if ( skins.length == 1 )
			{
				skin = ISkin2D( skins[0] );
				displayObject = AbstractSkin2D(skin).displayObjectContainer; //TODO: Rob moved this
				
				if ( !skin.transform2D ) return;
				
				bounds = displayObject.getRect( displayObject );
				
				startTransform = skin.transform2D.matrix.clone();
				currentTransform = startTransform.clone();
				startTransforms.push( new Matrix() );
			}
			else
			{
				bounds = new Rectangle();
				
				// TODO: Calculate bounds with respect to World matrix. Currently selecting multiple object in ISO calculats bounds incorrectly
				for ( var i:int = 0; i < skins.length; i++ )
				{
					skin = ISkin2D( skins[i] );
					displayObject = AbstractSkin2D(skin).displayObjectContainer; //TODO: Rob moved this
					
					if ( !skin.transform2D ) return;
					
					bounds = bounds.union( displayObject.getRect( Renderer2D(view.renderer).worldContainer ) );
					startTransforms.push( skin.transform2D.matrix.clone() );
				}
				startTransform = new Matrix();
				startTransform.tx = bounds.x;
				startTransform.ty = bounds.y;
				bounds.x = 0;
				bounds.y = 0;
				currentTransform = startTransform.clone();
				
				for ( i = 0; i < skins.length; i++ )
				{
					skin = ISkin2D( skins[i] );
					startTransforms[i].translate(-startTransform.tx, -startTransform.ty);
				}
			}
			
			storeTransforms();
		}
		
		private function preapplyTransform( transform:Matrix ):void
		{
			var newTransform:Matrix = transform.clone();
			newTransform.concat( startTransform );
			currentTransform = newTransform.clone();
			
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var skin:ISkin2D = skins[i];
				newTransform = startTransforms[i].clone();
				newTransform.concat( currentTransform );
				
				suppressInvalidateSkinHandler = true;
				skin.transform2D.matrix = newTransform;
				suppressInvalidateSkinHandler = false;
			}
			
			updateDisplay();
		}
		
		private function applyTransform( transform:Matrix ):void
		{
			var newTransform:Matrix = startTransform.clone();
			newTransform.concat( transform );
			currentTransform = newTransform.clone();
			
			if (!skins) return;
			
			for ( var i:int = 0; i < skins.length; i++ )
			{
				var skin:ISkin2D = skins[i];
				newTransform = startTransforms[i].clone();
				newTransform.concat( currentTransform );
				
				suppressInvalidateSkinHandler = true;
				skin.transform2D.matrix = newTransform;
				suppressInvalidateSkinHandler = false;
			}
			
			updateDisplay();
		}
		
		private function commitTransform():void
		{
			var skin:ISkin2D;
			var i:int;
			
			var newTransforms:Array = [];
			
			for ( i = 0; i < skins.length; i++ )
			{
				skin = skins[i];
				newTransforms.push( skin.transform2D.matrix.clone() );
				
				suppressInvalidateSkinHandler = true;
				skin.transform2D.matrix = storedTransforms[i];
				suppressInvalidateSkinHandler = false;
			}
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Change Transform";
			
			for ( i = 0; i < skins.length; i++ )
			{
				skin = skins[i];
				var changePropertyOperation:ChangePropertyOperation = new ChangePropertyOperation( skin.transform2D, "matrix", newTransforms[i] );
				operation.addOperation( changePropertyOperation );
			}
			
			suppressInvalidateSkinHandler = true;
			context.operationManager.addOperation( operation );
			suppressInvalidateSkinHandler = false;
			
			storeTransforms();
			startTransform = currentTransform.clone();
			updateDisplay();
		}
		
		// Handlers
		private function mouseDownBoxHandler( event:MouseEvent ):void
		{
			interactMode = SCALE_MODE;
			var snappedMousePos:Point = getSnappedWorldMouse();
			mouseDownX = snappedMousePos.x;
			mouseDownY = snappedMousePos.y
			ignoreNextMouseUp = true;
			ignoreDragDetect = true;
			
			context.snapManager.ignoreClosestPointTo(view.worldMouse);
			
			switch ( event.target )
			{
				case overlay.leftBox :
					scaleMode = LEFT;
					break;
				case overlay.rightBox :
					scaleMode = RIGHT;
					break;
				case overlay.topBox :
					scaleMode = TOP;
					break;
				case overlay.bottomBox :
					scaleMode = BOTTOM;
					break
				case overlay.topLeftBox :
					scaleMode = TOP | LEFT;
					break
				case overlay.topRightBox :
					scaleMode = TOP | RIGHT;
					break
				case overlay.bottomLeftBox :
					scaleMode = BOTTOM | LEFT;
					break
				case overlay.bottomRightBox :
					scaleMode = BOTTOM | RIGHT;
					break
			}
		}
		
		protected function mouseDownRotationAreaHandler( event:MouseEvent ):void
		{
			interactMode = ROTATE_MODE;
			mouseDownX = view.worldMouse.x;
			mouseDownY = view.worldMouse.y
			ignoreNextMouseUp = true;
			ignoreDragDetect = true;
		}
		
		protected function mouseDownTranslateAreaHandler( event:MouseEvent ):void
		{
			interactMode = TRANSLATE_MODE;
			
			mouseDownX = view.worldMouse.x;
			mouseDownY = view.worldMouse.y;
			ignoreNextMouseUp = true;
			ignoreDragDetect = true;
		}
		
		override protected function onMouseMoveContainer(event:PickingManagerEvent):void
		{
			if ( interactMode == 0 ) return;
			
			switch ( interactMode )
			{
				case TRANSLATE_MODE :
					translateActors( getSnappedWorldMouse() );
					break;
				case ROTATE_MODE :
					rotateActors( getSnappedWorldMouse() );
					break;
				case SCALE_MODE :
					scaleActors( getSnappedWorldMouse(), event.shiftKey );
					break;
			}
		}
		
		
		
		override protected function onMouseUpStage(event:PickingManagerEvent):void
		{
			if ( interactMode == 0 ) return;
			interactMode = 0;
			commitTransform();
			
			context.snapManager.clearIgnore();
			
			if ( !overBoxes && ! overRotationArea )
			{
				CursorManager.setCursor( null );
			}
		}
				
		// Transform handlers
		protected function translateActors( mousePos:Point ):void
		{
			var dx:Number = mousePos.x - mouseDownX;
			var dy:Number = mousePos.y - mouseDownY;
			
			applyTransform( new Matrix( 1, 0, 0, 1, dx, dy ) );
		}
		
		protected function rotateActors( mousePos:Point ):void
		{
			var dx:Number = mouseDownX - storedTransform.tx;
			var dy:Number = mouseDownY - storedTransform.ty;
			
			var mx:Number = mousePos.x - storedTransform.tx;
			var my:Number = mousePos.y - storedTransform.ty;
			
			var angle:Number = Math.atan2( my, mx ) - Math.atan2( dy, dx );
			
			var m:Matrix = new Matrix();
			m.translate( -startTransform.tx, -startTransform.ty );
			m.rotate( angle );
			m.translate( startTransform.tx, startTransform.ty );
			applyTransform( m );
		}
		
		
		protected function scaleActors( mousePos:Point, constrain:Boolean ):void
		{
			var globalToLocalMatrix:Matrix = startTransform.clone();
			globalToLocalMatrix.invert();
			
			var mouseDownPos:Point = globalToLocalMatrix.transformPoint( new Point( mouseDownX, mouseDownY ) );
			var localMousePos:Point = globalToLocalMatrix.transformPoint( mousePos );
			
			var dx:Number = localMousePos.x - mouseDownPos.x;
			var dy:Number = localMousePos.y - mouseDownPos.y;
			
			
			if ( constrain )
			{
				var value:Number = dx*0.5 + dy*0.5
				dx = dy = value;
			}
			
			
			var transform:Matrix = scale( dx, dy );
			
			if ( false )
			{
				applyTransform( transform );
			}
			else
			{
				preapplyTransform( transform );
			}
		}
		
		private function scale( dx:Number, dy:Number ):Matrix
		{
			var xRatio:Number;
			var yRatio:Number;
			
			var scaleOffsetX:Number = 0;
			var scaleOffsetY:Number = 0;
			var offsetX:Number = 0;
			var offsetY:Number = 0;
		
			
			if ( ( scaleMode & LEFT ) != 0 )
			{
				xRatio = bounds.right / bounds.width;
				scaleOffsetX -= dx  / bounds.width;
				
				offsetX += (xRatio) * dx;
			}
			else if ( ( scaleMode & RIGHT ) != 0 )
			{
				xRatio = bounds.left / bounds.width;
				scaleOffsetX += dx / bounds.width;
				
				offsetX -= (xRatio) * dx;
			}
			
			if ( ( scaleMode & TOP ) != 0 )
			{
				yRatio = bounds.bottom / bounds.height;
				scaleOffsetY -= dy / bounds.height;
				offsetY += (yRatio) * dy;
			}
			else if ( ( scaleMode & BOTTOM ) != 0 )
			{
				yRatio = bounds.top / bounds.height;
				scaleOffsetY += dy / bounds.height;
				offsetY -= (yRatio) * dy;
			}
			
			var m:Matrix = new Matrix();
			m.scale( 1+scaleOffsetX, 1+scaleOffsetY );
			m.translate(offsetX,offsetY);
			
			return m;
		}
		
		
		private function isScaleModeActive( value:int ):Boolean
		{
			return (scaleMode & value) != 0;
		}
	}
}