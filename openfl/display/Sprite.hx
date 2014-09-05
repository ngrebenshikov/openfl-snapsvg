package openfl.display;


import openfl.display.Graphics;
import openfl.display.InteractiveObject;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;


class Sprite extends DisplayObjectContainer {
	
	
	public var buttonMode:Bool;
	public var dropTarget (get_dropTarget, never):DisplayObject;
	public var graphics (get_graphics, never):Graphics;
	public var useHandCursor (default, set_useHandCursor):Bool;
	
	private var __cursorCallbackOut:Dynamic->Void;
	private var __cursorCallbackOver:Dynamic->Void;
	private var __dropTarget:DisplayObject;
	private var __graphics:Graphics;
	
	
	public function new () {
		
		super ();
		
        var graphicsSnap = Lib.snap.group().addClass("graphics");
        snap.append(graphicsSnap);
		__graphics = new Graphics(graphicsSnap);
		buttonMode = false;
		
	}
	
	
	public function startDrag (lockCenter:Bool = false, bounds:Rectangle = null):Void {
		
		if (__isOnStage ()) {
			
			stage.__startDrag (this, lockCenter, bounds);
			
		}
		
	}
	
	
	public function stopDrag ():Void {
		
		if (__isOnStage ()) {
			
			stage.__stopDrag (this);
			var l = parent.__children.length - 1;
			var obj:DisplayObject = stage;
			
			for (i in 0...parent.__children.length) {
				
				var result = parent.__children[l - i].__getObjectUnderPoint (new Point (stage.mouseX, stage.mouseY));
				if (result != null) obj = result;
				
			}
			
			if (obj != this) {
				
				__dropTarget = obj;
				
			} else {
				
				__dropTarget = stage;
				
			}
			
		}
		
	}
	
	
	override public function toString ():String {
		
		return "[Sprite name=" + this.name + " id=" + ___id + "]";
		
	}
	
	
	public override function __getGraphics ():Graphics {
		
		return __graphics;
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_dropTarget ():DisplayObject {
		
		return __dropTarget;
		
	}
	
	
	private function get_graphics ():Graphics {
		
		return __graphics;
		
	}
	
	
	private function set_useHandCursor (cursor:Bool):Bool {
		
		if (cursor == this.useHandCursor) return cursor;
		
		if (__cursorCallbackOver != null) {
			
			removeEventListener (MouseEvent.ROLL_OVER, __cursorCallbackOver);
			
		}
		
		if (__cursorCallbackOut != null) {
			
			removeEventListener (MouseEvent.ROLL_OUT, __cursorCallbackOut);
			
		}
		
		if (!cursor) {
			
			Lib.__setCursor (Default);
			
		} else {
			
			__cursorCallbackOver = function (_) { Lib.__setCursor (Pointer); }
			__cursorCallbackOut = function (_) { Lib.__setCursor (Default); }
			addEventListener (MouseEvent.ROLL_OVER, __cursorCallbackOver);
			addEventListener (MouseEvent.ROLL_OUT, __cursorCallbackOut);
			
		}
		
		this.useHandCursor = cursor;
		return cursor;
		
	}
	
	
}