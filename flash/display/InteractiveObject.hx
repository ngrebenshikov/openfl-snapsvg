package flash.display;


import flash.geom.Point;


class InteractiveObject extends DisplayObject {
	
	
	public var doubleClickEnabled:Bool;
	public var focusRect:Dynamic;
	public var mouseEnabled:Bool;
	public var tabEnabled:Bool;
	public var tabIndex (get_tabIndex, set_tabIndex):Int;
	
	private var __doubleClickEnabled:Bool;
	private var __tabIndex:Int;
	
	
	public function new () {
		
		super ();
		
		tabEnabled = false;
		mouseEnabled = true;
		doubleClickEnabled = true;
		tabIndex = 0;
		
	}
	
	
	override public function toString ():String {
		
		return "[InteractiveObject name=" + this.name + " id=" + ___id + "]";
		
	}
	
	
	override private function __getObjectUnderPoint (point:Point):DisplayObject {
		
		if (!mouseEnabled) {
			
			return null;
			
		} else {
			
			return super.__getObjectUnderPoint (point);
			
		}
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	public function get_tabIndex ():Int { return __tabIndex; }
	public function set_tabIndex (inIndex:Int):Int { return __tabIndex = inIndex; }
	

}