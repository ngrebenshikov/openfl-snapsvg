package flash.display;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;


class Loader extends Sprite {
	
	
	public var content (default, null):DisplayObject;
	public var contentLoaderInfo (default, null):LoaderInfo;
	
	private var mImage:BitmapData;
	private var mShape:Shape;
	
	
	public function new () {
		
		super ();
		
		contentLoaderInfo = LoaderInfo.create (this);
		
	}
	
	
	public function load (request:URLRequest, context:LoaderContext = null):Void {
		
		var extension = "";
		var parts = request.url.split (".");
		
		if (parts.length > 0) {
			
			extension = parts[parts.length - 1].toLowerCase ();
			
		}
		
		var transparent = true;
		
		untyped { contentLoaderInfo.url = request.url; }
		
		if (request.contentType == null && request.contentType != "") {
			
			untyped {
				
				contentLoaderInfo.contentType = switch (extension) {
					
					case "swf": "application/x-shockwave-flash";
					case "jpg", "jpeg": transparent = false; "image/jpeg";
					case "png": "image/png";
					case "gif": "image/gif";
					default: "application/x-www-form-urlencoded"; /*throw "Unrecognized file " + request.url;*/
					
				}
				
			}
			
		} else {
			
			untyped { contentLoaderInfo.contentType = request.contentType; }
			
		}
		
		mImage = new BitmapData (0, 0, transparent);
		
		try {
			
			contentLoaderInfo.addEventListener (Event.COMPLETE, handleLoad, false, 2147483647);
			contentLoaderInfo.addEventListener (IOErrorEvent.IO_ERROR, handleError, false, 2147483647);
			mImage.__loadFromFile (request.url, contentLoaderInfo);
			content = new Bitmap (mImage);
			Reflect.setField (contentLoaderInfo, "content", this.content);
			addChild (content);
			
		} catch (e:Dynamic) {
			
			trace ("Error " + e);
			var evt = new IOErrorEvent (IOErrorEvent.IO_ERROR);
			evt.currentTarget = this;
			contentLoaderInfo.dispatchEvent (evt);
			return;
			
		}
		
		if (mShape == null) {
			
			mShape = new Shape ();
			addChild (mShape);
			
		}
		
	}

    public function unload() 
    {
        if (numChildren > 0) 
        {
            while(numChildren > 0) 
            {
                removeChildAt(0);
            }

            untyped
            {
                content = null;
                contentLoaderInfo.url = null;
                contentLoaderInfo.contentType = null;
                contentLoaderInfo.content = null;
                contentLoaderInfo.bytesLoaded = contentLoaderInfo.bytesTotal = 0;
                contentLoaderInfo.width = 0;
                contentLoaderInfo.height = 0;   
            }
            var event = new Event(Event.UNLOAD);
            event.currentTarget = this;
            dispatchEvent(event);
        }
    }

	public function loadBytes (buffer:ByteArray):Void {
		
		try {
			
			contentLoaderInfo.addEventListener (Event.COMPLETE, handleLoad, false, 2147483647);
			
			BitmapData.loadFromBytes (buffer, null, function(bmd:BitmapData):Void {
				
				content = new Bitmap (bmd);
				Reflect.setField (contentLoaderInfo, "content", this.content);
				addChild (content);
				var evt = new Event (Event.COMPLETE);
				evt.currentTarget = this;
				contentLoaderInfo.dispatchEvent (evt);
				
			});
			
		} catch (e:Dynamic) {
			
			trace ("Error " + e);
			var evt = new IOErrorEvent (IOErrorEvent.IO_ERROR);
			evt.currentTarget = this;
			contentLoaderInfo.dispatchEvent (evt);
			
		}
		
	}
	
	
	override public function toString ():String {
		
		return "[Loader name=" + this.name + " id=" + ___id + "]";
		
	}
	
	
	override function validateBounds ():Void {
		
		if (_boundsInvalid) {
			
			super.validateBounds ();
			
			if (mImage != null) {
				
				var r = new Rectangle (0, 0, mImage.width, mImage.height);
				
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
	
	
	
	
	// Event Handlers
	
	
	
	
	private function handleLoad (e:Event):Void {
		
		e.currentTarget = this;
                if (content != null) {
			content.__invalidateBounds ();
			content.__render (null, null);
			contentLoaderInfo.removeEventListener (Event.COMPLETE, handleLoad);
                }		
	}

	private function handleError (e:Event):Void {
		
		e.currentTarget = this;
                if (content != null) {
			content.__invalidateBounds ();
			content.__render (null, null);
			contentLoaderInfo.removeEventListener (IOErrorEvent.IO_ERROR, handleError);
                }		
	}
	
	
}