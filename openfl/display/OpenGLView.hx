package openfl.display;


import openfl.geom.Matrix3D;
import openfl.Lib;
import openfl.gl.GL;
//import native.gl.GLInstance;


class OpenGLView extends DirectRenderer {
	

	public static inline var CONTEXT_LOST = "glcontextlost";
	public static inline var CONTEXT_RESTORED = "glcontextrestored";
	
	public static var isSupported (get_isSupported, null):Bool;
	
	//var context:GLInstance;
	
	
	public function new () {
		
		super("OpenGLView");
		
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