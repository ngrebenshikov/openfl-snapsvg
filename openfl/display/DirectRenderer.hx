package openfl.display;


import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.Lib;
import js.html.CanvasElement;
import js.html.webgl.RenderingContext;
import openfl.gl.GL;


class DirectRenderer extends DisplayObject {
	
	
	public var render (get_render, set_render):Dynamic;
	
	private var __context:RenderingContext;
	private var __graphics:Graphics;
	private var __renderMethod:Dynamic;
	
	
	public function new (inType:String = "DirectRenderer") {
		
		super ();
		
		__graphics = new Graphics ();
		
		__graphics.__surface.width = Lib.current.stage.stageWidth;
		__graphics.__surface.height = Lib.current.stage.stageHeight;
		
		if (inType == "OpenGLView" && __graphics != null) {
			
			__context = __graphics.__surface.getContext ("webgl");
			
			if (__context == null) {
				
				__context = __graphics.__surface.getContext ("experimental-webgl");
				
			}
			
			#if debug
			__context = untyped WebGLDebugUtils.makeDebugContext (__context);
			#end
			
		}
		
	}
	
	
	public override function __getGraphics ():Graphics {
		
		return __graphics;
		
	}
	
	
	private override function __render (inMask:CanvasElement = null, clipRect:Rectangle = null) {
		
		if (!__combinedVisible) return;
		
		var gfx = __getGraphics ();
		if (gfx == null) return;
		
		gfx.__surface.width = stage.stageWidth;
		gfx.__surface.height = stage.stageHeight;
		
		if (__context != null) {
			
			GL.__context = __context;
			
			var rect = null;
			
			if (scrollRect == null) {
				
				rect = new Rectangle (0, 0, stage.stageWidth, stage.stageHeight);
				
			} else {
				
				rect = new Rectangle (x + scrollRect.x, y + scrollRect.y, scrollRect.width, scrollRect.height);
				
			}
			
			if (render != null) render (rect);
			
		}
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_render ():Dynamic {
		
		return __renderMethod;
		
	}
	
	
	private function set_render (value:Dynamic):Dynamic {
		
		__renderMethod = value;
		__render ();
		
		return value;
		
	}
	
	
}