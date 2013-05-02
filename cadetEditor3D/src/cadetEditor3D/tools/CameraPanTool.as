// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.core.base.Object3D;
	
	import cadet3D.components.renderers.Renderer3D;
	
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.tools.ITool;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.events.RendererChangeEvent;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.ui.views.CadetEditorView3D;
	
	import core.appEx.core.contexts.IContext;
	import core.editor.CoreEditor;
	
	public class CameraPanTool implements ITool
	{
		private var context		:CadetEditorContext3D;
		private var view		:CadetEditorView3D;
		
		private var mouseDownX	:Number;
		private var mouseDownY	:Number;
		
		private var storedCameraPos			:Vector3D;
		private var storedCameraPivotPos	:Vector3D;
		
		private var isDragging	:Boolean = false;
		
		public static function getFactory():ToolFactory
		{
			return new ToolFactory( CadetEditorContext3D, CameraPanTool, "Camera Pan [S]", CadetEditor3DIcons.CameraPan, [Keyboard.S], false );
		}
		
		public function CameraPanTool()
		{
		}
		
		public function init(c:IContext):void
		{
			context = CadetEditorContext3D(c);
			view = context.view3D;
		}
		
		public function dispose():void
		{
			disable();
			context = null
			view = null;
		}
		
		public function enable():void
		{
			context.addEventListener(RendererChangeEvent.RENDERER_CHANGE, rendererChangeHandler);
			if ( context.renderer )
			{
				registerRendererEvents(context.renderer);
			}
		}
		
		public function disable():void
		{
			if ( isDragging )
			{
				endDrag();
			}
			
			context.removeEventListener(RendererChangeEvent.RENDERER_CHANGE, rendererChangeHandler);
			if ( context.renderer )
			{
				unregisterRendererEvents( context.renderer );
			}
		}
		
		private function rendererChangeHandler( event:RendererChangeEvent ):void
		{
			if ( event.oldRenderer ) unregisterRendererEvents(Renderer3D(event.oldRenderer));
			if ( event.newRenderer ) registerRendererEvents(Renderer3D(event.newRenderer));
		}
		
		private function registerRendererEvents( renderer:Renderer3D ):void
		{
			renderer.view3D.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBackgroundHandler);
		}
		
		private function unregisterRendererEvents( renderer:Renderer3D ):void
		{
			renderer.view3D.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownBackgroundHandler);
		}
		
		private function mouseDownBackgroundHandler( event:MouseEvent ):void
		{
			beginDrag( event.stageX, event.stageY );
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			updateDrag( event.stageX, event.stageY );
		}
		
		private function mouseUpHandler( event:MouseEvent ):void
		{
			endDrag();
		}
		
		private function beginDrag( x:Number, y:Number ):void
		{
			assert( isDragging == false, "Already dragging. Need to call endDrag first" );
			assert( context.renderer != null, "Renderer unavailable." );
			
			isDragging = true;
			context.changed = true;
				
			mouseDownX = x;
			mouseDownY = y;
			
			storedCameraPos = context.renderer.view3D.camera.position.clone();
			storedCameraPivotPos = context.renderer.view3D.camera.pivotPoint.clone();
				
			CoreEditor.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			CoreEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function updateDrag( x:Number, y:Number ):void
		{
			assert( isDragging, "Drag not started. Possibly calling 'updateDrag' without first calling 'beginDrag()'" );
			assert( context.renderer != null, "Renderer unavailable." );
			
			var camera:Camera3D = context.renderer.view3D.camera;
			
			var dx:Number = x - mouseDownX;
			var dy:Number = y - mouseDownY;
			
			var focalLength:Number;
			if ( camera.lens is PerspectiveLens )
			{
				focalLength = Math.tan(PerspectiveLens(camera.lens).fieldOfView*Math.PI/360);
			}
			else
			{
				focalLength = 1;
			}
			var sensitivity:Number = 1.3;
			
			var moveRight:Number = -dx * focalLength * sensitivity;
			var moveDown:Number = -dy * focalLength * sensitivity;
			
//			camera.position = storedCameraPos;
			
			var obj3D:Object3D = new Object3D();			
			obj3D.position = storedCameraPos;
			obj3D.rotationX = camera.rotationX;
			obj3D.rotationY = camera.rotationY;
			obj3D.rotationZ = camera.rotationZ;
			//obj3D.pivotPoint = camera.pivotPoint.clone(); //TODO: issue with Pivot Point
			obj3D.moveRight( moveRight );
			obj3D.moveDown( moveDown );
			
			camera.position = obj3D.position.clone();
			
			//trace("position "+camera.position+" storedCamPos "+storedCameraPos+" moveRight "+moveRight+" moveDown "+moveDown);
			
			var offset:Vector3D = obj3D.position.subtract(storedCameraPos.clone());
			camera.pivotPoint = storedCameraPivotPos.add(offset);
		}
		
		private function endDrag():void
		{
			assert( isDragging, "No drag to end." );
			assert( context.renderer != null, "Renderer unavailable." );
			
			isDragging = false;
			
			CoreEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			CoreEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
	}
}