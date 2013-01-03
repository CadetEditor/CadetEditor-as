// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.geom.Rectangle;
	
	import flox.app.FloxApp;
	import flox.app.util.AsynchronousUtil;
	import flox.editor.operations.InitializeFloxOperationAIR;
	import flox.editor.ui.components.SplashScreen;
	
	[SWF(backgroundColor="#15181A", frameRate="60")]
	public class Cadet2D extends Sprite
	{
		private var splashWindow		:NativeWindow;
		private var splashScreen		:SplashScreen;
		private var configURL			:String = "config.xml";
		
		public function Cadet2D()
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
			
			var splashWindowInitOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			splashWindowInitOptions.systemChrome = "none";
			splashWindowInitOptions.transparent = true;
			splashWindow = new NativeWindow(splashWindowInitOptions);
			splashScreen = new SplashScreen();
			splashWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			splashWindow.stage.align = StageAlign.TOP_LEFT;
			splashWindow.stage.addChild( splashScreen );
			splashWindow.width = splashScreen.width;
			splashWindow.height = splashScreen.height;
			var bounds:Rectangle = Screen.mainScreen.bounds;
			splashWindow.x = ( bounds.width - splashWindow.width ) >> 1;
			splashWindow.y = ( bounds.height - splashWindow.height ) >> 1;
			splashWindow.activate();
			
			// Don't init straight away, so the invokeHandler has chance to be called.
			AsynchronousUtil.callLater(initFlox);
		}
		
		/**
		 * Handle any commandline parameters.
		 */
		private function invokeHandler( event:InvokeEvent ):void
		{
			if ( event.arguments.length == 0 ) return;
			configURL = event.arguments[0];
		}
		
		private function initFlox():void
		{
			FloxApp.init();
			
			var initOperation:InitializeFloxOperationAIR = new InitializeFloxOperationAIR( stage, configURL );
			initOperation.addEventListener(Event.COMPLETE, initCompleteHandler);
			initOperation.execute();
			
			splashScreen.setOperation(initOperation);
		}
		
		private function initCompleteHandler( event:Event ):void
		{
			splashWindow.close();
			stage.nativeWindow.visible = true;
			stage.nativeWindow.maximize();
		}
	}
}