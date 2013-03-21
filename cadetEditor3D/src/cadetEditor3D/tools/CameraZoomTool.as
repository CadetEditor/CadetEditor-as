// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.cameras.Camera3D;
	
	import cadet3D.components.renderers.Renderer3D;
	
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.tools.ITool;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.events.RendererChangeEvent;
	import cadetEditor3D.icons.CadetEditor3DIcons;
	import cadetEditor3D.ui.views.CadetEditorView3D;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import core.editor.CoreEditor;
	import core.app.core.contexts.IContext;
	
	public class CameraZoomTool implements ITool
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
			return new ToolFactory( CadetEditorContext3D, CameraZoomTool, "Camera Zoom [D]", CadetEditor3DIcons.CameraZoom, [Keyboard.D], false );
		}
		
		public function CameraZoomTool()
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
			
			var dy:Number = y - mouseDownY;
			var sensitivity:Number = 3;
			
			var offset:Vector3D = storedCameraPos.subtract(storedCameraPivotPos);
			var newLength:Number = offset.length + dy * sensitivity;
			newLength = newLength < 50 ? 50 : newLength;
			
			offset.normalize();
			offset.scaleBy(newLength)
			camera.position = storedCameraPivotPos.add( offset  );
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