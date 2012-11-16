// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools
{
	import away3d.materials.ColorMaterial;
	
	import cadet3D.components.core.MeshComponent;
	import cadet3D.components.geom.GeometryComponent;
	import cadet3D.components.materials.ColorMaterialComponent;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import flox.editor.FloxEditor;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;

	public class AbstractPrimitveTool extends AbstractTool
	{
		static protected var defaultMaterialComponent	:ColorMaterialComponent;
	
		private var active	:Boolean = false;
		
		protected var meshComponent			:MeshComponent;
		
		public function AbstractPrimitveTool()
		{
			if ( defaultMaterialComponent == null )
			{
				defaultMaterialComponent = new ColorMaterialComponent();
				defaultMaterialComponent.name = "Default Primitive Material";
			}
		}
		
		override protected function performEnable():void
		{
			super.performEnable();
			
			renderer.view3D.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		override protected function performDisable():void
		{
			super.performDisable();
			
			if ( active )
			{
				FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				end();
			}
			
			renderer.view3D.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function mouseDownHandler( event:MouseEvent ):void
		{
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation()
			operation.label = "Create primtive";
			
			if ( defaultMaterialComponent.parentComponent == null )
			{
				operation.addOperation(new AddItemOperation( defaultMaterialComponent, context.scene.children ) );
			}
			meshComponent = new MeshComponent();
			meshComponent.materialComponent = defaultMaterialComponent;
			
			operation.addOperation( new AddItemOperation( meshComponent, context.scene.children ) );
			
			operation.addOperation( new ChangePropertyOperation( context.selection, "source", [meshComponent] ) );
			
			
			context.operationManager.addOperation(operation);
			
			begin();
			update();
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			FloxEditor.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			update();
		}
		
		private function mouseUpHandler( event:MouseEvent ):void
		{
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			FloxEditor.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			end();
		}
		
		protected function begin():void {}
		protected function update():void {}
		protected function end():void {}
		
		protected function getMousePositionOnPlane( planePos:Vector3D, planeNormal:Vector3D ):Vector3D
		{
			var rayPosition:Vector3D = renderer.view3D.camera.position;
			var rayDirection:Vector3D = renderer.view3D.unproject( renderer.view3D.mouseX, renderer.view3D.mouseY );
			rayDirection.normalize();
			
			var delta:Vector3D = planePos.subtract(rayPosition);
			var d:Number = delta.dotProduct(planeNormal) / rayDirection.dotProduct(planeNormal);
			rayDirection.scaleBy(d);
			
			return rayPosition.add( rayDirection );
		}
	}
}