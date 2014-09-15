package openfl.display;


import snap.Snap;
import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.IGraphicsData;
import openfl.display.IGraphicsFill;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.SpreadMethod;
import openfl.filters.BitmapFilter;
import openfl.filters.DropShadowFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.Vector;
import js.html.CanvasElement;
import js.html.CanvasGradient;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import js.html.MediaElement;
import js.Browser;
import openfl.display.Tilesheet;


class Graphics {

/*
		Lines, fill styles and closing polygons.
		Flash allows the line stype to be changed within one filled polygon.
		A single NME "DrawObject" has a point list, an optional solid fill style
		and a list of lines.  Each of these lines has a line style and a
		list of "point indices", which are indices into the DrawObject's point array.
		The solid does not need a point-index list because it uses all the
		points in order.
		
		When building up a filled polygon, eveytime the line style changes, the
		current "line fragment" is stored in the "mLineJobs" list and a new line
		is started, without affecting the solid fill bit.
	*/

    public static inline var TILE_SCALE = 0x0001;
    public static inline var TILE_ROTATION = 0x0002;
    public static inline var TILE_RGB = 0x0004;
    public static inline var TILE_ALPHA = 0x0008;
    public static inline var TILE_TRANS_2x2 = 0x0010;
    public static inline var TILE_BLEND_NORMAL = 0x00000000;
    public static inline var TILE_BLEND_ADD = 0x00010000;

    private static inline var BMP_REPEAT = 0x0010;
    private static inline var BMP_SMOOTH = 0x10000;
    private static inline var CORNER_ROUND = 0x0000;
    private static inline var CORNER_MITER = 0x1000;
    private static inline var CORNER_BEVEL = 0x2000;
    private static inline var CURVE = 2;
    private static inline var END_NONE = 0x0000;
    private static inline var END_ROUND = 0x0100;
    private static inline var END_SQUARE = 0x0200;
    private static inline var LINE = 1;
    private static inline var MOVE = 0;
    private static inline var __MAX_DIM = 5000;
    private static inline var PIXEL_HINTING = 0x4000;
    private static inline var RADIAL = 0x0001;
    private static inline var SCALE_HORIZONTAL = 2;
    private static inline var SCALE_NONE = 0;
    private static inline var SCALE_NORMAL = 3;
    private static inline var SCALE_VERTICAL = 1;
    private static inline var SPREAD_REPEAT = 0x0002;
    private static inline var SPREAD_REFLECT = 0x0004;

    public var boundsDirty:Bool;

    public var __extent (default, null):Rectangle;
    public var __extentWithFilters (default, null):Rectangle;
    public var __snap (default, null): SnapElement;

    private var mBitmap (default, null):Texture;
    private var mCurrentLine:LineJob;
    private var mDrawList (default, null):DrawList;
    private var mFillColour:Int;
    private var mFillAlpha:Float;
    private var mFilling:Bool;
    private var mLastMoveID:Int;
    private var mLineDraws:DrawList;
    private var mLineJobs:LineJobs;
    private var mPenX:Float;
    private var mPenY:Float;
    private var mPoints:GfxPoints;
    private var mSolidGradient:Grad;
    private var nextDrawIndex:Int;

    private var __changed:Bool;
    private var __clearNextCycle:Bool;
    private var _padding:Float;


    public function new (snap: SnapElement = null) {

        Lib.__bootstrap (); // sanity check

        if (snap == null) {
            __snap = Lib.snap.group();
            Lib.freeSnap.append(__snap);
            __snap.addClass("graphics");
        } else {
            __snap = snap;
        }

        mLastMoveID = 0;
        mPenX = 0.0;
        mPenY = 0.0;

        mDrawList = new DrawList ();
        mPoints = [];

        mSolidGradient = null;
        mBitmap = null;
        mFilling = false;
        mFillColour = 0x000000;
        mFillAlpha = 0.0;
        mLastMoveID = 0;
        boundsDirty = true;

        __clearLine ();
        mLineJobs = [];
        __changed = true;
        nextDrawIndex = 0;

        __extent = new Rectangle ();
        __extentWithFilters = new Rectangle ();
        _padding = 0.0;
        __clearNextCycle = true;

    }


    private function addDrawable (inDrawable:Drawable):Void {

        if (inDrawable == null) {

            return; // throw ?

        }

        mDrawList.unshift (inDrawable);

    }


    private function addLineSegment ():Void {

        if (mCurrentLine.point_idx1 > 0) {

            mLineJobs.push (new LineJob (mCurrentLine.grad, mCurrentLine.point_idx0, mCurrentLine.point_idx1, mCurrentLine.thickness, mCurrentLine.alpha, mCurrentLine.colour, mCurrentLine.pixel_hinting, mCurrentLine.joints, mCurrentLine.caps, mCurrentLine.scale_mode, mCurrentLine.miter_limit));

        }

        mCurrentLine.point_idx0 = mCurrentLine.point_idx1 = -1;

    }


    public function beginBitmapFill (bitmap:BitmapData, matrix:Matrix = null, in_repeat:Bool = true, in_smooth:Bool = false):Void {

        closePolygon (true);
        var repeat:Bool = (in_repeat == null ? true : in_repeat);
        var smooth:Bool = (in_smooth == null ? false : in_smooth);

        mFilling = true;
        mSolidGradient = null;
        __expandStandardExtent (bitmap.width, bitmap.height);

        mBitmap = { texture_buffer: bitmap.handle (), matrix: matrix == null ? matrix : matrix.clone (), flags :(repeat ? BMP_REPEAT : 0) | (smooth ? BMP_SMOOTH : 0 ) };

    }


