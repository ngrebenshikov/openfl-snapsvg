package flash.display;

import flash.display.Graphics;
import flash.geom.Point;
import flash.Lib;


class Shape extends DisplayObject {

	public var graphics (get_graphics, never):Graphics;
	
	private var __graphics:Graphics;
	
	public function new () {
		super ();
        this.__graphics = new Graphics(snap);
	}
	
	override public function toString ():String {
		return "[Shape name=" + this.name + " id=" + ___id + "]";
	}
	
	
	private override function __getGraphics ():Graphics {
		return this.__graphics;
	}
	
	
	override public function __getObjectUnderPoint (point:Point):DisplayObject {
		if (parent == null) return null;
		if (parent.mouseEnabled && super.__getObjectUnderPoint (point) == this) {
			return parent;
		} else {
			return null;
		}
	}
	
	// Getters & Setters

	private function get_graphics ():Graphics {
		return this.__graphics;
	}
}