package flash.display;

import flash.display.Graphics;
import flash.geom.Point;
import flash.Lib;


class Shape extends DisplayObject {

	public var graphics (get_graphics, never):Graphics;
	
	private var __graphics:Graphics;
	
	public function new () {
		super ();

        var graphicsSnap = Lib.snap.group().addClass("graphics");
        snap.append(graphicsSnap);
        __graphics = new Graphics(graphicsSnap);
	}
	
	override public function toString ():String {
		return "[Shape name=" + this.name + " id=" + ___id + "]";
	}
	
	
	public override function __getGraphics ():Graphics {
		return __graphics;
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
		return __graphics;
	}
}