    public function beginFill (color:Int, alpha:Null<Float> = null):Void {

        closePolygon (true);
        mFillColour = color;
        mFillAlpha = (alpha == null ? 1.0 : alpha);
        mFilling = true;
        mSolidGradient = null;
        mBitmap = null;

    }


    public function beginGradientFill (type:GradientType, colors:Array<Dynamic>, alphas:Array<Dynamic>, ratios:Array<Dynamic>, matrix:Matrix = null, spreadMethod:Null<SpreadMethod> = null, interpolationMethod:Null<InterpolationMethod> = null, focalPointRatio:Null<Float> = null):Void {

        closePolygon (true);
        mFilling = true;
        mBitmap = null;

        mSolidGradient = createGradient (type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

    }


    public function blit (inTexture:BitmapData):Void {

//        closePolygon (true);
//        var ctx = getContext ();
//
//        if (ctx != null) {
//
//            ctx.drawImage (inTexture.handle (), mPenX, mPenY);
//
//        }

    }


    public function clear ():Void {

        __clearLine ();

        mPenX = 0.0;
        mPenY = 0.0;

        mDrawList = new DrawList ();
        nextDrawIndex = 0;
        mPoints = [];
        mSolidGradient = null;

//mBitmap = null;
        mFilling = false;
        mFillColour = 0x000000;
        mFillAlpha = 0.0;
        mLastMoveID = 0;

// clear the canvas
        __clearNextCycle = true;

        boundsDirty = true;
        __extent.x = 0.0;
        __extent.y = 0.0;
        __extent.width = 0.0;
        __extent.height = 0.0;
        _padding = 0.0;

        mLineJobs = [];

        __changed = true;
    }


    private function closePolygon (inCancelFill:Bool):Void {

        var l = mPoints.length;

        if (l > 0) {

            if (l > 1) {

                if (mFilling && l > 2) {

                    // Make implicit closing line
                    if (mPoints[mLastMoveID].x != mPoints[l - 1].x || mPoints[mLastMoveID].y != mPoints[l - 1].y) {
                        lineTo (mPoints[mLastMoveID].x, mPoints[mLastMoveID].y);
                    }

                }

                addLineSegment ();

                var drawable = new Drawable (mPoints, mFillColour, mFillAlpha, mSolidGradient, mBitmap, mLineJobs, null, SnapJob.getPathJob());
                addDrawable (drawable);

            }

            mLineJobs = [];
            mPoints = [];

        }

        if (inCancelFill) {

            mFillAlpha = 0;
            mSolidGradient = null;
            mBitmap = null;
            mFilling = false;

        }

        __changed = true;

    }


    private function createCanvasColor (color:Int, alpha:Float):String {

        var r = (0xFF0000 & color) >> 16;
        var g = (0x00FF00 & color) >> 8;
        var b = (0x0000FF & color);

        return 'rgba' + '(' + r + ',' + g + ',' + b + ',' + alpha + ')';

    }


    private function createCanvasGradient (g:Grad):SnapElement {

        var gradientString: StringBuf = new StringBuf();

        if ((g.flags & RADIAL) == 0) {
            gradientString.add("L(-819.2, 0, 819.2, 0)");
        } else {
            gradientString.add(Snap.format("R(0, 0, 819.2, {x}, 0)", {x:g.focal * 819.2}));
        }

        var points: Array<String> = [];
        for (point in g.points) {
            points.push(Snap.format("{color}:{pos}", {
                    color: createCanvasColor(point.col, point.alpha),
                    pos: Std.int(point.ratio / 255 * 100)
                }));
        }
        gradientString.add(points.join('-'));

        var gradient: SnapElement = Lib.snap.gradient(gradientString.toString());
        gradient.attr({
            gradientTransform: 'matrix(' + g.matrix.a + ',' + g.matrix.b + ',' + g.matrix.c + ',' + g.matrix.d + ',' + g.matrix.tx + ',' + g.matrix.ty + ')',
            spreadMethod: if (g.flags & SPREAD_REFLECT != 0) 'reflect'
                            else if (g.flags & SPREAD_REPEAT != 0) 'repeat'
                            else 'pad'
        });

        return gradient;
    }


    private function createGradient (type:GradientType, colors:Array<Dynamic>, alphas:Array<Dynamic>, ratios:Array<Dynamic>, matrix:Null<Matrix>, spreadMethod:Null<SpreadMethod>, interpolationMethod:Null<InterpolationMethod>, focalPointRatio:Null<Float>):Grad {

        var points = new GradPoints ();

        for (i in 0...colors.length) {

            points.push (new GradPoint (colors[i], alphas[i], ratios[i]));

        }

        var flags = 0;

        if (type == GradientType.RADIAL) {

            flags |= RADIAL;

        }

        if (spreadMethod == SpreadMethod.REPEAT) {

            flags |= SPREAD_REPEAT;

        } else if (spreadMethod == SpreadMethod.REFLECT) {

            flags |= SPREAD_REFLECT;

        }

        if (matrix == null) {

            matrix = new Matrix ();
            matrix.createGradientBox (25, 25);

        } else {

            matrix = matrix.clone ();

        }

        var focal:Float = (focalPointRatio == null ? 0 : focalPointRatio);
        return new Grad (points, matrix, flags, focal);

    }


    public function curveTo (inCX:Float, inCY:Float, inX:Float, inY:Float):Void {

        var pid = mPoints.length;

        if (pid == 0) {

            mPoints.push (new GfxPoint (mPenX, mPenY, 0.0, 0.0, MOVE));
            pid++;

        }

        mPenX = inX;
        mPenY = inY;
        __expandStandardExtent (inX, inY, mCurrentLine.thickness);
        mPoints.push (new GfxPoint(inX, inY, inCX, inCY, CURVE));

        if (mCurrentLine.grad != null || mCurrentLine.alpha > 0) {

            if (mCurrentLine.point_idx0 < 0) {

                mCurrentLine.point_idx0 = pid - 1;

            }

            mCurrentLine.point_idx1 = pid;

        }

    }


    public function drawCircle (x:Float, y:Float, rad:Float):Void {
        closePolygon (false);
        __drawCircle (x, y, rad);

    }


    public function drawEllipse (x:Float, y:Float, rx:Float, ry:Float):Void {

        closePolygon (false);
        rx /= 2;
        ry /= 2;
        __drawEllipse (x + rx, y + ry, rx, ry);

    }


    public function drawGraphicsData (points:Vector<IGraphicsData>):Void {

        for (data in points) {

            if (data == null) {

                mFilling = true;

            } else {

                switch (data.__graphicsDataType) {

                    case STROKE:

                        var stroke:GraphicsStroke = cast data;

                        if (stroke.fill == null) {

                            lineStyle (stroke.thickness, 0x000000, 1., stroke.pixelHinting, stroke.scaleMode, stroke.caps, stroke.joints, stroke.miterLimit);

                        } else {

                            switch (stroke.fill.__graphicsFillType) {

                                case SOLID_FILL:

                                    var fill:GraphicsSolidFill = cast stroke.fill;
                                    lineStyle (stroke.thickness, fill.color, fill.alpha, stroke.pixelHinting, stroke.scaleMode, stroke.caps, stroke.joints, stroke.miterLimit);

                                case GRADIENT_FILL:

                                    var fill:GraphicsGradientFill = cast stroke.fill;
                                    lineGradientStyle (fill.type, fill.colors, fill.alphas, fill.ratios, fill.matrix, fill.spreadMethod, fill.interpolationMethod, fill.focalPointRatio);

                            }

                        }

                    case PATH:

                        var path:GraphicsPath = cast data;
                        var j = 0;

                        for (i in 0...path.commands.length) {

                            var command = path.commands[i];

                            switch (command) {

                                case GraphicsPathCommand.MOVE_TO:

                                    moveTo (path.data[j], path.data[j + 1]);
                                    j = j + 2;

                                case GraphicsPathCommand.LINE_TO:

                                    lineTo (path.data[j], path.data[j + 1]);
                                    j = j + 2;

                                case GraphicsPathCommand.CURVE_TO:

                                    curveTo (path.data[j], path.data[j + 1], path.data[j + 2], path.data[j + 3]);
                                    j = j + 4;

                            }

                        }

                    case SOLID:

                        var fill:GraphicsSolidFill = cast data;
                        beginFill (fill.color, fill.alpha);

                    case GRADIENT:

                        var fill:GraphicsGradientFill = cast data;
                        beginGradientFill (fill.type, fill.colors, fill.alphas, fill.ratios, fill.matrix, fill.spreadMethod, fill.interpolationMethod, fill.focalPointRatio);

                }

            }

        }

    }


    public function drawRect (x:Float, y:Float, width:Float, height:Float):Void {
        closePolygon (false);
        __drawRect(x, y, width, height, 0, 0);
    }

    public function drawRoundRect (x:Float, y:Float, width:Float, height:Float, rx:Float, ry:Float = -1):Void {
        closePolygon (false);
        __drawRect(x, y, width, height, rx, ry == -1 ? rx : ry);
    }


    /** @private */
    public function drawTiles (sheet:Tilesheet, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0):Void {

        // Checking each tile for extents did not include rotation or scale, and could overflow the maximum canvas
        // size of some mobile browsers. Always use the full stage size for drawTiles instead?

        __expandStandardExtent (Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

        var useScale = (flags & TILE_SCALE) > 0;
        var useRotation = (flags & TILE_ROTATION) > 0;
        var useTransform = (flags & TILE_TRANS_2x2) > 0;
        var useRGB = (flags & TILE_RGB) > 0;
        var useAlpha = (flags & TILE_ALPHA) > 0;

        if (useTransform) { useScale = false; useRotation = false; }

        var index = 0;
        var numValues = 3;

        if (useScale) numValues ++;
        if (useRotation) numValues ++;
        if (useTransform) numValues += 4;
        if (useRGB) numValues += 3;
        if (useAlpha) numValues ++;

        while (index < tileData.length) {
            __expandStandardExtent(tileData[index] + sheet.__bitmap.width, tileData[index + 1] + sheet.__bitmap.height);
            index += numValues;
        }

        addDrawable (new Drawable (null, null, null, null, null, null, new TileJob (sheet, tileData, flags), null));
        __changed = true;
    }


    public function endFill ():Void {

        closePolygon (true);

    }


    public function flush ():Void {

        closePolygon (true);

    }


//    private inline function getContext ():CanvasRenderingContext2D {
//
//        try {
//
//            return __surface.getContext ("2d");
//
//        } catch (e:Dynamic) {
//
//            return null;
//
//        }
//
//    }


    public function lineGradientStyle (type:GradientType, colors:Array<Dynamic>, alphas:Array<Dynamic>, ratios:Array<Dynamic>, matrix:Matrix = null, spreadMethod:SpreadMethod = null, interpolationMethod:InterpolationMethod = null, focalPointRatio:Null<Float> = null):Void {

        mCurrentLine.grad = createGradient (type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

    }


    public function lineStyle (thickness:Null<Float> = null, color:Null<Int> = null, alpha:Null<Float> = null, pixelHinting:Null<Bool> = null, scaleMode:LineScaleMode = null, caps:CapsStyle = null, joints:JointStyle = null, miterLimit:Null<Float> = null):Void {

// Finish off old line before starting a new one
        addLineSegment ();

        if (thickness == null) {

//with no parameters it clears the current line(to draw nothing)
            __clearLine ();
            return;

        } else {

            mCurrentLine.grad = null;
            mCurrentLine.thickness = thickness;
            mCurrentLine.colour = (color == null ? 0 : color);
            mCurrentLine.alpha = (alpha == null ? 1.0 : alpha);
            mCurrentLine.miter_limit = (miterLimit == null ? 3.0 : miterLimit);
            mCurrentLine.pixel_hinting = (pixelHinting == null || !pixelHinting) ? 0 : PIXEL_HINTING;

        }

//mCurrentLine.caps = END_ROUND;

        if (caps != null) {

            switch (caps) {

                case ROUND: mCurrentLine.caps = END_ROUND;
                case SQUARE: mCurrentLine.caps = END_SQUARE;
                case NONE: mCurrentLine.caps = END_NONE;

            }

        }

        mCurrentLine.scale_mode = SCALE_NORMAL;

        if (scaleMode != null) {

            switch (scaleMode) {

                case NORMAL: mCurrentLine.scale_mode = SCALE_NORMAL;
                case VERTICAL: mCurrentLine.scale_mode = SCALE_VERTICAL;
                case HORIZONTAL: mCurrentLine.scale_mode = SCALE_HORIZONTAL;
                case NONE: mCurrentLine.scale_mode = SCALE_NONE;

            }

        }

        mCurrentLine.joints = CORNER_ROUND;

        if (joints != null) {

            switch (joints) {

                case ROUND: mCurrentLine.joints = CORNER_ROUND;
                case MITER: mCurrentLine.joints = CORNER_MITER;
                case BEVEL: mCurrentLine.joints = CORNER_BEVEL;

            }

        }

    }


    public function lineTo (inX:Float, inY:Float):Void {

        var pid = mPoints.length;

        if (pid == 0) {

            mPoints.push (new GfxPoint (mPenX, mPenY, 0.0, 0.0, MOVE));
            pid++;

        }

        mPenX = inX;
        mPenY = inY;
        __expandStandardExtent (inX, inY, mCurrentLine.thickness);
        mPoints.push (new GfxPoint (mPenX, mPenY, 0.0, 0.0, LINE));

        if (mCurrentLine.grad != null || mCurrentLine.alpha > 0) {

            if (mCurrentLine.point_idx0 < 0) {

                mCurrentLine.point_idx0 = pid - 1;

            }

            mCurrentLine.point_idx1 = pid;

        }

        if (!mFilling) closePolygon (false);

    }


    public function moveTo (inX:Float, inY:Float):Void {

        mPenX = inX;
        mPenY = inY;

        __expandStandardExtent (inX, inY);

        if (!mFilling) {

            closePolygon (false);

        } else {

            addLineSegment ();
            mLastMoveID = mPoints.length;
            mPoints.push (new GfxPoint (mPenX, mPenY, 0.0, 0.0, MOVE));

        }

    }


    private function __adjustSurface (sx:Float = 1.0, sy:Float = 1.0):Void {

//        if (Reflect.field (__surface, "getContext") != null) {
//
//            var width = Math.ceil ((__extentWithFilters.width - __extentWithFilters.x) * sx);
//            var height = Math.ceil ((__extentWithFilters.height - __extentWithFilters.y) * sy);
//
//// prevent allocating too large canvas sizes
//            if (width <= __MAX_DIM && height <= __MAX_DIM) {
//
//// re-allocate canvas, copy into larger canvas.
//                var dstCanvas:CanvasElement = cast Browser.document.createElement ("canvas");
//                dstCanvas.width = width;
//                dstCanvas.height = height;
//
//                Lib.__drawToSurface (__surface, dstCanvas);
//
//                if (Lib.__isOnStage (__surface)) {
//
//                    Lib.__appendSurface (dstCanvas);
//                    Lib.__copyStyle (__surface, dstCanvas);
//                    Lib.__swapSurface (__surface, dstCanvas);
//                    Lib.__removeSurface (__surface);
//
//                    if (__surface.id != null) Lib.__setSurfaceId (dstCanvas, __surface.id);
//
//                }
//
//                __surface = dstCanvas;
//
//            }
//
//        }

    }


    public inline function __clearCanvas ():Void {
        var node = __snap.node;
        while(null != node.firstChild) {
            node.removeChild(node.firstChild);
        }
    }


    public function __clearLine ():Void {

        mCurrentLine = new LineJob (null, -1, -1, 0.0, 0.0, 0x000, 1, CORNER_ROUND, END_ROUND, SCALE_NORMAL, 3.0);

    }


    public static function __detectIsPointInPathMode ():PointInPathMode {

        var canvas:CanvasElement = cast Browser.document.createElement ("canvas");
        var ctx = canvas.getContext ('2d');

        if (ctx.isPointInPath == null) {

            return USER_SPACE;

        }

        ctx.save ();
        ctx.translate (1, 0);
        ctx.beginPath ();
        ctx.rect (0, 0, 1, 1);

        var rv = if (ctx.isPointInPath (0.3, 0.3)) {

            USER_SPACE;

        } else {

            DEVICE_SPACE;

        }

        ctx.restore ();
        return rv;

    }

    private function __getCurrentLineJobs(): LineJobs {
        var result: LineJobs = mCurrentLine.thickness != 0
            ? [new LineJob (mCurrentLine.grad, mCurrentLine.point_idx0, mCurrentLine.point_idx1,
                mCurrentLine.thickness, mCurrentLine.alpha, mCurrentLine.colour, mCurrentLine.pixel_hinting,
                mCurrentLine.joints, mCurrentLine.caps, mCurrentLine.scale_mode, mCurrentLine.miter_limit)]
            : [];
        return result;
    }

    private function __drawEllipse (x:Float, y:Float, rx:Float, ry:Float):Void {
        __expandStandardExtent(x + rx, y + ry, mCurrentLine.thickness);
        var drawable: Drawable = new Drawable (null, mFillColour, mFillAlpha, mSolidGradient, mBitmap, __getCurrentLineJobs(),
            null, SnapJob.getEllipseJob(x, y, rx, ry));
        addDrawable(drawable);
    }

    private function __drawCircle (x:Float, y:Float, rad:Float):Void {
        __expandStandardExtent(x + rad, y + rad, mCurrentLine.thickness);
        var drawable: Drawable = new Drawable (null, mFillColour, mFillAlpha, mSolidGradient, mBitmap, __getCurrentLineJobs(),
            null, SnapJob.getCircleJob(x, y, rad));
        addDrawable(drawable);
    }

    private function __drawRect (x: Float, y: Float, width: Float, height: Float, rx: Float, ry: Float):Void {
        __expandStandardExtent(x + width, y + height, mCurrentLine.thickness);
        var drawable: Drawable = new Drawable (null, mFillColour, mFillAlpha, mSolidGradient, mBitmap, __getCurrentLineJobs(),
            null, SnapJob.getRectJob(x, y, width, height, rx, ry));
        addDrawable(drawable);
    }


    private function __drawTilesAsSingleImage (sheet:Tilesheet, tileData:Array<Float>, flags:Int = 0):Void {

        var useScale = (flags & TILE_SCALE) > 0;
        var useRotation = (flags & TILE_ROTATION) > 0;
        var useTransform = (flags & TILE_TRANS_2x2) > 0;
        var useRGB = (flags & TILE_RGB) > 0;
        var useAlpha = (flags & TILE_ALPHA) > 0;

        if (useTransform) { useScale = false; useRotation = false; }

        var scaleIndex = 0;
        var rotationIndex = 0;
        var rgbIndex = 0;
        var alphaIndex = 0;
        var transformIndex = 0;

        var numValues = 3;

        if (useScale) { scaleIndex = numValues; numValues ++; }
        if (useRotation) { rotationIndex = numValues; numValues ++; }
        if (useTransform) { transformIndex = numValues; numValues += 4; }
        if (useRGB) { rgbIndex = numValues; numValues += 3; }
        if (useAlpha) { alphaIndex = numValues; numValues ++; }

        var totalCount = tileData.length;
        var itemCount = Std.int(totalCount / numValues);
        var index = 0;

        var rect = null;
        var center = null;
        var previousTileID = -1;

        var surface = sheet.__bitmap.handle ();
        var canvas: CanvasElement = cast Browser.document.createElement ('canvas');
        canvas.width = Std.int(__extent.width);
        canvas.height = Std.int(__extent.height);
        var ctx:CanvasRenderingContext2D = canvas.getContext2d();

        while (index < totalCount) {

            var tileID = Std.int (tileData[index + 2]);

            if (tileID != previousTileID) {

                rect = sheet.__tileRects[tileID];
                center = sheet.__centerPoints[tileID];

                previousTileID = tileID;

            }

            if (rect != null && center != null) {

                ctx.save ();
                ctx.translate (tileData[index], tileData[index + 1]);

                if (useRotation) {

                    ctx.rotate (tileData[index + rotationIndex]);

                }

                var scale = 1.0;

                if (useScale) {

                    scale = tileData[index + scaleIndex];

                }

                if (useTransform) {

                    ctx.transform (tileData[index + transformIndex], tileData[index + transformIndex + 1], tileData[index + transformIndex + 2], tileData[index + transformIndex + 3], 0, 0);

                }

                if (useAlpha) {

                    ctx.globalAlpha = tileData[index + alphaIndex];

                }

                ctx.drawImage (surface, rect.x, rect.y, rect.width, rect.height, -center.x * scale, -center.y * scale, rect.width * scale, rect.height * scale);
                ctx.restore ();

            }

            index += numValues;

        }
        __clearCanvas();
        __snap.append(Lib.snap.image(canvas.toDataURL('image/png'), 0, 0, canvas.width, canvas.height));
    }

    private function __drawTiles (sheet:Tilesheet, tileData:Array<Float>, flags:Int = 0):Void {

        __clearCanvas();
        var useScale = (flags & TILE_SCALE) > 0;
        var useRotation = (flags & TILE_ROTATION) > 0;
        var useTransform = (flags & TILE_TRANS_2x2) > 0;
        var useRGB = (flags & TILE_RGB) > 0;
        var useAlpha = (flags & TILE_ALPHA) > 0;

        if (useTransform) { useScale = false; useRotation = false; }

        var scaleIndex = 0;
        var rotationIndex = 0;
        var rgbIndex = 0;
        var alphaIndex = 0;
        var transformIndex = 0;

        var numValues = 3;

        if (useScale) { scaleIndex = numValues; numValues ++; }
        if (useRotation) { rotationIndex = numValues; numValues ++; }
        if (useTransform) { transformIndex = numValues; numValues += 4; }
        if (useRGB) { rgbIndex = numValues; numValues += 3; }
        if (useAlpha) { alphaIndex = numValues; numValues ++; }

        var totalCount = tileData.length;
        var itemCount = Std.int(totalCount / numValues);
        var index = 0;

        var rect = null;
        var center = null;
        var previousTileID = -1;

        var canvas: CanvasElement = cast Browser.document.createElement ('canvas');
        var ctx:CanvasRenderingContext2D = canvas.getContext2d();
        var surface = sheet.__bitmap.handle ();
        var imageDataUrl: String = '';

        while (index < totalCount) {

            var tileID = Std.int (tileData[index + 2]);

            if (tileID != previousTileID) {
                rect = sheet.__tileRects[tileID];
                center = sheet.__centerPoints[tileID];
                previousTileID = tileID;
                canvas.width = Std.int(rect.width);
                canvas.height = Std.int(rect.height);
                ctx.drawImage (surface, rect.x, rect.y, rect.width, rect.height, 0, 0, rect.width, rect.height);
                imageDataUrl = canvas.toDataURL('image/png');
            }


            if (rect != null && center != null) {

                var image = Lib.snap.image(imageDataUrl, 0, 0, rect.width, rect.height);
                var el: Element = cast(image.node);

                var matrix = new Matrix();

                if (useRotation) {
                    matrix.rotate(tileData[index + rotationIndex]);
                }

                if (useScale) {
                    matrix.scale(tileData[index + scaleIndex], tileData[index + scaleIndex]);
                }

                if (useTransform) {
                    matrix = new Matrix(tileData[index + transformIndex], tileData[index + transformIndex + 1], tileData[index + transformIndex + 2], tileData[index + transformIndex + 3], 0, 0);
                }

                matrix.translate (tileData[index], tileData[index + 1]);

                if (useAlpha) {
                    el.setAttribute('opacity', Std.string(tileData[index + alphaIndex]));
                }

                el.setAttribute('transform', matrix.toString());

                __snap.append(image);
            }

            index += numValues;

        }
    }


    private function __expandFilteredExtent (x:Float, y:Float):Void {

        var maxX, minX, maxY, minY;

        minX = __extent.x;
        minY = __extent.y;
        maxX = __extent.width + minX;
        maxY = __extent.height + minY;

        maxX = x > maxX ? x : maxX;
        minX = x < minX ? x : minX;
        maxY = y > maxY ? y : maxY;
        minY = y < minY ? y : minY;

        __extentWithFilters.x = minX;
        __extentWithFilters.y = minY;
        __extentWithFilters.width = maxX - minX;
        __extentWithFilters.height = maxY - minY;

    }


    private function __expandStandardExtent (x:Float, y:Float, thickness:Float = 0):Void {

        if (_padding > 0) {

            __extent.width -= _padding;
            __extent.height -= _padding;

        }

        if (thickness != null && thickness > _padding) _padding = thickness;

        var maxX, minX, maxY, minY;

        minX = __extent.x;
        minY = __extent.y;
        maxX = __extent.width + minX;
        maxY = __extent.height + minY;

        maxX = x > maxX ? x : maxX;
        minX = x < minX ? x : minX;
        maxY = y > maxY ? y : maxY;
        minY = y < minY ? y : minY;

        __extent.x = minX;
        __extent.y = minY;
        __extent.width = maxX - minX + _padding;
        __extent.height = maxY - minY + _padding;

        __expandFilteredExtent(x,y);
        boundsDirty = true;
    }


    public inline function __invalidate ():Void {

        __changed = true;
        __clearNextCycle = true;

    }


    private function __addStrokeAttribute(element: SnapElement, lineJob: LineJob):Void {
        if(lineJob != null){
            element.attr({
                stroke: if (lineJob.grad == null) createCanvasColor(lineJob.colour, lineJob.alpha) else "none",
                'stroke-width': lineJob.thickness,
                'stroke-linecap': switch(lineJob.caps) {
                    case END_ROUND: "round";
                    case END_SQUARE: "square";
                    case END_NONE: "butt";
                    case _: "round";
                },
                'stroke-linejoin': switch (lineJob.joints) {
                    case CORNER_ROUND: "round";
                    case CORNER_MITER: "miter";
                    case CORNER_BEVEL: "bevel";
                    case _: "round";
                },
                'stroke-miterlimit': lineJob.miter_limit,
                'vector-effect': switch(lineJob.scale_mode) {
                    case SCALE_NONE: "non-scaling-stroke";
                    case SCALE_HORIZONTAL: "none";
                    case SCALE_VERTICAL: "none";
                    case SCALE_NORMAL: "none";
                    case _: "none";
                }
            });
        } else {
            element.attr({ stroke: "none" });
        }
    }

    private function __addFillAttribute(element: SnapElement, fillColour: Int, fillAlpha: Float, solidGradient: Grad, bitmap: Texture):Void {
        if (solidGradient != null) {
            element.attr({ fill: createCanvasGradient(solidGradient) });
        } else if (bitmap != null && ((bitmap.flags & BMP_REPEAT) > 0)) {

//TODO: uncomment
//                        var m = bitmap.matrix;
//
//                        if (m != null) {
//
//                            ctx.transform (m.a, m.b, m.c, m.d, m.tx, m.ty);
//
//                        }
//
//                        if (bitmap.flags & BMP_SMOOTH == 0) {
//
//                            untyped ctx.mozImageSmoothingEnabled = false;
//                            untyped ctx.webkitImageSmoothingEnabled = false;
//
//                        }

            element.attr({
                fill:  Lib.snap.image(bitmap.texture_buffer.toDataURL(), 0, 0, 1, 1)
                    .pattern(0, 0, "100%", "100%").attr({patternContentUnits: "objectBoundingBox", patternUnits : "objectBoundingBox"})
            });

        } else {
            // Alpha value gets clamped in [0;1] range.
            element.attr({ fill: createCanvasColor (fillColour, Math.min (1.0, Math.max (0.0, fillAlpha)))});
        }
        element.attr({'fill-rule': 'evenodd'});
    }

    public function __render (maskHandle:SnapElement = null, filters:Array<BitmapFilter> = null, sx:Float = 1.0, sy:Float = 1.0, clip0:Point = null, clip1:Point = null, clip2:Point = null, clip3:Point = null) {
        if (!__changed) return false;

        closePolygon (true);
        var padding = _padding;

        if (filters != null) {
            for (filter in filters) {
                if (Reflect.hasField (filter, "blurX")) {
                    padding += (Math.max (Reflect.field (filter, "blurX"), Reflect.field (filter, "blurY")) * 4);
                }
            }
        }

        __expandFilteredExtent ( - (padding * sx) / 2, - (padding * sy) / 2);

        if (__clearNextCycle) {

            nextDrawIndex = 0;
            __clearCanvas ();
            __clearNextCycle = false;

        }

        var len:Int = mDrawList.length;
//TODO: uncomment
//        ctx.save ();
//
//        if (__extentWithFilters.x != 0 || __extentWithFilters.y != 0) {
//
//            ctx.translate ( -__extentWithFilters.x * sx, -__extentWithFilters.y * sy);
//
//        }
//
//        if (sx != 1 || sy != 0) {
//
//            ctx.scale (sx, sy);
//
//        }
//
        for (i in nextDrawIndex...len) {

            var d = mDrawList[(len - 1) - i];
            //Fill data
            var fillColour = d.fillColour;
            var fillAlpha = d.fillAlpha;
            var g = d.solidGradient;
            var bitmap = d.bitmap;

            if (d.tileJob != null) {
                __drawTiles (d.tileJob.sheet, d.tileJob.drawList, d.tileJob.flags);
            } else {
                var snapElements:Array<SnapElement> = [];
                switch(d.snapJob.jobType) {
                    case SnapDrawable.NONE:
                        //throw new Exception();
                    case SnapDrawable.ELLIPSE(x, y, rx, ry):
                        var ellipse: SnapElement = Lib.snap.ellipse(x, y, rx, ry);

                        __addStrokeAttribute(ellipse, d.lineJobs.length == 1 ? d.lineJobs[0] : null);
                        __addFillAttribute(ellipse, fillColour, fillAlpha, g, bitmap);

                        __snap.append(ellipse);
                    case SnapDrawable.CIRCLE(x, y, rad):
                        var circle: SnapElement = Lib.snap.circle(x, y, rad);

                        __addStrokeAttribute(circle, d.lineJobs.length == 1 ? d.lineJobs[0] : null);
                        __addFillAttribute(circle, fillColour, fillAlpha, g, bitmap);

                        __snap.append(circle);
                    case SnapDrawable.RECT(x, y, width, height, rx, ry):
                        var rect: SnapElement = Lib.snap.rect(x, y, width, height, rx, ry);

                        __addStrokeAttribute(rect, d.lineJobs.length == 1 ? d.lineJobs[0] : null);
                        __addFillAttribute(rect, fillColour, fillAlpha, g, bitmap);

                        __snap.append(rect);
                    case SnapDrawable.PATH:
                        // Create pathes
                        var pathString: StringBuf = new StringBuf();
                        if (d.lineJobs.length > 0) {
                            // Create pathes with stroke
                            for (lj in d.lineJobs) {
                                for (i in lj.point_idx0...lj.point_idx1 + 1) {
                                    pathString.add(getSvgPathStringFor(d.points[i]));
                                }
                                closeSvgPathString(pathString);

                                //TODO: add gradient on line prev: ctx.strokeStyle = createCanvasGradient (ctx, lj.grad);
                                var path: SnapElement = Lib.snap.path(pathString.toString());
                                __addStrokeAttribute(path, lj);
                                snapElements.push(path);
                            }
                        } else {
                        //Create path without stroke
                            Lambda.iter(d.points, function(p) { pathString.add(getSvgPathStringFor(p));});
                            closeSvgPathString(pathString);
                            snapElements.push(
                                Lib.snap.path(pathString.toString()).attr({stroke: "none"})
                            );
                        }

                        // Fill pathes
                        Lambda.iter(snapElements, function(path) {
                            __addFillAttribute(path, fillColour, fillAlpha, g, bitmap);
                            __snap.append(path);
                        });

                }



                if (bitmap != null && ((bitmap.flags & BMP_REPEAT) == 0)) {
//TODO: uncomment
//
//                    ctx.clip ();
//                    var img = bitmap.texture_buffer;
//                    var m = bitmap.matrix;
//
//                    if (m != null) {
//
//                        ctx.transform (m.a, m.b, m.c, m.d, m.tx, m.ty);
//
//                    }
//
//                    //if (bitmap.flags & BMP_SMOOTH == 0) {
//                    //
//                    //untyped ctx.mozImageSmoothingEnabled = false;
//                    //untyped ctx.webkitImageSmoothingEnabled = false;
//                    //
//                    //}
//
//                    ctx.drawImage (img, 0, 0);

                    __snap.append(Lib.snap.image(bitmap.texture_buffer.toDataURL(), 0, 0, bitmap.texture_buffer.width, bitmap.texture_buffer.height));
                }

            }

        }

        __changed = false;
        nextDrawIndex = len > 0 ? len - 1 : 0;
        mDrawList = [];

        return true;

    }

    private inline function getSvgPathStringFor(p: GfxPoint): String {
        return switch (p.type) {

            case MOVE: Snap.format("M{x} {y} ", {x:p.x, y:p.y});
            case CURVE: Snap.format("Q{cx} {cy} {x} {y} ", {cx:p.cx, cy:p.cy, x:p.x, y:p.y});
            default: Snap.format("L{x} {y} ", {x:p.x, y:p.y});

        }
    }

    private inline function closeSvgPathString(pathString: StringBuf) {
        pathString.add("Z");
    }


}


class Drawable {


    public var bitmap:Texture;
    public var fillAlpha:Float;
    public var fillColour:Int;
    public var lineJobs:LineJobs;
    public var points:GfxPoints;
    public var solidGradient:Grad;
    public var tileJob:TileJob;
    public var snapJob: SnapJob;


    public function new (inPoints:GfxPoints, inFillColour:Int, inFillAlpha:Float, inSolidGradient:Grad, inBitmap:Texture, inLineJobs:LineJobs, inTileJob:TileJob,
                         inSnapJob: SnapJob) {

        points = inPoints;
        fillColour = inFillColour;
        fillAlpha = inFillAlpha;
        solidGradient = inSolidGradient;
        bitmap = inBitmap;
        lineJobs = inLineJobs;
        tileJob = inTileJob;
        snapJob = inSnapJob;

    }


}


typedef DrawList = Array<Drawable>;


class GfxPoint {


    public var cx:Float;
    public var cy:Float;
    public var type:Int;
    public var x:Float;
    public var y:Float;


    public function new (inX:Float, inY:Float, inCX:Float, inCY:Float, inType:Int) {

        x = inX;
        y = inY;
        cx = inCX;
        cy = inCY;
        type = inType;

    }


}


typedef GfxPoints = Array<GfxPoint>;


class Grad {


    public var flags:Int;
    public var focal:Float;
    public var matrix:Matrix;
    public var points:GradPoints;


    public function new (inPoints:GradPoints, inMatrix:Matrix, inFlags:Int, inFocal:Float) {

        points = inPoints;
        matrix = inMatrix;
        flags = inFlags;
        focal = inFocal;

    }


}


class GradPoint {


    public var alpha:Float;
    public var col:Int;
    public var ratio:Int;


    public function new (inCol:Int, inAlpha:Float, inRatio:Int) {

        col = inCol;
        alpha = inAlpha;
        ratio = inRatio;

    }


}


typedef GradPoints = Array<GradPoint>;


class LineJob {


    public var alpha:Float;
    public var caps:Int;
    public var colour:Int;
    public var grad:Grad;
    public var joints:Int;
    public var miter_limit:Float;
    public var pixel_hinting:Int;
    public var point_idx0:Int;
    public var point_idx1:Int;
    public var scale_mode:Int;
    public var thickness:Float;


    public function new (inGrad:Grad, inPoint_idx0:Int, inPoint_idx1:Int, inThickness:Float, inAlpha:Float, inColour:Int, inPixel_hinting:Int, inJoints:Int, inCaps:Int, inScale_mode:Int, inMiter_limit:Float) {

        grad = inGrad;
        point_idx0 = inPoint_idx0;
        point_idx1 = inPoint_idx1;
        thickness = inThickness;
        alpha = inAlpha;
        colour = inColour;
        pixel_hinting = inPixel_hinting;
        joints = inJoints;
        caps = inCaps;
        scale_mode = inScale_mode;
        miter_limit = inMiter_limit;

    }


}


typedef LineJobs = Array<LineJob>;


enum PointInPathMode {

    USER_SPACE;
    DEVICE_SPACE;

}


typedef Texture = {

    var texture_buffer:Dynamic;
    var matrix:Matrix;
    var flags:Int;

}


class TileJob {


    public var drawList:Array<Float>;
    public var flags:Int;
    public var sheet:Tilesheet;


    public function new (sheet:Tilesheet, drawList:Array<Float>, flags:Int) {

        this.sheet = sheet;
        this.drawList = drawList;
        this.flags = flags;

    }


}

enum SnapDrawable {
    NONE;
    PATH;
    ELLIPSE(x: Float, y: Float, rx: Float, ry:Float);
    CIRCLE(x: Float, y: Float, rad: Float);
    RECT(x: Float, y: Float, width: Float, height: Float, rx: Float, ry: Float);
}

class SnapJob {

    public var jobType: SnapDrawable;

    private function new() {
        jobType = SnapDrawable.NONE;
    }

    public static function getPathJob(): SnapJob {
        var result: SnapJob = new SnapJob();
        result.jobType = SnapDrawable.PATH;
        return result;
    }

    public static function getEllipseJob(x: Float, y: Float, rx: Float, ry: Float): SnapJob {
        var result: SnapJob = new SnapJob();
        result.jobType = SnapDrawable.ELLIPSE(x, y, rx, ry);
        return result;
    }

    public static function getCircleJob(x: Float, y: Float, rad: Float): SnapJob {
        var result: SnapJob = new SnapJob();
        result.jobType = SnapDrawable.CIRCLE(x, y, rad);
        return result;
    }

    public static function getRectJob(x: Float, y: Float, width: Float, height: Float, rx: Float, ry: Float): SnapJob {
        var result: SnapJob = new SnapJob();
        result.jobType = SnapDrawable.RECT(x, y, width, height, rx, ry);
        return result;
    }
}