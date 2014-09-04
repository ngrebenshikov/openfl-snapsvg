package flash.display;


import snap.Snap;
import flash.errors.RangeError;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import js.html.CanvasElement;


class DisplayObjectContainer extends InteractiveObject {
	
	
	public var mouseChildren:Bool;
	public var numChildren (get_numChildren, never):Int;
	public var tabChildren:Bool;
	
	public var __children:Array<DisplayObject>;
	public var __combinedAlpha:Float;
	
	private var __addedChildren:Bool;
	
	
	public function new () {
		
		__children = new Array<DisplayObject> ();
		mouseChildren = true;
		tabChildren = true;
		
		super ();
		
		__combinedAlpha = alpha;
		
	}
	
	
	public function addChild (object:DisplayObject):DisplayObject {
		
		if (object == null) { throw "DisplayObjectContainer asked to add null child object"; }
		if (object == this) { throw "Adding to self"; }
		
		__addedChildren = true;
		
		if (object.parent == this) {
			setChildIndex (object, __children.length - 1);
			return object;
		}
		
		#if debug
		for (child in __children) {
			
			if (child == object) {
				
				throw "Internal error: child already existed at index " + getChildIndex (object);
				
			}
			
		}
		#end
		
		object.parent = this;
		if (__isOnStage ()) object.__addToStage (this);
		
		if (__children == null) {
			__children = new Array <DisplayObject> ();
		}
		
		__children.push (object);
		
		return object;
	}
	
	
	public function addChildAt (object:DisplayObject, index:Int):DisplayObject {
		
		if (index > __children.length || index < 0) {
			
			throw "Invalid index position " + index;
			
		}
		
		__addedChildren = true;
		
		if (object.parent == this) {
			
			setChildIndex (object, index);
			return object;
			
		}
		
		if (index == __children.length) {
			
			return addChild (object);
			
		} else {
			
			if (__isOnStage ()) object.__addToStage (this, __children[index]);
			__children.insert (index, object);
			object.parent = this;
			
		}
		
		return object;
		
	}
	
	
	public function contains (child:DisplayObject):Bool {
		
		return __contains (child);
		
	}
	
	
	public function getChildAt (index:Int):DisplayObject {
		
		if (index >= 0 && index < __children.length) {
			
			return __children[index];
			
		}
		
		throw "getChildAt : index out of bounds " + index + "/" + __children.length;
		return null;
		
	}
	
	
	public function getChildByName (inName:String):DisplayObject {
		
		for (child in __children) {
			
			if (child.name == inName) return child;
			
		}
		
		return null;
		
	}
	
	
	public function getChildIndex (inChild:DisplayObject):Int {
		
		for (i in 0...__children.length) {
			
			if (__children[i] == inChild) return i;
			
		}
		
		return -1;
		
	}
	
	
	public function getObjectsUnderPoint (point:Point):Array<DisplayObject> {
		
		var result = new Array<DisplayObject> ();
		__getObjectsUnderPoint (point, result);
		return result;
		
	}
	
	
	public function removeChild (inChild:DisplayObject):DisplayObject {
		
		for (child in __children) {
			
			if (child == inChild) {
				
				return __removeChild (child);
				
			}
			
		}
		
		throw "removeChild : none found?";
		
	}
	
	
	public function removeChildAt (index:Int):DisplayObject {
		
		if (index >= 0 && index < __children.length) {
			
			return __removeChild (__children[index]);
			
		}
		
		throw "removeChildAt(" + index + ") : none found?";
		
	}
	
	
	public function removeChildren (beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		
		if (endIndex == 0x7FFFFFFF) { 
			
			endIndex = __children.length - 1;
			
			if (endIndex < 0) {
				
				return;
				
			}
			
		}
		
		if (beginIndex > __children.length - 1) {
			
			return;
			
		} else if (endIndex < beginIndex || beginIndex < 0 || endIndex > __children.length) {
			
			throw new RangeError ("The supplied index is out of bounds.");
			
		}
		
		var numRemovals = endIndex - beginIndex;
		while (numRemovals >= 0) {
			
			removeChildAt (beginIndex);
			numRemovals--;
			
		}
		
	}
	
	
	public function setChildIndex (child:DisplayObject, index:Int) {
		
		if (index > __children.length) {
			
			throw "Invalid index position " + index;
			
		}
		
		var oldIndex = getChildIndex (child);
		
		if (oldIndex < 0) {
			
			var msg = "setChildIndex : object " + child.name + " not found.";
			
			if (child.parent == this) {
				
				var realindex = -1;
				
				for (i in 0...__children.length) {
					
					if (__children[i] == child) {
						
						realindex = i;
						break;
						
					}
					
				}
				
				if (realindex != -1) {
					
					msg += "Internal error: Real child index was " + Std.string (realindex);
					
				} else {
					
					msg += "Internal error: Child was not in __children array!";
					
				}
				
			}
			
			throw msg;
			
		}
		
		if (index < oldIndex) { // move down ...
			
			var i = oldIndex;
			
			while (i > index) {
				
				swapChildren (__children[i], __children[i - 1]);
				i--;
				
			}
			
		} else if (oldIndex < index) { // move up ...
			
			var i = oldIndex;
			
			while (i < index) {
				
				swapChildren (__children[i], __children[i + 1]);
				i++;
				
			}
			
		}
		
	}
	
	
	public function swapChildren (child1:DisplayObject, child2:DisplayObject):Void {
		
		var c1 = -1;
		var c2 = -1;
		var swap:DisplayObject;
		
		for (i in 0...__children.length) {
			
			if (__children[i] == child1) {
				
				c1 = i;
				
			} else if (__children[i] == child2) {
				
				c2 = i;
				
			}
			
		}
		
		if (c1 != -1 && c2 != -1) {
			swap = __children[c1];
			__children[c1] = __children[c2];
			__children[c2] = swap;
			swap = null;
			__swapSurface (c1, c2);
		}
		
	}
	
	
	public function swapChildrenAt (child1:Int, child2:Int):Void {
		
		var swap:DisplayObject = __children[child1];
		__children[child1] = __children[child2];
		__children[child2] = swap;
		swap = null;
		
	}
	
	
	override public function toString ():String {
		
		return "[DisplayObjectContainer name=" + this.name + " id=" + ___id + "]";
		
	}
	
	
	override function validateBounds ():Void {
		
		if (_boundsInvalid) {
			
			super.validateBounds ();
			
			for (obj in __children) {
				
				if (obj.visible) {
					
					var r = obj.getBounds (this);
					
					if (r.width != 0 || r.height != 0) {
						
						if (__boundsRect.width == 0 && __boundsRect.height == 0) {
							
							__boundsRect = r.clone ();
							
						} else {
							
							__boundsRect.extendBounds (r);
							
						}
						
					}
					
				}
				
			}
			
			__setDimensions ();
			
		}
		
	}
	
	
	override private function __addToStage (newParent:DisplayObjectContainer, beforeSibling:DisplayObject = null):Void {
		super.__addToStage (newParent, beforeSibling);
		for (child in __children) {
			if (null != child && (child.__getGraphics () == null || !child.__isOnStage ())) {
				child.__addToStage (this);
			}
		}
	}

