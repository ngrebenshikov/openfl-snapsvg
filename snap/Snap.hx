/*
 * Extern file for Snap(http://snapsvg.io/), a JS vector graphic library.
 * Source: https://github.com/prgsmall/snap.svg-haxe.git
 */

package snap;

import js.html.Node;
import js.html.Event;

// The Snap class maps to the Paper object defined in the snap api

@:native("Snap")
extern class Snap {
	public function new(?p0:Dynamic, ?p1:Dynamic);
	
	// Public static methods:
	static public function Matrix(a:Dynamic, ?b:Float, ?c:Float, ?d:Float, ?e:Float, ?f:Float):SnapMatrix;
	static public function ajax(url:String, postData:Dynamic, callbackFunction:Dynamic, scope:Dynamic):Dynamic;  // XmlHttpRequest
	static public function angle(x1:Float, y1:Float, x2:Float, y2:Float, ?x3:Float, ?y3:Float):Float;
	static public function animation(params:Dynamic, ms:Float, easing:String, ?callbackFunction:Dynamic):Dynamic;
	static public function color(clr:String):SnapColor;
	static public function deg(rad:Float):Float;
	static public function format(token:String, json:Dynamic):String;
	static public function is(obj:Dynamic, type:String):Bool;
	static public function load(url:String, callbackFunction:Dynamic, ?scope:Dynamic):Void;
	static public function parse(svg:String):SnapFragment;
	static public function parsePathString(pathString:String):Array<Dynamic>;
	static public function parseTransformString(tString:String):Array<Dynamic>;
	static public function rad(deg:Float):Float;
	
	static public function select(query:String):SnapElement;
	static public function selectAll(query:String):SnapSet;
	static public function snapTo(values:Array<Float>, value:Float, ?tolerance:Float):Float;
    static public function getElementByPoint(x: Float, y: Float): SnapElement;

	// path utility methods
	inline static public function path_bezierBBox(bez:Array<Float>):SnapBoundingBox {
		var bz = bez;
		return untyped __js__("Snap.path.bezierBBox(bz)");
	}
	inline static public function path_findDotsAtSegment(p1x:Float, p1y:Float, c1x:Float, c1y:Float, c2x:Float, c2y:Float, p2x:Float, p2y:Float, t:Float): SnapPointInformation {
		var a=p1x; var b=p1y; var c=c1x; var d=c1y; var e=c2x; var f=c2y; var g=p2x; var h=p2y; var i=t;
		return untyped __js__("Snap.path.findDotsAtSegment(a,b,c,d,e,f,g,h,i)");
	}
	inline static public function path_getBBox(path:String):Dynamic {
		var p=path;
		return untyped __js__("Snap.path.getBBox(p)");
	}
	inline static public function path_getPointAtLength(path:String, length:Float):Dynamic {
		var p=path; var l=length;
		return untyped __js__("Snap.path.getPointAtLength(p, l)");
	}
	inline static public function path_getSubpath(path:String, inFrom:Float, inTo:Float):String {
		var p=path; var f=inFrom; var t=inTo;
		return untyped __js__("Snap.path.getSubpath(p, f, t)");
	}
	inline static public function path_getTotalLength(path:String):Float {
		var p=path;
		return untyped __js__("Snap.path.getTotalLength(p)");
	}
	inline static public function path_intersection(path1:String, path2:String): Array<Dynamic> {
		var p1=path1; var p2=path2;
		return untyped __js__("Snap.path.intersection(p1, p2)");
	}
	inline static public function path_isPointInsidePath(path:String, x:Float, y:Float):Bool {
		var p=path; var x1=x; var y1=y;
		return untyped __js__("Snap.path.isPointInsidePath(p, x1, y1)");
	}
	inline static public function path_isPointInsideBBox(bbox:String, x:Float, y:Float):Bool {
		var b=bbox; var x1=x; var y1=y;
		return untyped __js__("Snap.path.isPointInsideBBox(b, x1, y1)");
	}
	inline static public function path_map(path:String, matrix:SnapMatrix):String {
		var p=path; var m=matrix;	
		return untyped __js__("Snap.path.map(p, m)");
	}
	inline static public function path_toAbsolute(path:String):Array<Dynamic>{
		var p=path;
		return untyped __js__("Snap.path.toAbsolute(p)");
	}
	inline static public function path_toCubic(path:String):Array<Dynamic> {
		var p=path;
		return untyped __js__("Snap.path.toCubic(p)");
	}
	inline static public function path_toRelative(path:String):Array<Dynamic> {
		var p=path;
		return untyped __js__("Snap.path.toRelative(p)");
	}

	// Filter utility methods
	inline static public function filter_blur(x:Float, ?y:Float): String {
		var x1 = x;var y1 = y;
		return untyped __js__("Snap.filter.blur(x1, y1)");
	}
	inline static public function filter_brightness(amount:Float):String {
		var a = amount;
		return untyped __js__("Snap.filter.brightness(a)");
	}
	inline static public function filter_contrast(amount:Float):String {
		var a = amount;
		return untyped __js__("Snap.filter.contrast(a)");
	}
	inline static public function filter_grayscale(amount:Float):String {
		var a = amount;
		return untyped __js__("Snap.filter.grayscale(a)");
	}
	inline static public function filter_hueRotate(angle:Float):String {
		var a = angle;
		return untyped __js__("Snap.filter.hueRotate(a)");
	}
	inline static public function filter_invert(amount:Float):String {
		var a = amount;
		return untyped __js__("Snap.filter.invert(a)");
	}
	inline static public function filter_saturate(amount:Float):String {
		var a = amount;
		return untyped __js__("Snap.filter.saturate(a)");
	}
	inline static public function filter_sepia(amount:Float):String {
		var a = amount;
		return untyped __js__("Snap.filter.sepia(a)");
	}
	inline static public function filter_shadow(dx:Float, dy:Float, ?blur:Float, ?color:String):String {
		var dx1 = dx;var dy1 = dy; var blur1=blur; var color1=color;
		return untyped __js__("Snap.filter.shadow(dx1, dy1, blur1, color1)");
	}

	// Element creation
	public function circle(x:Float, y:Float, r:Float):SnapElement;
	public function el(name:String, attr:Dynamic):SnapElement;
	public function ellipse(x:Float, y:Float, rx:Float, ry:Float):SnapElement;
	public function filter(filstr:String):SnapElement;
	public function fragment(varargs:Dynamic):SnapFragment;
	inline public function group(elements:Array<Dynamic> = null):SnapElement {
		var e123 = if (null != elements) elements else [];
		var me123 = this;
		return untyped __js__("me123.group.apply(me123, e123)");
	}
	public function gradient(gradientstr:String):SnapElement;
	public function image(src:String, x:Float, y:Float, width:Float, height:Float):SnapElement;
	public function line(x1:Float, y1:Float, x2:Float, y2:Float):SnapElement;
	public function path(?pathString:String):SnapElement;
	public function polygon(?varargs:Array<Dynamic>):SnapElement;
	public function polyline(?varargs:Array<Dynamic>):SnapElement;
	public function rect(x:Float, y:Float, width:Float, height:Float, ?rx:Float, ?ry:Float):SnapElement;
	public function text(x:Float, y:Float, text:Dynamic):SnapElement;

	public function toString():String;

	static public function getRGB(color:String):SnapRGB;
	static public function getColor(?val:Float):String;
	inline static public function getColorReset():Void {
		untyped __js__("Snap.getColor.reset()");
	}
	
	static public function hsb(hue:Float, saturation:Float, brightness:Float):String;
	static public function hsb2rgb(hue:Float, saturation:Float, brightness:Float):SnapRGB;

	static public function hsl(hue:Float, saturation:Float, lightness:Float):String;
	static public function hsl2rgb(hue:Float, saturation:Float, lightness:Float):SnapRGB;

	static public function rgb(red:Float, green:Float, blue:Float):String;
	static public function rgb2hsb(red:Float, green:Float, blue:Float):SnapHSB;
	static public function rgb2hsl(red:Float, green:Float, blue:Float):SnapHSL;
	
	/*
	 * Events
	 */
	
	public function click(handler:Event->Void):Snap;
	public function dblclick(handler:Event->Void):Snap;
	public function mousedown(handler:Event->Void):Snap;
	public function mousemove(handler:Event->Void):Snap;
	public function mouseout(handler:Event->Void):Snap;
	public function mouseover(handler:Event->Void):Snap;
	public function mouseup(handler:Event->Void):Snap;
	public function touchstart(handler:Event->Void):Snap;
	public function touchmove(handler:Event->Void):Snap;
	public function touchend(handler:Event->Void):Snap;
	public function touchcancel(handler:Event->Void):Snap;
	
	public function unclick(handler:Event->Void):Snap;
	public function undblclick(handler:Event->Void):Snap;
	public function unmousedown(handler:Event->Void):Snap;
	public function unmousemove(handler:Event->Void):Snap;
	public function unmouseout(handler:Event->Void):Snap;
	public function unmouseover(handler:Event->Void):Snap;
	public function unmouseup(handler:Event->Void):Snap;
	public function untouchstart(handler:Event->Void):Snap;
	public function untouchmove(handler:Event->Void):Snap;
	public function untouchend(handler:Event->Void):Snap;
	public function untouchcancel(handler:Event->Void):Snap;	
}

