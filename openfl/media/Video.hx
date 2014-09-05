package openfl.media;


import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.InteractiveObject;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.media.VideoElement;
import openfl.net.NetStream;
import openfl.Lib;
import js.html.CanvasElement;
import js.html.MediaElement;
import js.Browser;


class Video extends DisplayObject {
	
	
	public var deblocking:Int;
	public var smoothing:Bool;
	
	private var netStream:NetStream;
	private var renderHandler:Event->Void;
	private var videoElement(default, null):MediaElement;
	private var windowHack:Bool;
	
	private var __graphics:Graphics;
	
	
	public function new (width:Int = 320, height:Int = 240):Void {
		
		super ();
		
		/*
		 * todo: netstream/camera
		 * 			check compat with flash events
		 */
		
		__graphics = new Graphics ();
		__graphics.drawRect (0, 0, width, height);
		
		this.width = width;
		this.height = height;
		
		this.smoothing = false;
		this.deblocking = 0;
		
		//this.addEventListener(Event.ADDED_TO_STAGE, added);
		
	}
	
	
	/*private function added(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
	}*/
	
	
	/*public function attachCamera(camera:openfl.net.Camera):Void;
	{
		// (html5 <device/> 
		throw "not implemented";
	}*/
	
	
	public function attachNetStream (ns:NetStream):Void {
		
		this.netStream = ns;
		var scope:Video = this;
		
		__graphics.__mediaSurface (ns.__videoElement);
		
		ns.__videoElement.style.setProperty ("width", width + "px", "");
		ns.__videoElement.style.setProperty ("height", height + "px", "");
		ns.__videoElement.play ();
		
	}
	
	
	public function clear():Void {
		
		if (__graphics != null) {
			
			Lib.__removeSurface (__graphics.__surface);
			
		}
		
		__graphics = new Graphics ();
		__graphics.drawRect (0, 0, width, height);
		
	}
		
	
	override private function __getGraphics ():Graphics {
        return __graphics;
    }
	
	
	override public function __getObjectUnderPoint (point:Point):InteractiveObject {
		
		var local = globalToLocal (point);
		
		if (local.x >= 0 && local.y >= 0 && local.x <= width && local.y <= height) {
			
			// NOTE: bad cast, should be InteractiveObject... 
			return cast this;
			
		} else {
			
			return null;
			
		}
		
	}
	
	
	override public function __render (inMask:CanvasElement = null, clipRect:Rectangle = null):Void {
		
		if (_matrixInvalid || _matrixChainInvalid) {
			
			__validateMatrix ();
			
		}
		
		var gfx = __getGraphics ();
		if (gfx != null) {
			
			Lib.__setSurfaceTransform (gfx.__surface, getSurfaceTransform (gfx));
			
		}
		
	}
	
	
	override public function toString ():String {
		
		return "[Video name=" + this.name + " id=" + ___id + "]";
		
	}
	
   override function validateBounds ():Void {
        
        if (_boundsInvalid) {
            
            super.validateBounds ();
            
            if ((width == 0) && (height == 0)) {
                
                var r = new Rectangle (0, 0, 320, 240);      
                
                if (r.width != 0 || r.height != 0) {
                    
                    if (__boundsRect.width == 0 && __boundsRect.height == 0) {
                        
                        __boundsRect = r.clone ();
                        
                    } else {
                        
                        __boundsRect.extendBounds (r);
                        
                    }
                    
                }
                
            }
            
            __setDimensions ();
            
        }
        
    }
}