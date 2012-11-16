package cadetEditor3D.controllers
{
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet3D.components.behaviours.RigidBodyBehaviour;
	import cadet3D.components.core.MeshComponent;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.controllers.ICadetContextController;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.ui.controlBars.PhysicsToolControlBar;
	import cadetEditor3D.ui.views.CadetEditorView3D;
	
	import flash.events.Event;
	
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.RemoveItemOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.core.data.ArrayCollection;
	import flox.editor.FloxEditor;
	import flox.editor.core.IViewContainer;
	
	public class PhysicsControlBarController implements ICadetContextController
	{
		private var _context								:CadetEditorContext3D;
		private var _view									:CadetEditorView3D;
		
		private var _controlBar								:PhysicsToolControlBar;
		
		public function PhysicsControlBarController()
		{
		}
		
		public function init(context:ICadetEditorContext):void
		{
			_context 	= CadetEditorContext3D(context);
			_view		= _context.view3D;
			
			_controlBar = new PhysicsToolControlBar();
			_controlBar.paddingLeft = 0;
			_controlBar.paddingRight = 0;
			
			IViewContainer(_view.parent.parent).actionBar.addChild(_controlBar);
			
			_context.selection.addEventListener("change", selectionChangeHandler);
			
			updateControlBar();
		}
		
		public function dispose():void
		{
			_context.selection.removeEventListener("change", selectionChangeHandler);
		}
		
		private function selectionChangeHandler( event:Event ):void
		{
			updateControlBar();
		}
		
		private function updateControlBar():void
		{
			removeListeners();
			
			_controlBar.rigidBodyCheckbox.selected = false;
			
			_controlBar.rigidBodyCheckbox.enabled = false;
			
			if ( _context.selection.length > 0 ) 
			{
				if (allComponentsAreMeshes())
				{
					_controlBar.rigidBodyCheckbox.enabled = true;
					
					if (allComponentsContain([RigidBodyBehaviour])) 
					{
						_controlBar.rigidBodyCheckbox.selected = true;
//						_controlBar.fixedCheckBox.enabled = true;
//						_controlBar.mouseDragCheckbox.enabled = true;
//						
//						if (allRigidBodiesAreFixed()) {
//							_controlBar.fixedCheckBox.selected = true;
//						}
//						if (allComponentsContain([RigidBodyMouseDragBehaviour])) {
//							_controlBar.mouseDragCheckbox.selected = true;
//						}
					}
				}
			}

			addListeners();
		}
		
		private function allComponentsAreMeshes():Boolean
		{
			for ( var i:uint = 0; i < _context.selection.length; i ++ )
			{
				if (!(_context.selection[i] is MeshComponent) )
				{
					return false;
				}
			}
			
			return true;
		}
		
		private function noComponentsContain(blackList:Array):Boolean
		{
			for ( var i:uint = 0; i < _context.selection.length; i ++ )
			{
				if (_context.selection[i] is IComponentContainer )
				{
					var container:IComponentContainer = _context.selection[i];
					for ( var j:uint = 0; j < blackList.length; j ++ )
					{
						var type:Class = blackList[j];
						var obj:Object = ComponentUtil.getChildOfType(container, type, false);
						// Return false if a black listed item is present.
						if ( obj ) {
							return false;
						}
					}
				}
			}
			return true;
		}
		
		private function allComponentsContain(whiteList:Array):Boolean
		{
			var numObjects:uint = 0;
			var numComponentContainers:uint = 0;
			for ( var i:uint = 0; i < _context.selection.length; i ++ )
			{
				if (_context.selection[i] is IComponentContainer )
				{
					numComponentContainers ++;
					var container:IComponentContainer = _context.selection[i];
					for ( var j:uint = 0; j < whiteList.length; j ++ )
					{
						var type:Class = whiteList[j];
						var obj:Object = ComponentUtil.getChildOfType(container, type, false);
						// Return false if a black listed item is present.
						if ( obj ) {
							numObjects ++;
						}
					}		
				}
			}
			
			if (numComponentContainers > 0 && numObjects == numComponentContainers) {
				return true;
			}
			
			return false;			
		}

		private function removeListeners():void
		{
			_controlBar.rigidBodyCheckbox.removeEventListener(Event.CHANGE, rigidBodyCheckBoxChangeHandler);
//			_controlBar.fixedCheckBox.removeEventListener(Event.CHANGE, fixedCheckBoxChangeHandler);
//			_controlBar.mouseDragCheckbox.removeEventListener(Event.CHANGE, mouseDragCheckBoxChangeHandler);
//			_controlBar.createJointCheckBox.removeEventListener(Event.CHANGE, jointCheckBoxChangeHandler);
//			_controlBar.jointTypeList.removeEventListener(Event.CHANGE, jointListSelectionChangeHandler);
		}
		private function addListeners():void
		{
			_controlBar.rigidBodyCheckbox.addEventListener(Event.CHANGE, rigidBodyCheckBoxChangeHandler);
//			_controlBar.fixedCheckBox.addEventListener(Event.CHANGE, fixedCheckBoxChangeHandler);
//			_controlBar.mouseDragCheckbox.addEventListener(Event.CHANGE, mouseDragCheckBoxChangeHandler);
//			_controlBar.createJointCheckBox.addEventListener(Event.CHANGE, jointCheckBoxChangeHandler);
//			_controlBar.jointTypeList.addEventListener(Event.CHANGE, jointListSelectionChangeHandler);
		}

		
		private function rigidBodyCheckBoxChangeHandler(event:Event):void
		{
			var selected:Boolean = _controlBar.rigidBodyCheckbox.selected;
			
			// if deselecting (removing) rigidBodyBehaviours, remove rigidBodyMouseDragBehaviours too
			if (!selected) {
				removeListeners();
				//_controlBar.mouseDragCheckbox.selected = false;
				//_controlBar.fixedCheckBox.selected = false;
				addListeners();
			}
			
			if (selected) {
				addComponents([RigidBodyBehaviour], "Add RigidBodyBehaviour(s)");
			} else {
				//removeComponents([RigidBodyBehaviour, RigidBodyMouseDragBehaviour], "Remove RigidBodyBehaviour/MouseDragBehaviour(s)");
				removeComponents([RigidBodyBehaviour], "Remove RigidBodyBehaviour(s)");
			}
		}
		
		private function addComponents(types:Array, label:String):void
		{			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = label;
			
			for ( var i:uint = 0; i < _context.selection.length; i ++ )
			{
				if (_context.selection[i] is IComponentContainer )
				{
					var container:IComponentContainer = _context.selection[i];
					
					for ( var j:uint = 0; j < types.length; j ++ ) 
					{
						var type:Class = types[j];
						
						var obj:Object = ComponentUtil.getChildOfType(container, type, false);
						
						if (!obj) {
							var newComponent:Object = new type();
							var addItemOperation:AddItemOperation = new AddItemOperation( newComponent, container.children );
							operation.addOperation( addItemOperation );							
						}						
					}
				}
			}
			
			_context.operationManager.addOperation(operation);			
		}
		
		private function removeComponents(types:Array, label:String = "Remove Component"):void
		{			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = label;
			
			for ( var i:uint = 0; i < _context.selection.length; i ++ )
			{
				if (_context.selection[i] is IComponentContainer )
				{
					var container:IComponentContainer = _context.selection[i];
					
					for ( var j:uint = 0; j < types.length; j ++ ) 
					{
						var type:Class = types[j];
						
						var obj:Object = ComponentUtil.getChildOfType(container, type, false);
						
						if (obj) {
							var removeItemOperation:RemoveItemOperation = new RemoveItemOperation( obj, container.children );
							operation.addOperation( removeItemOperation );								
						}						
					}
				}
			}
			
			_context.operationManager.addOperation(operation);			
		}
		/*
		private function fixedCheckBoxChangeHandler(event:Event):void
		{
			var selected:Boolean = _controlBar.fixedCheckBox.selected;
			
			var operation:UndoableCompoundOperation = new UndoableCompoundOperation();
			operation.label = "Change fixed value on RigidBodyBehaviour(s)";
			
			for ( var i:uint = 0; i < _context.selection.length; i ++ )
			{
				if (_context.selection[i] is IComponentContainer )
				{			
					var container:IComponentContainer = _context.selection[i];
					var rigidBodyBehaviour:RigidBodyBehaviour = ComponentUtil.getChildOfType(container, RigidBodyBehaviour, false);
					
					if (rigidBodyBehaviour) 
					{
						if (rigidBodyBehaviour.fixed != selected) {
							var changePropertyOperation:ChangePropertyOperation = new ChangePropertyOperation(rigidBodyBehaviour, "fixed", selected, rigidBodyBehaviour.fixed);
							operation.addOperation( changePropertyOperation );	
						} 
					}
				}
			}
			
			_context.operationManager.addOperation(operation);
		}
		*/
	}
}














