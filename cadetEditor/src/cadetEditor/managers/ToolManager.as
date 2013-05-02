// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.managers
{
	import cadetEditor.entities.ToolFactory;
	import cadetEditor.tools.ITool;
	import cadetEditor.ui.views.IToolEditorView;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import core.ui.components.Button;
	
	import core.editor.CoreEditor;
	import core.appEx.core.contexts.IContext;
	import core.app.util.IntrospectionUtil;

	public class ToolManager
	{
		private var context			:IContext;
		private var view			:IToolEditorView;
		private var _tools			:Array;
		private var _selectedTool	:ITool;
		
		private var keysDown		:Object;
		private var enabled			:Boolean = true;
		private var factoriesByTool	:Dictionary;
		
		private var previousTool	:ITool;
		
		public function ToolManager( context:IContext, view:IToolEditorView )
		{
			this.context = context;
			this.view = view;
			_tools = [];
			keysDown = {};
			factoriesByTool = new Dictionary();
			
			view.toolBar.addEventListener( Event.CHANGE, changeToolBarHandler );
		}
		
		public function enable():void
		{
			enabled = true;
			if ( _selectedTool )
			{
				_selectedTool.enable();
			}
			
			CoreEditor.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			CoreEditor.stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
		}
		
		public function disable():void
		{
			enabled = false;
			if ( _selectedTool )
			{
				_selectedTool.disable();
			}
			
			CoreEditor.stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			CoreEditor.stage.removeEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
		}
		
		public function dispose():void
		{
			disable();
			
			for each ( var tool:ITool in _tools )
			{
				tool.dispose();
			}
			_tools = null;
			context = null;
			view = null;
		}
		
		public function addTool( factory:ToolFactory ):ITool
		{
			var tool:ITool = ITool( factory.getInstance() );
			factoriesByTool[tool] = factory;
			
			view.addToolButton( factory.icon, factory.getLabel() );
			_tools.push( tool );
			tool.init( context );
			
			if ( _tools.length == 1 )
			{
				selectedTool = tool;
			}
			
			return tool;
		}
		
		public function get tools():Array { return _tools.slice(); }
		
		public function set selectedTool( value:ITool ):void
		{
			if ( value == _selectedTool ) return;
			
			// If the tool is only temporarily activated while the correct keys are pressed,
			// then we need to store the previous tool to return to.
			var previousFactory:ToolFactory = factoriesByTool[_selectedTool];
			var newFactory:ToolFactory = factoriesByTool[value];
			if ( previousFactory && previousFactory.keyToggle && newFactory && newFactory.keyToggle == false )
			{
				previousTool = _selectedTool;
			}
			
			var buttonIndex:int;
			if ( _selectedTool ) 
			{
				_selectedTool.disable();
				buttonIndex = _tools.indexOf(_selectedTool);
				if ( buttonIndex != -1 )
				{
					Button( view.toolBar.getChildAt(buttonIndex) ).selected = false
				}
			}
			
			_selectedTool = value;
			
			if ( _selectedTool )
			{
				if ( enabled )
				{
					_selectedTool.enable();
				}
				
				buttonIndex = _tools.indexOf(_selectedTool);
				if ( buttonIndex != -1 )
				{
					Button( view.toolBar.getChildAt(buttonIndex) ).selected = true
				}
			}
		}
		public function get selectedTool():ITool { return _selectedTool; }
		
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			if ( CoreEditor.contextManager.getCurrentContext() is IntrospectionUtil.getType(context) == false ) return;
			
			if ( keysDown[event.keyCode] ) return;
			keysDown[event.keyCode] = true;
			
			var tool:ITool = getToolForKeysPressed();
			if ( tool == null || tool == _selectedTool ) return;
			
			selectedTool = tool;
		}
		
		private function keyUpHandler( event:KeyboardEvent ):void
		{
			if ( !keysDown[event.keyCode] ) return;
			keysDown[event.keyCode] = false;
			trace("keyUp");
			
			var tool:ITool = getToolForKeysPressed();
			if ( tool == null && previousTool )
			{
				selectedTool = previousTool;
				previousTool = null;
			}
			else if ( tool != null )
			{
				selectedTool = tool;
			}
		}
		
		private function getToolForKeysPressed():ITool
		{
			var bestNumMatches:int = 0;
			var bestTool:ITool;
			for each ( var tool:ITool in _tools )
			{
				var factory:ToolFactory = factoriesByTool[tool];
				if ( factory.keyCodes == null || factory.keyCodes.length == 0 ) continue;
				
				var numMatches:int = 0;
				for ( var i:int = 0; i < factory.keyCodes.length; i++ )
				{
					var keyCode:int = factory.keyCodes[i];
					if ( keysDown[keyCode] )
					{
						numMatches++;
					}
				}
				if ( numMatches < factory.keyCodes.length ) continue;
				
				if ( numMatches > bestNumMatches )
				{
					bestNumMatches = numMatches;
					bestTool = tool;
				}
			}
			
			return bestTool;
		}
		
		private function changeToolBarHandler( event:Event ):void
		{
			selectedTool = _tools[view.toolBar.selectedIndex];
		}
	}
}