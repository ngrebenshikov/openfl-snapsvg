package flash.display;


import js.html.Element;
import flash.display.DisplayObject;
import flash.display.DisplayObject;
import snap.Snap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.PixelSnapping;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import js.html.CanvasElement;


class Bitmap extends DisplayObject {
	
	
	public var bitmapData (default, set_bitmapData):BitmapData;
	public var pixelSnapping:PixelSnapping;
	public var smoothing:Bool;

	public var __graphics (default, null):Graphics;
	private var __currentLease:ImageDataLease;
	private var __init:Bool;
	
	
	public function new (inBitmapData:BitmapData = null, inPixelSnapping:PixelSnapping = null, inSmoothing:Bool = false):Void {
		
		super ();
		
		pixelSnapping = inPixelSnapping;
		smoothing = inSmoothing;
		
		if (inBitmapData != null) {
			this.bitmapData = inBitmapData;
			bitmapData.__referenceCount++;
		}
		
		if (pixelSnapping == null) {
			pixelSnapping = PixelSnapping.AUTO;
			
		}
		
		if (__graphics == null) {
            __graphics = new Graphics();
		}
		
		if (bitmapData != null) {
			__render();
		}
		
	}
	
	
	private inline function getBitmapSurfaceTransform (gfx:Graphics):Matrix {
		
		var extent = gfx.__extentWithFilters;
		var fm = __getFullMatrix ();
		fm.__translateTransformed (extent.topLeft);
		return fm;
		
	}
	
	
	override public function toString ():String {
		
		return "[Bitmap name=" + this.name + " id=" + ___id + "]";
		
	}
	
	
	override function validateBounds ():Void {
		
		if (_boundsInvalid) {
			
			super.validateBounds ();
			
			if (bitmapData != null) {
				
				var r = new Rectangle (0, 0, bitmapData.width, bitmapData.height);		
				
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
	
	
	override private function __getGraphics ():Graphics {
		
		return __graphics;
		
	}
	
	
	override public function __getObjectUnderPoint (point:Point):DisplayObject {
		
		if (!visible) {
			
			return null;
			
		} else if (this.bitmapData != null) {
			
			var local = globalToLocal (point);
			
			if (local.x < 0 || local.y < 0 || local.x > width / scaleX || local.y > height / scaleY) {
				
				return null;
				
			} else {
				
				return cast this;
				
			}
			
		} else {
			
			return super.__getObjectUnderPoint (point);
			
		}
		
	}
	
	
	override public function __render (inMask:SnapElement = null, clipRect:Rectangle = null):Void {
		
		if (!__combinedVisible) return;
		if (bitmapData == null) return;
		
		if (_matrixInvalid || _matrixChainInvalid) {
			
			__validateMatrix ();
			
		}
        var imageDataLease = bitmapData.__getLease ();

        if (imageDataLease != null && (__currentLease == null || imageDataLease.seed != __currentLease.seed || imageDataLease.time != __currentLease.time)) {
            var srcCanvas: CanvasElement = bitmapData.handle ();
            var child = snap.select('*');
            if (null != child) {
                child.remove();
            }
            snap.append(Lib.snap.image(
                        srcCanvas.toDataURL("image/png"),
                        0, 0,
                        srcCanvas.width,
                        srcCanvas.height
                    ));
            __currentLease = imageDataLease.clone();

            handleGraphicsUpdated (null);
        }
//TODO: uncomment
		if (inMask != null) {
//
//			__applyFilters (__graphics.__surface);
//			var m = getBitmapSurfaceTransform (__graphics);
//			Lib.__drawToSurface (__graphics.__surface, inMask, m, (parent != null ? parent.__combinedAlpha : 1) * alpha, clipRect, smoothing);
//
        } else {
            if (__testFlag (DisplayObject.TRANSFORM_INVALID)) {
                var m = getSurfaceTransform ();
                __setTransform (m);
                __clearFlag (DisplayObject.TRANSFORM_INVALID);
            }
            var el: Element = cast(snap.node);
            el.setAttribute('opacity', Std.string(alpha));

            var snapMask = el.getAttribute('mask');
            if (null != mask && (null == snapMask || "none" == snapMask) ) {
                if (null != mask.snap) {
                    snap.attr({mask:mask.snap});
                }
            } else if (null == mask) {
                if (null != snapMask && "none" != snapMask) {
                    snap.node.attributes.getNamedItem("mask").nodeValue="none";
                }
            }
        }
        updateClipRect();
    }

	// Getters & Setters

	
	private function set_bitmapData (inBitmapData:BitmapData):BitmapData {
		if (inBitmapData != bitmapData) {
			if (bitmapData != null) {
				bitmapData.__referenceCount--;
			}
			if (inBitmapData != null) {
				inBitmapData.__referenceCount++;
			}
		}
		
		__invalidateBounds ();
		bitmapData = inBitmapData;
		return inBitmapData;
	}
	
	
}