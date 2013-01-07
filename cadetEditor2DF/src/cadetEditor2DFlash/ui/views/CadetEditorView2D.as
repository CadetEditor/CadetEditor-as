// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2DFlash.ui.views
{
	import cadet.core.IRenderer;
	import cadet.events.InvalidationEvent;
	
	import cadet2D.components.renderers.IRenderer2D;
	import cadet2DFlash.components.renderers.Renderer2D;
	
	import cadetEditor.entities.CadetEditorCommands;
	import cadetEditor.events.CadetEditorViewEvent;
	import cadetEditor.ui.views.ToolEditorView;
	
	import cadetEditor2D.ui.controlBars.CadetEditorControlBar;
	import cadetEditor2D.ui.overlays.ICadetEditorOverlay2D;
	import cadetEditor2D.ui.views.ICadetEditorView2D;
	
	import cadetEditor2DFlash.ui.overlays.Grid2D;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flox.core.events.PropertyChangeEvent;
	import flox.editor.FloxEditor;
	import flox.editor.core.IViewContainer;
	import flox.ui.components.Container;
	import flox.ui.components.IUIComponent;
	import flox.ui.components.UIComponent;
	import flox.ui.util.BindingUtil;
	
	import starling.display.Sprite;

	[Event(type="cadetEditor.events.CadetEditorViewEvent", name="viewportChanged")]
	
	public class CadetEditorView2D extends ToolEditorView implements ICadetEditorView2D
	{
		public static const TOP		:int = 1;
		public static const ABOVE	:int = 0;
		public static const BOTTOM	:int = 2;
		
		private var _zoomMin	:Number = 0.1;
		private var _zoomMax	:Number = 4;
		
		// Display Hierachy
		private var background						:flash.display.Sprite;
		private var overlayContainerBottom			:Container;
		private var overlayContainerAbove			:Container;
		private var overlayContainerTop				:Container;
		
		private var _viewportWidth						:int;
		private var _viewportHeight						:int;
		
//		private var _controlBar							:CadetEditorControlBar;
				
		// View State
		private var overlays							:Array;
		private var _renderer							:IRenderer2D;
		private var _backgroundColor					:uint = 0x303030;
		private var _gridSize							:Number;
		private var _showGrid							:Boolean = false;
		private var _panX								:Number = 0;
		private var _panY								:Number = 0;
		private var _zoom								:Number = 1;
		
		public function CadetEditorView2D()
		{
			
		}
		
		public function dispose():void
		{
			while (overlays.length > 0)
			{
				removeOverlay(overlays[0]);
				overlays.splice(0,1);
			}
			
//			BindingUtil.unbindTwoWay(this, "zoom", _controlBar.zoomControl, "value");
//			BindingUtil.unbindTwoWay(this, "showGrid", _controlBar.gridToggle, "selected" );
//			BindingUtil.unbindTwoWay(this, "gridSize", _controlBar.gridSizeControl, "value" );
		}
		
		override protected function init():void
		{
			super.init();
			
			overlays = [];
			
			background = new flash.display.Sprite();
			addChild(background);
			
			overlayContainerBottom = new Container();
			overlayContainerBottom.percentWidth = overlayContainerBottom.percentHeight = 100;
			addChild(overlayContainerBottom)
			
			overlayContainerAbove = new Container();
			overlayContainerAbove.percentWidth = overlayContainerAbove.percentHeight = 100;
			addChild( overlayContainerAbove );
		
			overlayContainerTop = new Container();
			overlayContainerTop.percentWidth = overlayContainerTop.percentHeight = 100;
			addChild( overlayContainerTop );
			
//			_controlBar = new CadetEditorControlBar();
//			BindingUtil.bindTwoWay(this, "zoom", _controlBar.zoomControl, "value");
//			BindingUtil.bindTwoWay(this, "showGrid", _controlBar.gridToggle, "selected" );
//			BindingUtil.bindTwoWay(this, "gridSize", _controlBar.gridSizeControl, "value" );
//			_controlBar.snapToggle.addEventListener("rightClick", rightClickSnapToggleHandler);
//			
//			gridSize = 20;
//			showGrid = true;
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler( event:Event ):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			//IViewContainer(parent.parent).actionBar.addChild(_controlBar);
		}
		
//		private function rightClickSnapToggleHandler( event:MouseEvent ):void
//		{
//			BonesEditor.commandManager.executeCommand( CadetBuilderCommands.EDIT_SNAP_SETTINGS );
//		}
		
		public function set backgroundColor( value:uint ):void
		{
			_backgroundColor = value;
			invalidate();
		}
		public function get backgroundColor():uint { return _backgroundColor; }
						
		override protected function validate():void
		{
			super.validate();
			
			var layoutRect:Rectangle = getChildrenLayoutArea();
			_viewportWidth = layoutRect.width;
			_viewportHeight = layoutRect.height;
			
			if ( _renderer )
			{
				_renderer.viewportWidth = _viewportWidth;
				_renderer.viewportHeight = _viewportHeight;
				
				var m:Matrix = new Matrix();
				m.scale(_zoom,_zoom);
				m.translate(-panX*_zoom,-panY*_zoom);
				
				m.translate(_viewportWidth*0.5,_viewportHeight*0.5);		
				
				_renderer.setWorldContainerTransform( m );
				//Renderer2D(_renderer).worldContainer.transform.matrix = m;
				_renderer.validateNow();
			}
			
			background.graphics.clear();
			background.graphics.beginFill(_backgroundColor, 1);
			background.graphics.drawRect(0,0,layoutRect.width,layoutRect.height);
			
			for each ( var overlay:DisplayObject in overlays )
			{
				if ( overlay is UIComponent )
				{
					UIComponent(overlay).invalidate();
					UIComponent(overlay).validateNow();
				}
			}
		}

		public function set showGrid(value:Boolean):void
		{
			_showGrid = value;
			invalidate();
			dispatchEvent( new PropertyChangeEvent( "propertyChange_showGrid", null, _showGrid ) );
		}
		public function get showGrid():Boolean { return _showGrid; }
				
		public function set gridSize(value:Number):void
		{
			_gridSize = value;
			invalidate();
			dispatchEvent( new PropertyChangeEvent( "propertyChange_gridSize", null, _gridSize ) );
		}
		public function get gridSize():Number { return _gridSize; }
		
		public function set zoom(value:Number):void
		{
			_zoom = value;
			_zoom = _zoom < _zoomMin ? _zoomMin : _zoom > _zoomMax ? _zoomMax : _zoom;
//			_controlBar.zoomControl.value = _zoom;
//			_controlBar.zoomAmountLabel.text = String( int(_controlBar.zoomControl.value * 100 ) + "%" );
			invalidate();
			dispatchEvent( new PropertyChangeEvent( "propertyChange_zoom", null, _zoom ) );
			dispatchEvent( new CadetEditorViewEvent( CadetEditorViewEvent.VIEWPORT_CHANGED ) );
		}
		public function get zoom():Number { return _zoom; }
		
		public function set panX(value:Number):void
		{
			_panX = value;
			invalidate();
			dispatchEvent( new PropertyChangeEvent( "propertyChange_panX", null, _panX ) );
			dispatchEvent( new CadetEditorViewEvent( CadetEditorViewEvent.VIEWPORT_CHANGED ) );
		}
		public function get panX():Number { return _panX; }
		
		
		public function set panY(value:Number):void
		{
			_panY = value;
			invalidate();
			dispatchEvent( new PropertyChangeEvent( "propertyChange_panY", null, _panY ) );
			dispatchEvent( new CadetEditorViewEvent( CadetEditorViewEvent.VIEWPORT_CHANGED ) );
		}
		public function get panY():Number { return _panY; }
		
		public function addOverlay( overlay:DisplayObject, location:int = 0 ):void
		{
			var container:Container = location == TOP ? overlayContainerTop : overlayContainerBottom;
			if ( overlay is IUIComponent )
			{
				IUIComponent(overlay).percentWidth = IUIComponent(overlay).percentHeight = 100;
			}
			container.addChild(overlay);
			if ( overlay is ICadetEditorOverlay2D )
			{
				ICadetEditorOverlay2D(overlay).view = this;
			}
			
			overlays.push(overlay);
		}
		
		public function removeOverlay( overlay:DisplayObject ):void
		{
			if ( overlays.indexOf(overlay) == -1 ) return;
			
			if ( overlay is ICadetEditorOverlay2D )
			{
				ICadetEditorOverlay2D(overlay).view = null;
			}
			
			try
			{
				overlays.splice(overlays.indexOf(overlay),1);
				overlay.parent.parent.removeChild(overlay);
			}
			catch ( e:Error )
			{
				return;
			}
		}
		
		public function getOverlayOfType( type:Class ):DisplayObject
		{
			for each ( var overlay:DisplayObject in overlays )
			{
				if ( overlay is type )
				{
					return overlay;
				}
			}
			return null;
		}
		
		public function set renderer( value:IRenderer2D ):void
		{
			if ( _renderer )
			{
				_renderer.removeEventListener(InvalidationEvent.INVALIDATE, invalidateRendererHandler);
				//removeChild(_renderer.viewport);
				_renderer.disable(this);
				
				var existingGrid:Grid2D = Grid2D(getOverlayOfType(Grid2D));
				if ( existingGrid )
				{
					removeOverlay(existingGrid);
				}
			}
			_renderer = value;
			if ( _renderer )
			{
				_renderer.addEventListener(InvalidationEvent.INVALIDATE, invalidateRendererHandler);
				//addChildAt(_renderer.viewport,2);
				_renderer.enable(container, 2);
		
				if ( _renderer is IRenderer2D )
				{
					addOverlay( new Grid2D(), BOTTOM );
				}
			}
			
			// Enable/Disable Grid controls depending on the availibility of a Renderer2D
//			var gridEnabled:Boolean = _renderer is Renderer2D;
//			_controlBar.gridToggle.enabled = gridEnabled;
//			_controlBar.gridSizeControl.enabled = gridEnabled;
			
			invalidate();
			dispatchEvent( new CadetEditorViewEvent( CadetEditorViewEvent.RENDERER_CHANGED ) );
			dispatchEvent( new CadetEditorViewEvent( CadetEditorViewEvent.VIEWPORT_CHANGED ) );
		}
		public function get renderer():IRenderer2D { return _renderer; }
		
		//public function get controlBar():DisplayObjectContainer { return _controlBar; }
		
		
		private function invalidateRendererHandler( event:Event ):void
		{
			invalidate();
		}
		
		public function getContent():flash.display.Sprite
		{
			return content;
		}
		public function get viewportWidth():Number { return _viewportWidth; }
		public function get viewportHeight():Number { return _viewportHeight; }
		//public function get viewport():Sprite { return renderer.viewport; }
		public function get viewportMouse():Point 
		{ 
			if ( renderer )
			{
				return new Point(renderer.mouseX, renderer.mouseY); 
			}
			return new Point();
		}
		public function get worldMouse():Point 
		{ 
			if ( renderer )
			{
				return renderer.viewportToWorld( new Point(  renderer.mouseX, renderer.mouseY ) );
			}
			return new Point();
		}
		public function get container():DisplayObjectContainer { return content; }
	}
}