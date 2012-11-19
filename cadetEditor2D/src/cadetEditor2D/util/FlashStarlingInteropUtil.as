package cadetEditor2D.util
{
	import cadet.core.IRenderer;
	
	import cadet2D.components.skins.ISkin2D;
	import cadet2D.renderPipeline.flash.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D;
	import cadet2D.renderPipeline.starling.components.renderers.Renderer2D;
	import cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	public class FlashStarlingInteropUtil
	{
		// Returns 0 for Flash, 1 for Starling
		static public function isSkinFlashOrStarling( skin:ISkin2D ):uint
		{
			var abstractSkinFlash:cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D;
			var abstractSkinStarling:cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D;
			
			if ( skin is cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D ) {
				return 0;
			} else if ( skin is cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D ) {
				return 1;
			}
			
			return null;
		}
		// Returns 0 for Flash, 1 for Starling
		static public function isRendererFlashOrStarling( renderer:IRenderer ):uint
		{
			if ( renderer is cadet2D.renderPipeline.flash.components.renderers.Renderer2D ) {
				return 0;
			} else if ( renderer is cadet2D.renderPipeline.starling.components.renderers.Renderer2D ) {
				return 1;
			}
			
			return null;
		}
		
		static public function getSkinDisplayObjectStarling( skin:ISkin2D ):starling.display.DisplayObject
		{
			return cadet2D.renderPipeline.starling.components.skins.AbstractSkin2D(skin).displayObjectContainer;
		}
		
		static public function getSkinDisplayObjectFlash( skin:ISkin2D ):flash.display.DisplayObject
		{
			return cadet2D.renderPipeline.flash.components.skins.AbstractSkin2D(skin).displayObject;
		}
		
		static public function getRendererViewportFlash( renderer:IRenderer ):flash.display.Sprite
		{
			return cadet2D.renderPipeline.flash.components.renderers.Renderer2D(renderer).viewport;
		}
		
		static public function getRendererViewportStarling( renderer:IRenderer ):starling.display.Sprite
		{
			return cadet2D.renderPipeline.starling.components.renderers.Renderer2D(renderer).viewport;
		}
	}
}