extern class SnapMatrix {
	public function add(a:Dynamic, ?b:Float, ?c:Float, ?d:Float, ?e:Float, ?f:Float):Void;
	public function clone():SnapMatrix;
	public function invert():SnapMatrix;
	public function rotate(a:Float, x:Float, y:Float):Void;
	public function scale(x:Float, ?y:Float, ?cx:Float, ?cy:Float):Void;
	public function split():Dynamic;
	public function toTransformString():String;
	public function translate(x:Float, y:Float):Void;
	public function x(x:Float, y:Float):Float;
	public function y(x:Float, y:Float):Float;
}

extern class SnapMina {
	public function new(a:Float, A:Float, b:Float, B:Float, get:Dynamic, set:Dynamic, easing:Dynamic);
	public function backin(n:Float):Float;
	public function backout(n:Float):Float;
	public function bounce(n:Float):Float;
	public function easein(n:Float):Float;
	public function easeinout(n:Float):Float;
	public function easeout(n:Float):Float;
	public function elastic(n:Float):Float;
	public function getById(id:String):SnapMina;
	public function linear(n:Float):Float;
	public function time():Float;
}

extern class SnapFragment {
	public function select():Void;
	public function selectAll():Void;
}

extern class SnapElement {
	public function new();
	public function add(el:SnapElement):SnapElement;
    public function addClass(c: String):SnapElement;
    public function hasClass(c: String):Bool;
    public function toggleClass(c:String, flag:Bool): SnapElement;
	public function after(el:SnapElement):SnapElement;
	public function animate(newAttrs:Dynamic, duration:Float, ?easing:String, ?callbackFunction:Dynamic):SnapElement;
	public function append(el:Dynamic):SnapElement;
	public function asPX(attr:String, ?value:String):String;
	public function attr(?p0:Dynamic, ?p1:Dynamic):Dynamic;
	public function before(el:SnapElement):SnapElement;
	public function click(handler:Event->Void):SnapElement;
	public function clone():SnapElement;
	public function data(key:String, ?value :Dynamic):Dynamic;
	public function drag(?onmove:Event->Void, ?onstart:Event->Void, ?onend:Event->Void,
		                 ?mcontext:Dynamic, ?scontext:Dynamic, ?econtext:Dynamic):Void;
	public function dblclick(handler:Event->Void):SnapElement;
	public function getBBox(?isWithoutTransform:Bool): Dynamic;
	public function getPointAtLength(length:Float): {x:Float, y:Float, alpha:Float};
	public function getSubpath(inFrom:Float, inTo:Float):String;
	public function getTotalLength():Float;
	public function hover(f_in:Event->Void, f_out:Event->Void, ?icontext:Dynamic, ?ocontext:Dynamic):SnapElement;
	public function inAnim():Dynamic;
	public function innerSVG():String;
	public function insertBefore(el:SnapElement):SnapElement;
	public function insertAfter(el:SnapElement):SnapElement;
	public function marker(x:Float, y:Float, width:Float, height:Float, refX:Float, refY:Float):Dynamic;
	public function mousedown(handler:Event->Void):SnapElement;
	public function mousemove(handler:Event->Void):SnapElement;
	public function mouseout(handler:Event->Void):SnapElement;
	public function mouseover(handler:Event->Void):SnapElement;
	public function mouseup(handler:Event->Void):SnapElement;
	public function parent():SnapElement;
	public function pattern(x:Float, y:Float, width:Float, height:Float):SnapElement;
	public function prepend(el:SnapElement):SnapElement;
	public function remove():SnapElement;
	public function removeData(?key:String):SnapElement;
	public function select(query:String):Dynamic;
	public function selectAll(query:String):SnapSet;
	public function stop():SnapElement;
	public function toDefs():SnapElement;
	public function toString():StringBuf;
	public function touchcancel(handler:Event->Void):SnapElement;
	public function touchend(handler:Event->Void):SnapElement;
	public function touchmove(handler:Event->Void):SnapElement;
	public function touchstart(handler:Event->Void):SnapElement;
	public function transform(tstr:String):Dynamic;
	public function unclick(handler:Event->Void):SnapElement;
	public function undblclick(handler:Event->Void):SnapElement;
	public function unhover(handler_in:Event->Void, handler_out:Event->Void):SnapElement;
	public function unmousedown(handler:Event->Void):SnapElement;
	public function unmousemove(handler:Event->Void):SnapElement;
	public function unmouseout(handler:Event->Void):SnapElement;
	public function unmouseover(handler:Event->Void):SnapElement;
	public function unmouseup(handler:Event->Void):SnapElement;
	public function untouchstart(handler:Event->Void):SnapElement;
	public function untouchmove(handler:Event->Void):SnapElement;
	public function untouchend(handler:Event->Void):SnapElement;
	public function untouchcancel(handler:Event->Void):SnapElement;
    public var node: Node;
    public var type: String;
}

