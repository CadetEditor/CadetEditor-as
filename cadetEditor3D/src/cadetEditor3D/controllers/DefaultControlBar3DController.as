package cadetEditor3D.controllers
{
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.controllers.ICadetContextController;
	import cadetEditor.controllers.ICadetEditorContextController;
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.events.CadetEditorViewEvent;
	
	import cadetEditor3D.contexts.CadetEditorContext3D;
	import cadetEditor3D.ui.controlBars.CadetEditorControlBar;
	import cadetEditor3D.ui.views.CadetEditorView3D;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import core.events.PropertyChangeEvent;
	import core.editor.CoreEditor;
	import core.editor.core.IViewContainer;
	import core.ui.components.HBox;
	import core.ui.util.BindingUtil;
	
	public class DefaultControlBar3DController extends EventDispatcher implements ICadetEditorContextController
	{
		private var _context								:CadetEditorContext3D;
		private var _view									:CadetEditorView3D;
		
		private var _controlBar								:CadetEditorControlBar;
		
		public function DefaultControlBar3DController()
		{
			
		}
		
		public function init(context:ICadetEditorContext):void
		{
			_context 	= CadetEditorContext3D(context);
			_view		= _context.view3D;
			
			_controlBar = new CadetEditorControlBar();
			//_controlBar.paddingLeft = 10;
			//_controlBar.paddingRight = 0;
			/*
			BindingUtil.bindTwoWay(_view, "zoom", _controlBar.zoomControl, "value");
			BindingUtil.bindTwoWay(_view, "showGrid", _controlBar.gridToggle, "selected" );
			BindingUtil.bindTwoWay(_view, "gridSize", _controlBar.gridSizeControl, "value" );
			
			_controlBar.snapToggle.addEventListener("rightClick", rightClickSnapToggleHandler);
			
			_view.gridSize = 20;
			_view.showGrid = true;
			*/
			IViewContainer(_view.parent.parent).actionBar.addChild(_controlBar);
			
			//_view.addEventListener("propertyChange_zoom", zoomChangeHandler );
		}
		/*
		private function zoomChangeHandler( event:PropertyChangeEvent ):void
		{
			_controlBar.zoomControl.value = event.newValue;//_zoom;
			_controlBar.zoomAmountLabel.text = String( int(_controlBar.zoomControl.value * 100 ) + "%" );
		}
		*/
		public function dispose():void
		{
//			BindingUtil.unbindTwoWay(_view, "zoom", _controlBar.zoomControl, "value");
//			BindingUtil.unbindTwoWay(_view, "showGrid", _controlBar.gridToggle, "selected" );
//			BindingUtil.unbindTwoWay(_view, "gridSize", _controlBar.gridSizeControl, "value" );
//			// shouldn't this be added?
//			//_controlBar.snapToggle.removeEventListener("rightClick", rightClickSnapToggleHandler);
//			
//			_view.removeEventListener("propertyChange_zoom", zoomChangeHandler ); // Rob put this here
		}
		
		// From CadetEditorContext2D
		public function initScene():void
		{
			// used to use private instead of public properties... (_showGrid not showGrid)
//			_view.showGrid = _context.scene.userData.showGrid == "0" ? false : true;
//			_view.zoom = _context.scene.userData.zoom == null ? 1 : Number(_context.scene.userData.zoom);
//			_view.panX = _context.scene.userData.panX == null ? _view.viewportWidth/2 : Number(_context.scene.userData.panX);
//			_view.panY = _context.scene.userData.panY == null ? _view.viewportHeight/2 : Number(_context.scene.userData.panY);
//			_view.gridSize = _context.scene.userData.gridSize == null ? 10 : Number(_context.scene.userData.gridSize);
//			
//			BindingUtil.bindTwoWay( _context.snapManager, "snapEnabled", CadetEditorControlBar(_controlBar).snapToggle, "selected" );	
		}
		
		// From CadetEditorContext2D
		public function disposeScene():void
		{
//			BindingUtil.unbindTwoWay( _controlBar.snapToggle, "selected", _context.snapManager, "snapEnabled"  );
		}
		/*
		private function rightClickSnapToggleHandler( event:MouseEvent ):void
		{
			CoreEditor.commandManager.executeCommand( CadetEditorCommands.EDIT_SNAP_SETTINGS );
		}
		*/
		
		public function get controlBar():HBox
		{
			return _controlBar;
		}
	}
}