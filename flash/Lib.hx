package flash;


import flash.text.TextField.Span;
import snap.Snap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import haxe.Template;
import haxe.Timer;
import js.html.Attr;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.DivElement;
import js.html.Element;
import js.html.MetaElement;
import js.Browser;


class Lib {
	
	
	public static inline var HTML_ACCELEROMETER_EVENT_TYPE = 'devicemotion';
	public static inline var HTML_ORIENTATION_EVENT_TYPE = 'orientationchange';
	
	public static var current (get_current, null):MovieClip;
	
	private static inline var DEFAULT_HEIGHT = 500;
	private static inline var DEFAULT_WIDTH = 500;
	private static var HTML_DIV_EVENT_TYPES = [ 'resize', /*'mouseup',*/ 'mouseover', 'mouseout', /*'mousemove', 'mousedown',*/ 'mousewheel', 'dblclick', 'click' ];
	private static var HTML_TOUCH_EVENT_TYPES = [ 'touchstart', 'touchmove', 'touchend' ];
	private static var HTML_TOUCH_ALT_EVENT_TYPES = [ 'mousedown', 'mousemove', 'mouseup' ];
	private static var HTML_WINDOW_EVENT_TYPES = [ 'keyup', 'keypress', 'keydown', 'resize', 'blur', 'focus' ];
	private static inline var NME_IDENTIFIER = 'haxe:openfl';
    public static inline var SNAP_IDENTIFIER = 'haxe-openfl-svg';
	private static inline var VENDOR_HTML_TAG = "data-";
	
	private static var mCurrent:MovieClip;
	private static var mForce2DTransform:Bool;
	private static var mMainClassRoot:MovieClip;
	private static var mMe:Lib;
	private static var mStage:Stage;
	private static var starttime:Float = Timer.stamp ();
    private static var mSnap: Snap;
    private static var mStageSnap: SnapElement;
    private static var mFreeSnap: SnapElement;

	private var mArgs:Array<String>;
	private var mKilled:Bool;
	private var __scr:DivElement;

    public static var snap(get_snap, null): Snap;
    public static var stageSnap(get_stageSnap, null): SnapElement;
    public static var freeSnap(get_freeSnap, null): SnapElement;

