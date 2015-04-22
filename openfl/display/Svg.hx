package openfl.display;


import flash.display.DisplayObject;
import js.html.Element;
import openfl.display.DisplayObject;
import openfl.display.DisplayObject;
import snap.Snap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import js.html.CanvasElement;


class Svg extends Shape {

	public function new (svg: SnapElement):Void {
		super ();
        snap.append(svg);
	}

	override public function toString ():String {
		return "[Svg name=" + this.name + " id=" + ___id + "]";
	}

    override function validateBounds ():Void {

        if (_boundsInvalid) {
            super.validateBounds ();
            var rect = snap.getBBox();
            var r = new Rectangle (0, 0, rect.width, rect.height);

            if (r.width != 0 || r.height != 0) {
                if (__boundsRect.width == 0 && __boundsRect.height == 0) {
                    __boundsRect = r.clone ();
                } else {
                    __boundsRect.extendBounds (r);
                }
            }
            __setDimensions ();
        }
    }

    override private function __render (inMask:SnapElement = null, clipRect:Rectangle = null, force: Bool = false) {
        if (!__combinedVisible && !force) return;

        if (_matrixInvalid || _matrixChainInvalid) __validateMatrix();

        if (inMask != null) {
            //TODO: uncomment
            //			var m = getSurfaceTransform (gfx);
            //            Lib.__drawToSurface (gfx.__surface, inMask, m, fullAlpha, clipRect);
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
                    if (!mask.__isOnStage()) {
                        Lib.current.addChild(mask);
                    }
                    snap.attr({mask:mask.snap});
                }
            } else if (null == mask) {
                if (null != snapMask && "none" != snapMask) {
                    el.setAttribute('mask', 'none');
                }
            }
        }
    }
}