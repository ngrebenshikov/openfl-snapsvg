package flash.display;


import flash.gl.GL;
import flash.geom.Matrix3D;
import flash.Lib;
//import native.gl.GLInstance;


class OpenGLView extends DirectRenderer {
	

	public static inline var CONTEXT_LOST = "glcontextlost";
	public static inline var CONTEXT_RESTORED = "glcontextrestored";
	
	public static var isSupported (get_isSupported, null):Bool;
	
	//var context:GLInstance;
	
	
	public function new () {
		
		super ("OpenGLView");
		
		GL.__context = __context;
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private static function get_isSupported ():Bool {
		
		if (untyped (!window.WebGLRenderingContext)) {
			
			return false;
			
		}
		
		var view = new OpenGLView ();
		
		if (view.__context == null) {
			
			return false;
			
		}
		
		return true;
		
	}
	
	
}