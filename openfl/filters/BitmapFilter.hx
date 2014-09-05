package openfl.filters;

import snap.Snap;
import openfl.geom.Rectangle;
import js.html.CanvasElement;


class BitmapFilter {

	private var _mType:String;
	private var ___cached:Bool;

	public function new (inType:String) {
		_mType = inType;
	}
	
	public function clone ():BitmapFilter {
		return new BitmapFilter (_mType);
	}
	
	public function __preFilter (surface:CanvasElement) {}
	
	public function __applyFilter (surface:CanvasElement, rect:Rectangle = null, refreshCache:Bool = false) {}

    public function __getSvg(): String { return null; }

}