extern class SnapSet {
	public function clear():Void;
	public function exclude(el:SnapElement):Bool;
	public function forEach(callback:SnapElement->Void, thisArg:Dynamic):SnapSet;
	public function pop() : Null<SnapElement>;
	public function push(x:SnapElement) : SnapSet;
	public function splice(index:Float, count:Float, insertion:Dynamic):Dynamic;
}

typedef SnapRGB = {
	r:Float, 
	g:Float, 
	b:Float, 
	hex:String,
	error:Bool
}

typedef SnapHSB = {
	h:Float, 
	s:Float, 
	b:Float,
	toString:Void->String
}

typedef SnapHSL = {
	h:Float, 
	s:Float, 
	l:Float,
	toString:Void->String
}

typedef SnapColor = {
	r:Float, 
	g:Float, 
	b:Float, 
	hex:String,
	error:Bool,
	h:Float, 
	s:Float,
	v:Float,
	l:Float
}

typedef SnapBoundingBox = {
	x:Float,
	y:Float,
	x2:Float,
	y2:Float,
	width:Float,
	height:Float
}

typedef SnapCoordinates = {
	x:Float,
	y:Float
}

typedef SnapPointInformation = {
	x:Float,
	y:Float,
	m: SnapCoordinates,
	n: SnapCoordinates,
	start:SnapCoordinates,
	end:SnapCoordinates,
	alpha:Float
}