	override public function __broadcast (event:Event):Void {
		for (child in __children) {
			child.__broadcast (event);
		}
		dispatchEvent (event);
	}
	
	
	@:noCompletion public override function __contains (child:DisplayObject):Bool {
		
		if (child == null) return false;
		if (this == child) return true;
		
		for (c in __children) {
			
			if (c == child || c.__contains (child)) return true;
			
		}
		
		return false;
		
	}
	
	
	override private function __getObjectUnderPoint (point:Point):DisplayObject {
		
		if (!visible) return null;
		
		var l = __children.length - 1;
		
		for (i in 0...__children.length) {
			
			var result = null;
			
			if (mouseEnabled) {
				
				result = __children[l - i].__getObjectUnderPoint (point);
				
			}
			
			if (result != null) {
				
				return mouseChildren ? result : this;
				
			}
			
		}
		
		return super.__getObjectUnderPoint (point);
		
	}
	
	
	private function __getObjectsUnderPoint (point:Point, stack:Array<DisplayObject>):Void {
		
		var l = __children.length - 1;
		
		for (i in 0...__children.length) {
			
			var result = __children[l - i].__getObjectUnderPoint (point);
			
			if (result != null) {
				
				stack.push (result);
				
			}
			
		}
		
	}
	
	
	override public function __invalidateMatrix (local:Bool = false):Void {
		
		//** FINAL **//	
		
		if (!_matrixChainInvalid && !_matrixInvalid) {	
			
			for (child in __children) {
				
				child.__invalidateMatrix ();
				
			}
			
		}
		
		super.__invalidateMatrix (local);
		
	}
	
	
	public inline function __removeChild (child:DisplayObject):DisplayObject {
		
		__children.remove (child);
		child.__removeFromStage ();
		child.parent = null;
		
		#if debug
		if (getChildIndex (child) >= 0) {
			
			throw "Not removed properly";
			
		}
		#end
		
		return child;
		
	}
	
	
	override private function __removeFromStage ():Void {
		
		super.__removeFromStage ();
		
		for (child in __children) {
			
			child.__removeFromStage ();
			
		}
		
	}
	
	
	override private function __render (inMask:SnapElement = null, clipRect:Rectangle = null):Void {
		
		if (!__visible) return;
		
		if (clipRect == null && __scrollRect != null) {
			
			clipRect = __scrollRect;
			
		}
		
		super.__render(inMask, clipRect);
		
		__combinedAlpha = (parent != null ? parent.__combinedAlpha * alpha : alpha);
		
		for (child in __children) {
			
			if (child.__visible) {
				
				if (clipRect != null) {
					
					if (child._matrixInvalid || child._matrixChainInvalid) {
						
						//child.invalidateGraphics ();
						child.__validateMatrix ();
						
					}
					
				}
				
				child.__render (inMask, clipRect);
				
			}
			
		}
		
		if (__addedChildren) {
			__addedChildren = false;
		}
	}
	
	
	private function __swapSurface (c1:Int, c2:Int):Void {
		if (__children[c1] == null) throw "Null element at index " + c1 + " length " + __children.length;
		if (__children[c2] == null) throw "Null element at index " + c2 + " length " + __children.length;

        var surface1 = __children[c1].snap;
        var surface2 = __children[c2].snap;

        if (surface1 != null && surface2 != null) {
            Lib.__swapSurface (surface1, surface2);
        }
	}
	
	
	// Getters & Setters
	
	override private function set_filters (filters:Array<Dynamic>):Array<Dynamic> {
		
		super.set_filters (filters);
		
		// TODO: check if we need to merge filters with children.
		for (child in __children) {
			
			child.filters = filters;
			
		}
		
		return filters;
		
	}
	
	
	override private function set___combinedVisible (inVal:Bool):Bool {
		
		if (inVal != __combinedVisible) {
			
			for (child in __children) {
				
				child.__combinedVisible = (child.visible && inVal);
				
			}
			
		}
		
		return super.set___combinedVisible (inVal);
		
	}
	
	
	private inline function get_numChildren ():Int {
		
		return __children.length;
		
	}
	
	
	override private function set_visible (inVal:Bool):Bool {
		
		__combinedVisible = parent != null ? parent.__combinedVisible && inVal : inVal;
		return super.set_visible (inVal);
		
	}
	

	override private function set_scrollRect (inValue:Rectangle):Rectangle {
		inValue = super.set_scrollRect (inValue);
		return inValue;
	}
	
		
}