	private function new (rootElement:DivElement, width:Int, height:Int) {
		
		mKilled = false;
		
		//var document:HTMLDocument = cast js.Lib.document;
		//__scr = cast document.getElementById(title);
		
		__scr = rootElement;
		if (__scr == null) throw "Root element not found";
		
		__scr.style.setProperty ("overflow", "hidden", "");
		//__scr.style.setProperty ("position", "absolute", ""); // necessary for chrome ctx.isPointInPath
		
		if (__scr.style.getPropertyValue ("width") != "100%") {
			
			__scr.style.width = width + "px";
			
		}
		
		if (__scr.style.getPropertyValue ("height") != "100%") {
			
			__scr.style.height = height + "px";
			
		}
	}
	
	
	// used by ExternalInterface to add a function by name to the containing HTMLElement
	public static function addCallback (functionName:String, closure:Dynamic):Void {
		
		untyped mMe.__scr[functionName] = closure;
		
	}
	
	
	public static function as<T> (v:Dynamic, c:Class<T>):Null<T> {
		
		return Std.is (v, c) ? v : null;
		
	}
	
	
	public static function attach (name:String):MovieClip
	{
		return new MovieClip ();
	}
	
	
	public static function getTimer ():Int {
		
		return Std.int ((Timer.stamp () - starttime) * 1000);
		
	}
	
	
	public static function getURL (request:URLRequest, target:String = null) {
		
		if (target == null) {
			
			target = "_blank";
			
		}
		
		//Browser.window.open(request.url);
		untyped { window.open (request.url, target); }
		
	}
	
	
	public static function preventDefaultTouchMove ():Void {
		
		Browser.document.addEventListener ("touchmove", function (evt:js.html.Event):Void {
			
			evt.preventDefault ();
			
		}, false);
		
	}
	
	
	private static function Run (tgt:DivElement, width:Int, height:Int):Lib {
		
		mMe = new Lib (tgt, width, height);

		for (i in 0...tgt.attributes.length) {

			var attr:Attr = cast tgt.attributes.item (i);

			if (StringTools.startsWith (attr.name, VENDOR_HTML_TAG)) {

				if (attr.name == VENDOR_HTML_TAG + "framerate") {

					__getStage ().frameRate = Std.parseFloat (attr.value);

				}

			}

		}

        for (type in HTML_TOUCH_EVENT_TYPES) {

            tgt.addEventListener(type, __getStage ().__queueStageEvent, true);

        }

        for (type in HTML_TOUCH_ALT_EVENT_TYPES) {

            tgt.addEventListener(type, __getStage ().__queueStageEvent, true);

        }

		for (type in HTML_DIV_EVENT_TYPES) {

			tgt.addEventListener(type, __getStage ().__queueStageEvent, true);

		}

		if (Reflect.hasField (Browser.window, "on" + HTML_ACCELEROMETER_EVENT_TYPE)) {

			Browser.window.addEventListener (HTML_ACCELEROMETER_EVENT_TYPE, __getStage ().__queueStageEvent, true);

		}

		if (Reflect.hasField (Browser.window, "on" + HTML_ORIENTATION_EVENT_TYPE)) {

			Browser.window.addEventListener (HTML_ORIENTATION_EVENT_TYPE, __getStage ().__queueStageEvent, true);

		}

		for (type in HTML_WINDOW_EVENT_TYPES) {

			Browser.window.addEventListener(type, __getStage ().__queueStageEvent, false);

		}

		#if interop
		// search document for data-bindings
		untyped {
			
			if (Browser.document.querySelectorAll != null) {
				
				var parser = new hscript.Parser ();
				
				for (type in HTML_DIV_EVENT_TYPES) {
					
					var allElements = Browser.document.querySelectorAll ("[data-openfl-binding-" + type.toLowerCase () + "]");
					
					if (allElements != null) {
						
						for (elIdx in 0...allElements.length) {
							
							var el = allElements[elIdx];
							var value = el.getAttribute ("data-openfl-binding-" + type);
							
							var program = try {
								
								parser.parseString (value);
								
							} catch (e: Dynamic) {
								
								Lib.trace ("'" + value + "' should be parseable by hscript: " + e);
								
							}
							
							if (program != null) {
								
								var interp = new hscript.Interp ();
								
								interp.variables.set ("stage", __getStage ());
								interp.variables.set ("Lib", Lib);
								interp.variables.set ("createDOMEvent", function (t, e) return new flash.events.DOMEvent (t, e));
								
								el.addEventListener (type, function (e) { 
									
									interp.variables.set ("event", e);
									interp.execute (program);
									
								});
								
							}
							
						}
						
					}
					
				}
				
			}
			
		}
		#end
		
//		if (tgt.style.backgroundColor != null && tgt.style.backgroundColor != "") {
//
//			__getStage ().backgroundColor = __parseColor (tgt.style.backgroundColor, function (res, pos, cur) {
//
//				return if (pos == 0)
//					res |(cur << 16);
//				else if (pos == 1)
//					res |(cur << 8);
//				else if (pos == 2)
//					res |(cur);
//				else
//					throw "pos should be 0-2";
//
//			});
//
//		} else {
//
//			__getStage ().backgroundColor = 0xFFFFFF;
//
//		}
		
		return mMe;
		
	}
	
	
	public static function setUserScalable (isScalable:Bool = true):Void {
		
		var meta:MetaElement = cast Browser.document.createElement ("meta");
		meta.name = "viewport";
		meta.content = "user-scalable=" + (isScalable ? "yes" : "no");
		
	}
	
	
	public static function trace (arg:Dynamic):Void {
		
		untyped { if (window.console != null) window.console.log (arg); }
		
	}
	
	
	public static function __appendSurface (surface:SnapElement, before:SnapElement = null, after:SnapElement = null, parent:SnapElement = null):Void {
		
		if (mMe.__scr != null) {
			if (before != null) {
				surface.insertBefore(before);
			} else if (after != null) {
				surface.insertAfter(after);
			} else if (parent != null) {
                parent.append(surface);
            } else {
                Lib.stageSnap.append(surface);
            }
		}
		
	}
	
	
	public static function __appendText (surface:Element, container:Element, text:String, wrap:Bool, isHtml:Bool):Void {
		
		for (i in 0...surface.childNodes.length) {
			
			surface.removeChild (surface.childNodes[i]);
			
		}
		
		if (isHtml) {
			
			container.innerHTML = text;
			
		} else {
			
			container.appendChild (cast Browser.document.createTextNode (text));
			
		}
		
		container.style.setProperty ("position", "relative", "");
		container.style.setProperty ("cursor", "default", "");
		if (!wrap) container.style.setProperty ("white-space", "nowrap", "");
		
		surface.appendChild (cast container);
		
	}
	
	
	public static function __bootstrap ():Void {
		
		if (mMe == null) {
			
			var target:DivElement = cast Browser.document.getElementById (NME_IDENTIFIER);

			if (target == null) {

				target = cast Browser.document.createElement ("div");
				//trace("Error: Cannot find element ID \"" + NME_IDENTIFIER + "\"");
				//untyped __js__("target.id; // throw error");

			}
//
//			var agent:String = untyped navigator.userAgent;
//
//			if (agent.indexOf ("BlackBerry") > -1 && target.style.height == "100%") {
//
//				target.style.height = untyped screen.height + "px";
//
//			}
//
//			if (agent.indexOf ("Android") > -1) {
//
//				var version = Std.parseFloat (agent.substr (agent.indexOf ("Android") + 8, 3));
//
//				if (version <= 2.3) {
//
//					mForce2DTransform = true;
//
//				}
//
//			}
			
			Run(target, __getWidth (), __getHeight ());
			
		}
		
	}
	
	
	public static function __copyStyle (src:Element, tgt:Element):Void {
		
		tgt.id = src.id;
		
		for (prop in ["left", "top", "transform", "transform-origin", "-moz-transform", "-moz-transform-origin", "-webkit-transform", "-webkit-transform-origin", "-o-transform", "-o-transform-origin", "opacity", "display"]) {
			
			tgt.style.setProperty (prop, src.style.getPropertyValue (prop), "");
			
		}
		
	}
	
	
	public static function __createSurfaceAnimationCSS<T> (surface:Element, data:Array<T>, template:Template, templateFunc:T -> Dynamic, fps:Float = 25, discrete:Bool = false, infinite:Bool = false):Dynamic {
		
		// TODO: getSanitizedOrGenerate ID
		
		if (surface.id == null || surface.id == "") {
			
			// generate id ?
			
			Lib.trace ("Failed to create a CSS Style tag for a surface without an id attribute");
			return null;
			
		}
		
		var style:Dynamic = null;
		
		if (surface.getAttribute ("data-openfl-anim") != null) {
			
			style = Browser.document.getElementById(surface.getAttribute ("data-openfl-anim"));
			
		} else {
			
			style = cast mMe.__scr.appendChild(Browser.document.createElement ("style"));
			style.sheet.id = "__openfl_anim_" + surface.id + "__";
			surface.setAttribute ("data-openfl-anim", style.sheet.id);
			
		}
		
		var keyframeStylesheetRule = "";
		
		for (i in 0...data.length) {
			
			var perc = i / (data.length - 1) * 100;
			var frame = data[i];
			keyframeStylesheetRule += perc + "% { " + template.execute (templateFunc(frame)) + " } ";
			
		}
		
		var animationDiscreteRule = if (discrete) "steps(::steps::, end)"; else "";
		var animationInfiniteRule = if (infinite) "infinite"; else "";
		var animationTpl = "";
		
		for (prefix in ["animation", "-moz-animation", "-webkit-animation", "-o-animation", "-ms-animation"]) {
			
			animationTpl += prefix + ": ::id:: ::duration::s " + animationDiscreteRule + " " + animationInfiniteRule  + "; ";
			
		}
		
		var animationStylesheetRule = new Template (animationTpl).execute( {
			
			id: surface.id,
			duration: data.length / fps,
			steps: 1
			
		});
		
		var rules = (style.sheet.rules != null) ? style.sheet.rules : style.sheet.cssRules;
		
		for (variant in ["", "-moz-", "-webkit-", "-o-", "-ms-"]) {
			
			// a try catch is necessary, because browsers throw exceptions on unknown vendor prefixes.
			
			try {
				
				style.sheet.insertRule ("@" + variant + "keyframes " + surface.id + " {" + keyframeStylesheetRule + "}", rules.length);
				
			} catch (e:Dynamic) { }
			
		}
		
		style.sheet.insertRule ("#" + surface.id + " { " + animationStylesheetRule + " } ", rules.length);
		
		return style;
		
	}
	
	
	public static function __designMode (mode:Bool):Void {
		
		Browser.document.designMode = mode ? 'on' : 'off';
		
	}
	
	
	public dynamic static function __disableFullScreen ():Void {
		
		
		
	}
	
	
	public static function __disableRightClick ():Void {
		
		if (mMe != null) {
			
			untyped {
				
				try {
					
					mMe.__scr.oncontextmenu = function () { return false; }
					
				} catch (e:Dynamic) {
					
					Lib.trace ("Disable right click not supported in this browser.");
					
				}
				
			}
			
		}
		
	}
	
	
	private static function __drawClippedImage (surface:CanvasElement, tgtCtx:CanvasRenderingContext2D, clipRect:Rectangle = null):Void {
		
		if (clipRect != null) {
			
			if (clipRect.x < 0) { clipRect.width += clipRect.x; clipRect.x = 0; }
			if (clipRect.y < 0) { clipRect.height += clipRect.y; clipRect.y = 0; }
			if (clipRect.width > surface.width - clipRect.x) clipRect.width = surface.width - clipRect.x;
			if (clipRect.height > surface.height - clipRect.y) clipRect.height = surface.height - clipRect.y;
			
			tgtCtx.drawImage (surface, clipRect.x, clipRect.y, clipRect.width, clipRect.height, clipRect.x, clipRect.y, clipRect.width, clipRect.height);
			
		} else {
			
			tgtCtx.drawImage (surface, 0, 0);
			
		}
		
	}
	
	
	public inline static function __drawSurfaceRect (surface:Element, tgt:CanvasElement, x:Float, y:Float, rect:Rectangle) {
		
		var tgtCtx = tgt.getContext ('2d');
		
		tgt.width = cast rect.width;
		tgt.height = cast rect.height;
		tgtCtx.drawImage (surface, rect.x, rect.y, rect.width, rect.height, 0, 0, rect.width, rect.height);
		tgt.style.left = (x) + "px";
		tgt.style.top = (y) + "px";
		
	}
	
	
	public static function __drawToSurface (surface:CanvasElement, tgt:CanvasElement, matrix:Matrix = null, alpha:Float = 1.0, clipRect:Rectangle = null, smoothing:Bool = true):Void {
		
		var srcCtx:CanvasRenderingContext2D = surface.getContext ("2d");
		var tgtCtx:CanvasRenderingContext2D = tgt.getContext ("2d");
		
		//if (alpha != 1.0) {
			
			tgtCtx.globalAlpha = alpha;
			
		//}
		
		__setImageSmoothing(tgtCtx, smoothing);
		
		if (surface.width > 0 && surface.height > 0) {
			
			if (matrix != null) {
				
				tgtCtx.save ();
				
				if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1) {
					
					tgtCtx.translate (matrix.tx, matrix.ty);
					
				} else { 
					
					tgtCtx.setTransform (matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
					
				}
				
				__drawClippedImage (surface, tgtCtx, clipRect);
				tgtCtx.restore ();
				
			} else {
				
				__drawClippedImage (surface, tgtCtx, clipRect);
				
			}
			
		}
		
	}
	
	
	public static function __enableFullScreen ():Void {
		
		if (mMe != null) {
			
			var origWidth = mMe.__scr.style.getPropertyValue ("width");
			var origHeight = mMe.__scr.style.getPropertyValue ("height");
			mMe.__scr.style.setProperty ("width", "100%", "");
			mMe.__scr.style.setProperty ("height", "100%", "");
			
			Lib.__disableFullScreen = function () {
				
				mMe.__scr.style.setProperty ("width", origWidth, "");
				mMe.__scr.style.setProperty ("height", origHeight, "");
				
			}
			
		}
		
	}
	
	
	public static function __enableRightClick ():Void {
		
		if (mMe != null) {
			
			untyped {
				
				try {
					
					mMe.__scr.oncontextmenu = null;
					
				} catch (e:Dynamic) {
					
					Lib.trace ("Enable right click not supported in this browser.");
					
				}
				
			}
			
		}
		
	}
	
	
	public inline static function __fullScreenHeight ():Int {
		
		return Browser.window.innerHeight;
		
	}
	
	
	public inline static function __fullScreenWidth ():Int {
		
		return Browser.window.innerWidth;
		
	}
	
	
	public static function __getHeight ():Int {
		
		var tgt:DivElement = if (Lib.mMe != null) Lib.mMe.__scr; else cast Browser.document.getElementById (NME_IDENTIFIER);
		return (tgt != null && tgt.clientHeight > 0) ? tgt.clientHeight:Lib.DEFAULT_HEIGHT;
		
	}
	
	
	public static function __getStage ():Stage {
		if (mStage == null) {
			var width = __getWidth ();
			var height = __getHeight ();
			mStage = new Stage (width, height);
		}
		return mStage;
	}
	
	
	public static function __getWidth ():Int {
		
		var tgt:DivElement = if (Lib.mMe != null) Lib.mMe.__scr; else cast Browser.document.getElementById (NME_IDENTIFIER);
		return (tgt != null && tgt.clientWidth > 0) ? tgt.clientWidth : Lib.DEFAULT_WIDTH;
		
	}
	
	
	public static inline function __isOnStage (p:SnapElement):Bool {
		while (p != null && p.node != stageSnap.node) {
			p = p.parent();
		}
		return p != null;
	}
	
	
	private static function __parseColor (str:String, cb:Int -> Int -> Int -> Int):Int {
		
		var re = ~/rgb\(([0-9]*), ?([0-9]*), ?([0-9]*)\)/;
		var hex = ~/#([0-9a-zA-Z][0-9a-zA-Z])([0-9a-zA-Z][0-9a-zA-Z])([0-9a-zA-Z][0-9a-zA-Z])/;
		
		if (re.match (str)) {
			
			var col = 0;
			
			for (pos in 1...4) {
				
				var v = Std.parseInt (re.matched (pos));
				col = cb (col, pos - 1, v);
				
			}
			
			return col;
			
		} else if (hex.match (str)) {
			
			var col = 0;
			
			for (pos in 1...4) {
				
				var v:Int = untyped ("0x" + hex.matched (pos)) & 0xFF;
				v = cb(col, pos - 1, v);
				
			}
			
			return col;
			
		} else {
			
			throw "Cannot parse color '" + str + "'.";
			
		}
		
	}
	
	
	public static function __removeSurface (surface:SnapElement):Dynamic {
        surface.remove();
		return surface;
		
	}
	
	
	public static function __setSurfaceBorder (surface:Element, color:Int, size:Int):Void {
		
		surface.style.setProperty ("border-color", '#' + StringTools.hex (color), "");
		surface.style.setProperty ("border-style", 'solid' , "");
		surface.style.setProperty ("border-width", size + 'px', "");
		surface.style.setProperty ("border-collapse", "collapse", "");
		
	}
	
	
	public static function __setSurfaceClipping (surface:Element, rect:Rectangle):Void {
		
		//rect(<top>, <right>, <bottom>, <left>)
		//trace("clip: " + "rect(" + rect.top + "px, " + rect.right + "px, " + rect.bottom + "px, " + rect.left + "px)");
		//surface.style.setProperty("clip", "rect(" + rect.top + "px, " + rect.right + "px, " + rect.bottom + "px, " + rect.left + "px)", "");
		
	}
	
	
	public static function __setSurfaceFont (surface:Element, font:String, bold:Int, size:Float, color:Int, align:String, lineHeight:Int):Void {
		
		surface.style.setProperty ("font-family", font, "");
		surface.style.setProperty ("font-weight", Std.string(bold), "");
		surface.style.setProperty ("color", '#' + StringTools.hex(color), "");
		surface.style.setProperty ("font-size", size + 'px', "");
		surface.style.setProperty ("text-align", align, "");
		surface.style.setProperty ("line-height", lineHeight + 'px', "");
		
	}
	
	
	public static function __setSurfaceOpacity (surface:SnapElement, alpha:Float):Void {
		surface.attr({ opacity: Std.string (alpha) });
	}
	
	
	public static function __setSurfacePadding (surface:Element, padding:Float, margin:Float, display:Bool):Void {
		
		surface.style.setProperty ("padding", padding + 'px', "");
		surface.style.setProperty ("margin", margin + 'px' , "");
		surface.style.setProperty ("top", (padding + 2) + "px", "");
		surface.style.setProperty ("right", (padding + 1) + "px", "");
		surface.style.setProperty ("left", (padding + 1) + "px", "");
		surface.style.setProperty ("bottom", (padding + 1) + "px", "");
		surface.style.setProperty ("display", (display ? "inline":"block") , "");
		
	}
	
	
	public static function __setSurfaceTransform (surface:SnapElement, matrix:Matrix):Void {
		if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1 && surface.attr ("data-openfl-anim") == null && matrix.tx == 0 && matrix.ty == 0) {
            surface.attr({ transform: null });
		} else {
            surface.attr({transform: matrix.toString()});
		}
	}
	
	
	public static function __setSurfaceZIndexAfter (surface1:Element, surface2:Element):Void {
		
		if (surface1 != null && surface2 != null) {
			
			if (surface1.parentNode != surface2.parentNode && surface2.parentNode != null) {
				
				surface2.parentNode.appendChild (surface1);
				
			}

			if (surface2.parentNode != null) {
				
				var nextSibling = surface2.nextSibling;
				
				if (surface1.previousSibling != surface2) {
					
					var swap = __removeSurface (cast surface1);
					
					if (nextSibling == null) {
						
						surface2.parentNode.appendChild (swap);
						
					} else {
						
						surface2.parentNode.insertBefore (swap, nextSibling); 
						
					}
					
				}
				
			}
		}
		
	}
	
	
	public static function __swapSurface (snap1:SnapElement, snap2:SnapElement):Void {
        var surface1 = snap1.node;
        var surface2 = snap2.node;

		var parent1 = surface1.parentNode;
		var parent2 = surface2.parentNode;

		if (parent1 != null && parent2 != null) {
			
			//they have one parent
			if (parent1 == parent2) {
				
				var next1 = surface1.nextSibling;
				var next2 = surface2.nextSibling;

				//if surface2 goes right after surface1
				if (next1 == surface2) {
					
					parent1.insertBefore (surface2, surface1);
					
				//if surface1 goes right after surface2
				} else if (next2 == surface1) {
					
					parent1.insertBefore (surface1, surface2);
					
				//another case
				} else {
					
					parent1.replaceChild (surface2, surface1);
					
					if (next2 != null) {
						
						parent1.insertBefore (surface1, next2);
						
					} else {
						
						parent1.appendChild (surface1);
						
					}
					
				}
				
			//they have different parents
			} else {
				
				var next2 = surface2.nextSibling;
				parent1.replaceChild (surface2, surface1);
				
				if (next2 != null) {
					
					parent2.insertBefore (surface1, next2);
					
				} else {
					
					parent2.appendChild (surface1);
					
				}
				
			}
			
		}
		
	}
	
	
	public static function __setContentEditable (surface:Element, contentEditable:Bool = true):Void {
		
		surface.setAttribute ("contentEditable", contentEditable ? "true" : "false");
		
	}
	
	
	public static function __setCursor (type:CursorType):Void {
		
		if (mMe != null) {
			
			mMe.__scr.style.cursor = switch (type) {
				
				case Pointer: "pointer";
				case Text: "text";
				default: "default";
				
			}
			
		}
		
	}
	
	
	public static function __setImageSmoothing (context:CanvasRenderingContext2D, enabled:Bool):Void {
		
		for (variant in ["imageSmoothingEnabled", "mozImageSmoothingEnabled", "webkitImageSmoothingEnabled"]) {
			
			Reflect.setField (context, variant, enabled);
			
		}
		
	}
	
	
	public static function __setSurfaceAlign (surface:Element, align:String):Void {
		
		surface.style.setProperty ("text-align", align, "");
		
	}
	
	
	public inline static function __setSurfaceId (surface:SnapElement, name:String):Void {
		var regex = ~/[^a-zA-Z0-9\-]/g;
		surface.attr({ id :regex.replace (name, "_") });
	}
	
	
	public inline static function __setSurfaceRotation (surface:Element, rotate:Float):Void {
		surface.style.setProperty ("transform", "rotate(" + rotate + "deg)", "");
		surface.style.setProperty ("-moz-transform", "rotate(" + rotate + "deg)", "");
		surface.style.setProperty ("-webkit-transform", "rotate(" + rotate + "deg)", "");
		surface.style.setProperty ("-o-transform", "rotate(" + rotate + "deg)", "");
		surface.style.setProperty ("-ms-transform", "rotate(" + rotate + "deg)", "");
	}
	
	
	public inline static function __setSurfaceScale (surface:Element, scale:Float):Void {
		
		surface.style.setProperty ("transform", "scale(" + scale + ")", "");
		surface.style.setProperty ("-moz-transform", "scale(" + scale + ")", "");
		surface.style.setProperty ("-webkit-transform", "scale(" + scale + ")", "");
		surface.style.setProperty ("-o-transform", "scale(" + scale + ")", "");
		surface.style.setProperty ("-ms-transform", "scale(" + scale + ")", "");
		
	}
	
	
	public static function __setSurfaceSpritesheetAnimation (surface:CanvasElement, spec:Array<Rectangle>, fps:Float):Element {
//TODO: uncomment
//		if (spec.length == 0) return surface;
//		var div:DivElement = cast Browser.document.createElement ("div");
//
//		// TODO: to be revisited...(see webkit-canvas and -moz-element)
//
//		//div.style.backgroundImage = "url(" + surface.toDataURL("image/png", {}) + ")";
//		div.style.backgroundImage = "url(" + surface.toDataURL("image/png") + ")";
//		div.id = surface.id;
//
//		var keyframeTpl = new Template ("background-position: ::left::px ::top::px; width: ::width::px; height: ::height::px; ");
//		var templateFunc = function (frame:Rectangle) {
//
//			return {
//
//				left: - frame.x,
//				top: - frame.y,
//				width: frame.width,
//				height: frame.height
//
//			}
//
//		}
//
//		__createSurfaceAnimationCSS (div, spec, keyframeTpl, templateFunc, fps, true, true);
//
//		if (__isOnStage (surface)) {
//
//			Lib.__appendSurface (div);
//			Lib.__copyStyle (surface, div);
//			Lib.__swapSurface (surface, div);
//			Lib.__removeSurface (surface);
//
//		} else {
//
//			Lib.__copyStyle (surface, div);
//
//		}
//
//		return div;
        return null;
	}
	
	
	public inline static function __setSurfaceVisible (snap:SnapElement, visible:Bool):Void {
        snap.attr({
            visibility: if (visible) "visible" else "hidden"
        });
	}
	
	
	public static function __setTextDimensions (surface:Element, width:Float, height:Float, align:String):Void {
		
		surface.style.setProperty ("width", width + "px", "");
		surface.style.setProperty ("height", height + "px", "");
		surface.style.setProperty ("overflow", "hidden", "");
		surface.style.setProperty ("text-align", align, "");
		
	}
	
	
	public static function __surfaceHitTest (surface:Element, x:Float, y:Float):Bool {
		
		for (i in 0...surface.childNodes.length) {
			
			var node:Element = cast surface.childNodes[i];
			
			if (x >= node.offsetLeft && x <= (node.offsetLeft + node.offsetWidth) && y >= node.offsetTop && y <= (node.offsetTop + node.offsetHeight)) {
				
				return true;
				
			}
			
		}
		
		return false;
		
	}
	
	
	
	
	// Getters & Setters
	

	private static function get_current ():MovieClip {
		if (mMainClassRoot == null) {
			mMainClassRoot = new MovieClip ();
			mCurrent = mMainClassRoot;
			__getStage ().addChild (mCurrent);

            // This ensures that a canvas hitTest hits the root movieclip

            mMainClassRoot.graphics.beginFill (__getStage ().backgroundColor, 0);
            mMainClassRoot.graphics.drawRect (0, 0, __getWidth(), __getHeight());
            __setSurfaceId (mMainClassRoot.snap, "Root MovieClip");
            __getStage ().__updateNextWake ();
		}
		return mMainClassRoot;
	}

    private static function get_snap ():Snap {
        if (mSnap == null) {
            mSnap = new Snap("#" + SNAP_IDENTIFIER);
        }
        return mSnap;
    }

    private static function get_stageSnap ():SnapElement {
        if (mStageSnap == null) {
            mStageSnap = snap.group();
            mStageSnap.attr({id : SNAP_IDENTIFIER + "-stage"});
        }
        return mStageSnap;
    }

    private static function get_freeSnap ():SnapElement {
        if (mFreeSnap == null) {
            mFreeSnap = snap.group();
            mFreeSnap.attr({id : SNAP_IDENTIFIER + "-free", visibility: "hidden"});
        }
        return mFreeSnap;
    }
}


private enum CursorType {
	
	Pointer;
	Text;
	Default;
	
}
