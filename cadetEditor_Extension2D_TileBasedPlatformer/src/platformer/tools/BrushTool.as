package platformer.tools
{
	import cadet.util.ComponentUtil;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.renderPipeline.flash.components.skins.AssetSkin;
	
	import cadetEditor.assets.CadetEditorIcons;
	import cadetEditor.contexts.ICadetEditorContext;
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.tools.ITool;
	
	import cadetEditor2D.events.PickingManagerEvent;
	import cadetEditor2D.managers.SnapInfo;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import cadetEditor2DFlash.tools.CadetEditorTool2D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flox.app.FloxApp;
	import flox.app.core.contexts.IContext;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.entities.URI;
	import flox.app.managers.ResourceManager;
	import flox.app.operations.AddItemOperation;
	import flox.app.operations.BindResourceOperation;
	import flox.app.operations.ChangePropertyOperation;
	import flox.app.operations.UndoableCompoundOperation;
	import flox.app.resources.ExternalBitmapDataResource;
	import flox.app.resources.IResource;
	import flox.editor.FloxEditor;
	import flox.ui.components.Button;
	
	import platformer.components.behaviours.TileBehaviour;
	import platformer.components.processes.GridProcess;
	import platformer.operations.AddTileOperation;
	import platformer.ui.panels.BrushesPanel;
	
	public class BrushTool extends CadetEditorTool2D implements ITool
	{
		protected var dragging				:Boolean = false;
		protected var mouseDownPoint		:Point;
		protected var currentMousePoint		:Point;
		
		[Embed( source = 'platformer/assets/brush.png' )] 	
		static public var BrushToolImg:Class;

		//private var tileLinkage:String = "tiles/asphalt0/";
		private var configURI:URI;
		
		private var panel:BrushesPanel;
		//private var brushes:Array;
		private var brushesList:XMLList;
		private var currentBrush:XML;
		
		static public function getFactory():ToolFactory
		{
			return new ToolFactory( ICadetEditorContext, BrushTool, "Brush Tool", BrushToolImg );
		}
		
		
		public function BrushTool()
		{
			//brushes = [];
		}
		
		override public function init( context:IContext ):void
		{
			super.init(context);
			
			_context.addEventListener(Event.CHANGE, contextChangeHandler);
		}
		override public function enable():void
		{
			super.enable();
			
			openPanel();
		}
		override public function disable():void
		{
			super.disable();
			
			disposePanel();
		}

		private function contextChangeHandler( event:Event ):void
		{
			if ( configURI ) return;
			
			if ( _context.uri ) {
				configURI = new URI( FloxEditor.getProjectDirectoryURI(_context.uri).path + "editor/brushes.xml" );
				var operation:IReadFileOperation = FloxApp.fileSystemProvider.readFile( configURI );
				operation.addEventListener(ErrorEvent.ERROR, readFileErrorHandler);
				operation.addEventListener( Event.COMPLETE, loadConfigCompleteHandler );
				operation.execute();
			}
		}
		
		private function readFileErrorHandler( event:ErrorEvent ):void
		{
			trace("READ BRUSHES XML ERRROR");
		}
		
		private function loadConfigCompleteHandler( event:Event ):void
		{
			var readFileOperation:IReadFileOperation = IReadFileOperation(event.target);
			var xmlString:String = readFileOperation.bytes.readUTFBytes(readFileOperation.bytes.length);
			var configXML:XML = XML(xmlString);
			
			brushesList = configXML.brush;
//			for ( var i:int = 0; i < brushesList.length(); i++ )
//			{
//				var brush:XML = brushesList[i];
//				trace("brush "+brush.@path);
//				brushes.push(brush.@path);
//			}
		}
		
		private function openPanel():void
		{
			if (panel) return;
			
//			var assetsURI:URI = new URI(FloxEditor.getProjectDirectoryURI().path+FloxApp.externalResourceFolderName);
			panel = new BrushesPanel(brushesList);
			panel.addEventListener( Event.CHANGE, brushChangeHandler );
			panel.label = "Brushes";
			panel.dragEnabled = true;
			panel.x = 31;
			panel.y = 114;
			
			FloxEditor.viewManager.addPopUp(panel, false, false);
//			panel.list.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
//			panel.okBtn.addEventListener(MouseEvent.CLICK, clickOkHandler);
//			panel.cancelBtn.addEventListener(MouseEvent.CLICK, clickCancelHandler);
			
			currentBrush = brushesList[panel.selectedIndex];
		}
		
		private function disposePanel():void
		{
			if (!panel) return;
			panel.removeEventListener( Event.CHANGE, brushChangeHandler );
//			panel.list.removeEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
//			panel.okBtn.removeEventListener(MouseEvent.CLICK, clickOkHandler);
//			panel.cancelBtn.removeEventListener(MouseEvent.CLICK, clickCancelHandler);
			FloxEditor.viewManager.removePopUp(panel);
			panel = null;
		}
		
		private function brushChangeHandler( event:Event ):void
		{
			//tileLinkage = brushesList[panel.selectedIndex].@path;
			currentBrush = brushesList[panel.selectedIndex];
		}
		
		override protected function onMouseDownContainer( event:PickingManagerEvent ):void
		{
			dragging = true;
			
			mouseDownPoint = context.snapManager.snapPoint(ICadetEditorView2D(view).worldMouse).snapPoint;
			currentMousePoint = mouseDownPoint;
			
			drawTile();
			
			onMouseMoveContainer(null);
		}
		
		override protected function onMouseUpStage(event:PickingManagerEvent):void
		{
			if ( !dragging ) return;
			dragging = false;
		}
		
		override protected function onMouseMoveContainer(event:PickingManagerEvent):void
		{
			if ( !dragging ) return;
			
			var snapInfo:SnapInfo = context.snapManager.snapPoint( ICadetEditorView2D(view).worldMouse );
			var snappedMousePos:Point = snapInfo.snapPoint;
			
			//var dx:Number = snappedMousePos.x - mouseDownPoint.x;
			//var dy:Number = snappedMousePos.y - mouseDownPoint.y;
			
			if (snapInfo.snapType == 1 && (snappedMousePos.x != currentMousePoint.x || snappedMousePos.y != currentMousePoint.y)) {
				currentMousePoint = snappedMousePos;
				
				//trace("DRAW TILE sx"+snappedMousePos.x+" cx "+currentMousePoint.x+" sy "+snappedMousePos.y+" cy "+currentMousePoint.y+" snapType "+snapInfo.snapType);
				drawTile();
			}
		}
		
		private function drawTile():void
		{
			var addTileOperation:AddTileOperation = new AddTileOperation(context, currentMousePoint.x, currentMousePoint.y, currentBrush);
			context.operationManager.addOperation( addTileOperation );			
		}
		
		// Abstract functions
		protected function initializeComponent():void {}
		protected function getName():String { return "Tile"; }
	}
}










