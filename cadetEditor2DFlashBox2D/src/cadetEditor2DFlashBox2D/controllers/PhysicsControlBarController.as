package cadetEditor2DFlashBox2D.controllers
{
	import cadet.core.IComponentContainer;
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.connections.Connection;
	import cadet2D.components.connections.Pin;
	import cadet2DBox2D.components.behaviours.RigidBodyMouseDragBehaviour;
	import cadet2DFlash.components.skins.SpringSkin;
	
	import cadet2DBox2D.components.behaviours.DistanceJointBehaviour;
	import cadet2DBox2D.components.behaviours.PrismaticJointBehaviour;
	import cadet2DBox2D.components.behaviours.RevoluteJointBehaviour;
	import cadet2DBox2D.components.behaviours.RigidBodyBehaviour;
	import cadet2DBox2D.components.behaviours.SpringBehaviour;
	
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.controllers.ICadetContextController;
	
	import cadetEditor2D.contexts.ICadetEditorContext2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import cadetEditor2DBox2D.ui.controlBars.PhysicsToolControlBar;
	
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
		private var _context								:ICadetEditorContext2D;
		private var _view									:ICadetEditorView2D;
		
		private var _controlBar								:PhysicsToolControlBar;
				
		public function PhysicsControlBarController()
		{
		}
		
		public function init(context:ICadetEditorContext):void
		{
			_context 	= ICadetEditorContext2D(context);
			_view		= _context.view2D;
			
			_controlBar = new PhysicsToolControlBar();
			_controlBar.paddingLeft = -70;
			_controlBar.paddingRight = 0;
			
			IViewContainer(_view.parent.parent).actionBar.addChild(_controlBar);
			
			_context.selection.addEventListener("change", selectionChangeHandler);
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
			_controlBar.fixedCheckBox.selected = false;
			_controlBar.mouseDragCheckbox.selected = false;
			
			_controlBar.createJointCheckBox.selected = false;
			
			
			_controlBar.rigidBodyCheckbox.enabled = false;
			_controlBar.fixedCheckBox.enabled = false;
			_controlBar.mouseDragCheckbox.enabled = false;			
			
			_controlBar.createJointCheckBox.enabled = false;
			
			if ( _context.selection.length > 0 ) 
			{
				if (allComponentsContain([Pin]))
				{
					_controlBar.createJointCheckBox.enabled = true;
					_controlBar.jointTypeList.dataProvider = new ArrayCollection( [PhysicsToolControlBar.JOINT_REVOLUTE] );
					
					if (allComponentsContain([RevoluteJointBehaviour])) 
					{
						_controlBar.createJointCheckBox.selected = true;
					}
				}
				else if (allComponentsContain([Connection]))
				{
					_controlBar.createJointCheckBox.enabled = true;
					_controlBar.jointTypeList.dataProvider = new ArrayCollection( [PhysicsToolControlBar.JOINT_DISTANCE, PhysicsToolControlBar.JOINT_SPRING, PhysicsToolControlBar.JOINT_PRISMATIC] );
					
					if (allComponentsContain([DistanceJointBehaviour])) 
					{
						_controlBar.createJointCheckBox.selected = true;
						_controlBar.jointTypeList.selectedItem = PhysicsToolControlBar.JOINT_DISTANCE;
					}
					else if (allComponentsContain([SpringBehaviour])) 
					{
						_controlBar.createJointCheckBox.selected = true;
						_controlBar.jointTypeList.selectedItem = PhysicsToolControlBar.JOINT_SPRING;
					}
					else if (allComponentsContain([PrismaticJointBehaviour])) 
					{
						_controlBar.createJointCheckBox.selected = true;
						_controlBar.jointTypeList.selectedItem = PhysicsToolControlBar.JOINT_PRISMATIC;
					}
					else if (allComponentsContain([DistanceJointBehaviour, SpringBehaviour, PrismaticJointBehaviour])) 
					{
						_controlBar.createJointCheckBox.selected = true;
						_controlBar.jointTypeList.dataProvider.addItemAt("--", 0);
						_controlBar.jointTypeList.selectedItem = "--";
					}
				}
				else if (noComponentsContain([Pin, Connection]))
				{
					_controlBar.rigidBodyCheckbox.enabled = true;
					
					if (allComponentsContain([RigidBodyBehaviour])) 
					{
						_controlBar.rigidBodyCheckbox.selected = true;
						_controlBar.fixedCheckBox.enabled = true;
						_controlBar.mouseDragCheckbox.enabled = true;
						
						if (allRigidBodiesAreFixed()) {
							_controlBar.fixedCheckBox.selected = true;
						}
						if (allComponentsContain([RigidBodyMouseDragBehaviour])) {
							_controlBar.mouseDragCheckbox.selected = true;
						}
					}
				}
			}
			
			addListeners();
			
//			if ( context.selection.length > 0 ) {
//				if (containsOneComponentContainer(context.selection)) {
//					addControlBar();
//				} else {
//					removeControlBar();
//				}
//			} else {
//				removeControlBar();
//			}
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
		
		private function allRigidBodiesAreFixed():Boolean
		{
			var numRBBehaviours:uint = 0;
			var numFixedRBs:uint = 0;
			for ( var i:uint = 0; i < _context.selection.length; i ++ )
			{
				if (_context.selection[i] is IComponentContainer )
				{
					var container:IComponentContainer = _context.selection[i];
					var rigidBodyBehaviour:RigidBodyBehaviour = ComponentUtil.getChildOfType(container, RigidBodyBehaviour, false);
					
					if (rigidBodyBehaviour) {
						numRBBehaviours ++;
						if (rigidBodyBehaviour.fixed) {
							numFixedRBs ++;
						}
					}
				}
			}
			
			if (numRBBehaviours > 0 && numFixedRBs == numRBBehaviours) {
				return true;
			}
			
			return false;
		}			
		
		private function removeListeners():void
		{
			_controlBar.rigidBodyCheckbox.removeEventListener(Event.CHANGE, rigidBodyCheckBoxChangeHandler);
			_controlBar.fixedCheckBox.removeEventListener(Event.CHANGE, fixedCheckBoxChangeHandler);
			_controlBar.mouseDragCheckbox.removeEventListener(Event.CHANGE, mouseDragCheckBoxChangeHandler);
			_controlBar.createJointCheckBox.removeEventListener(Event.CHANGE, jointCheckBoxChangeHandler);
			_controlBar.jointTypeList.removeEventListener(Event.CHANGE, jointListSelectionChangeHandler);
		}
		private function addListeners():void
		{
			_controlBar.rigidBodyCheckbox.addEventListener(Event.CHANGE, rigidBodyCheckBoxChangeHandler);
			_controlBar.fixedCheckBox.addEventListener(Event.CHANGE, fixedCheckBoxChangeHandler);
			_controlBar.mouseDragCheckbox.addEventListener(Event.CHANGE, mouseDragCheckBoxChangeHandler);
			_controlBar.createJointCheckBox.addEventListener(Event.CHANGE, jointCheckBoxChangeHandler);
			_controlBar.jointTypeList.addEventListener(Event.CHANGE, jointListSelectionChangeHandler);
		}
		
		private function jointListSelectionChangeHandler(event:Event):void
		{
			var typeStr:String = String(_controlBar.jointTypeList.selectedItem);
			var type:Class = getJointType(typeStr);
			
			if (!type) return;
			
			var types:Array = [type];
			
			removeComponents([RevoluteJointBehaviour, PrismaticJointBehaviour, SpringBehaviour, DistanceJointBehaviour, SpringSkin], "Remove JointBehaviour(s)");
			
			if ( type == SpringBehaviour ) {
				types.push(SpringSkin);
			}
			addComponents(types, "Add "+type+"JointBehaviour(s)");
		}
		
		private function getJointType(type:String):Class
		{
			if ( type == PhysicsToolControlBar.JOINT_REVOLUTE ) {
				return RevoluteJointBehaviour;
			}
			
			if ( type == PhysicsToolControlBar.JOINT_PRISMATIC ) {
				return PrismaticJointBehaviour;
			} 
			
			if ( type == PhysicsToolControlBar.JOINT_SPRING ) {
				return SpringBehaviour;
			}
			
			if ( type == PhysicsToolControlBar.JOINT_DISTANCE ) {
				return DistanceJointBehaviour;
			}
			
			return null;
		}
		
		private function jointCheckBoxChangeHandler(event:Event):void
		{
			var selected:Boolean = _controlBar.createJointCheckBox.selected;
			var typeStr:String = String(_controlBar.jointTypeList.selectedItem);
			var type:Class = getJointType(typeStr);
			
			if (type)
			{
				var types:Array = [type];
				
				if (selected) {
					removeComponents([RevoluteJointBehaviour, PrismaticJointBehaviour, SpringBehaviour, DistanceJointBehaviour, SpringSkin], "Remove JointBehaviour(s)");
					
					if ( type == SpringBehaviour ) {
						types.push(SpringSkin);
					}
					addComponents(types, "Add "+type+"JointBehaviour(s)");
				} else {
					removeComponents([type], "Remove "+type+"JointBehaviour(s)");
				}
			}
			else
			{
				// if deselected when joint dropdown displays "--"
				if (!selected) {
					removeComponents([DistanceJointBehaviour, SpringBehaviour, PrismaticJointBehaviour]);
				}
			}
		}
		
		private function mouseDragCheckBoxChangeHandler(event:Event):void
		{
			if (_controlBar.mouseDragCheckbox.selected) {
				addComponents([RigidBodyMouseDragBehaviour], "Add RigidBodyMouseDragBehaviour(s)");
			} else {
				removeComponents([RigidBodyMouseDragBehaviour], "Remove RigidBodyMouseDragBehaviour(s)");
			}
		}

		private function rigidBodyCheckBoxChangeHandler(event:Event):void
		{
			var selected:Boolean = _controlBar.rigidBodyCheckbox.selected;
			
			// if deselecting (removing) rigidBodyBehaviours, remove rigidBodyMouseDragBehaviours too
			if (!selected) {
				removeListeners();
				_controlBar.mouseDragCheckbox.selected = false;
				_controlBar.fixedCheckBox.selected = false;
				addListeners();
			}
			
			if (selected) {
				addComponents([RigidBodyBehaviour], "Add RigidBodyBehaviour(s)");
			} else {
				removeComponents([RigidBodyBehaviour, RigidBodyMouseDragBehaviour], "Remove RigidBodyBehaviour/MouseDragBehaviour(s)");
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
	}
}














