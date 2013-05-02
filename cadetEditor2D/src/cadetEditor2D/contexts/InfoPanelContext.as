// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor2D.contexts
{
	import core.appEx.core.contexts.IVisualContext;
	import core.appEx.events.ContextValidatorEvent;
	import core.appEx.validators.ContextValidator;
	
	import core.editor.CoreEditor;
	
	import cadetEditor2D.ui.views.InfoPanelView;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class InfoPanelContext implements IVisualContext
	{
		private var _view				:InfoPanelView;
		
		private var contextValidator	:ContextValidator;
		
		private var _context			:ICadetEditorContext2D;
		
		public function InfoPanelContext()
		{
			_view = new InfoPanelView();
			contextValidator = new ContextValidator(CoreEditor.contextManager, ICadetEditorContext2D);
			contextValidator.addEventListener(ContextValidatorEvent.CONTEXT_CHANGED, contextChangedHandler);
			context = contextValidator.getContext() as ICadetEditorContext2D;
		}
		
		public function dispose():void
		{
			contextValidator.removeEventListener(ContextValidatorEvent.CONTEXT_CHANGED, contextChangedHandler);
			contextValidator.dispose();
			contextValidator = null;
		}
		
		public function get view():DisplayObject { return _view; }
		
		private function contextChangedHandler( event:ContextValidatorEvent ):void
		{
			context = contextValidator.getContext() as ICadetEditorContext2D;
		}
		
		private function set context( value:ICadetEditorContext2D ):void
		{
			if ( _context )
			{
				_context.view.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			_context = value;
			if ( _context )
			{
				_context.view.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			updateView();
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			updateView();
		}
		
		private function updateView():void
		{
			if ( !_context )
			{
				_view.screenXLabel.text = "-";
				_view.screenYLabel.text = "-";
				_view.worldXLabel.text = "-";
				_view.worldYLabel.text = "-";
			}
			else
			{
				var snappedWorldMouse:Point = _context.snapManager.snapPoint( _context.view2D.worldMouse ).snapPoint;
				
				_view.screenXLabel.text = String( _context.view2D.viewportMouse.x );
				_view.screenYLabel.text = String( _context.view2D.viewportMouse.y );
				_view.worldXLabel.text = String( snappedWorldMouse.x );
				_view.worldYLabel.text = String( snappedWorldMouse.y );
			}
		}
	}
}