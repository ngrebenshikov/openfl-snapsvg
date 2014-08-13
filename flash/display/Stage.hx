package flash.display;


import haxe.ds.StringMap;
import snap.Snap;
import flash.display.Graphics;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Acceleration;
import flash.ui.Keyboard;
import flash.Lib;
import flash.Vector;
import js.html.CanvasElement;
import js.html.DeviceMotionEvent;
import js.Browser;

#if stage3d
import flash.display.Stage3D;
#end


class Stage extends DisplayObjectContainer {
	
	
	public static inline var NAME:String = "Stage";
	public static var OrientationPortrait = 1;
	public static var OrientationPortraitUpsideDown = 2;
	public static var OrientationLandscapeRight = 3;
	public static var OrientationLandscapeLeft = 4;
	
	public static var __acceleration:Acceleration = { x: 0.0, y: 1.0, z: 0.0 };
	
	public var align:StageAlign;
	public var backgroundColor (get_backgroundColor, set_backgroundColor):Int; // Keeping for backward compatibility, for now
	public var color (get, set):Int;
	@:isVar public var displayState (get_displayState, set_displayState):StageDisplayState;
	public var focus (get_focus, set_focus):InteractiveObject;
	public var frameRate (get_frameRate, set_frameRate):Float;
	public var fullScreenHeight (get_fullScreenHeight, null):Int;
	public var fullScreenWidth (get_fullScreenWidth, null):Int;
	public var __pointInPathMode (default, null):PointInPathMode;
	@:isVar public var quality (get_quality, set_quality):String;
	public var scaleMode:StageScaleMode;
	public var showDefaultContextMenu (get_showDefaultContextMenu, set_showDefaultContextMenu):Bool;
	public var stageFocusRect:Bool;
	public var stageHeight (get_stageHeight, null):Int;
	public var stageWidth (get_stageWidth, null):Int;

	#if stage3d
	public var stage3Ds:Vector<Stage3D>;
	#end
	
	private static inline var DEFAULT_FRAMERATE = 0.0;
	private static inline var UI_EVENTS_QUEUE_MAX = 1000;
	
	private static var __mouseChanges:Array<String> = [ MouseEvent.MOUSE_OUT, MouseEvent.MOUSE_OVER, MouseEvent.ROLL_OUT, MouseEvent.ROLL_OVER ];
	private static var __touchChanges:Array<String> = [ TouchEvent.TOUCH_OUT, TouchEvent.TOUCH_OVER, TouchEvent.TOUCH_ROLL_OUT, TouchEvent.TOUCH_ROLL_OVER ];
	
	private var __backgroundColour:Int;
	private var __dragBounds:Rectangle;
	private var __dragObject:DisplayObject;
	private var __dragOffsetX:Float;
	private var __dragOffsetY:Float;
	private var __focusObject:InteractiveObject;
	private var __focusObjectActivated:Bool;
	private var __frameRate:Float;
	private var __interval:Int;
	private var __invalid:Bool;
	private var __mouseOverObjects:Array<InteractiveObject>;
	private var __showDefaultContextMenu:Bool;
	private var __stageActive:Bool;
	private var __stageMatrix:Matrix;
	private var __timer:Dynamic;
	private var __touchInfo:Array<TouchInfo>;
	private var __uIEventsQueue:Array<js.html.Event>;
	private var __uIEventsQueueIndex:Int;
	private var __windowWidth:Int;
	private var __windowHeight:Int;
	private var _mouseX:Float;
	private var _mouseY:Float;

    private var __graphics: Graphics;

    public var snapIdToDisplayObjects: StringMap<DisplayObject>;

	public function new (width:Int, height:Int) {
		
		super();
		
		__focusObject = null;
		__focusObjectActivated = false;
		__windowWidth = width;
		__windowHeight = height;
		stageFocusRect = false;
		scaleMode = StageScaleMode.SHOW_ALL;
		__stageMatrix = new Matrix ();
		tabEnabled = true;
		frameRate = DEFAULT_FRAMERATE;
		this.backgroundColor = 0xffffff;
		name = NAME;
		loaderInfo = LoaderInfo.create (null);
		loaderInfo.parameters.width = Std.string (__windowWidth);
		loaderInfo.parameters.height = Std.string (__windowHeight);
		
		__pointInPathMode = Graphics.__detectIsPointInPathMode ();
		__mouseOverObjects = [];
		showDefaultContextMenu = true;
		__touchInfo = [];
		__uIEventsQueue = untyped __new__("Array", UI_EVENTS_QUEUE_MAX);
		__uIEventsQueueIndex = 0;
        snapIdToDisplayObjects = new StringMap<DisplayObject>();

        #if stage3d
		stage3Ds = new Vector ();
		stage3Ds.push(new Stage3D ());
		//alpha = 0;   // so that the stage itself does not preclude to see Stage3D OpenGLView
		#end

        snap.remove();
        snap = Lib.stageSnap;
        var graphicsSnap = Lib.snap.group().addClass("graphics");
        snap.append(graphicsSnap);
        __graphics = new Graphics(graphicsSnap);
	}
	
	
	public static dynamic function getOrientation ():Int {
		
		var rotation:Int = untyped window.orientation;
		var orientation:Int = OrientationPortrait;
		
		switch (rotation) {
			
			case -90: orientation = OrientationLandscapeLeft;
			case 180: orientation = OrientationPortraitUpsideDown;
			case 90: orientation = OrientationLandscapeRight;
			default: orientation = OrientationPortrait;
			
		}
		
		return orientation;
		
	}
	
	
	public function invalidate ():Void {
		
		__invalid = true;
		
	}
	
	
	override public function toString ():String {
		
		return "[Stage id=" + ___id + "]";
		
	}
	
	
	private function __checkInOuts (event:Event, stack:Array<InteractiveObject>, touchInfo:TouchInfo = null) {
		
		var prev = (touchInfo == null ? __mouseOverObjects : touchInfo.touchOverObjects);
		var changeEvents = (touchInfo == null ? __mouseChanges : __touchChanges);
		
		var new_n = stack.length;
		var new_obj:InteractiveObject = (new_n > 0 ? stack[new_n - 1] : null);
		var old_n = prev.length;
		var old_obj:InteractiveObject = (old_n > 0 ? prev[old_n - 1] : null);
		
		if (new_obj != old_obj) {
			
			// mouseOut/MouseOver goes up the object tree...
			if (old_obj != null) {
				
				old_obj.__fireEvent (event.__createSimilar (changeEvents[0], new_obj, old_obj));
				
			}
			
			if (new_obj != null) {
				
				new_obj.__fireEvent (event.__createSimilar(changeEvents[1], old_obj, new_obj));
				
			}
			
			// rollOver/rollOut goes only over the non-common objects in the tree...
			var common = 0;
			while (common < new_n && common < old_n && stack[common] == prev[common]) {
				
				common++;
				
			}
			
			var rollOut = event.__createSimilar (changeEvents[2], new_obj, old_obj);
			var i = old_n - 1;
			
			while (i >= common) {
				
				prev[i].dispatchEvent (rollOut);
				i--;
				
			}
			
			var rollOver = event.__createSimilar (changeEvents[3], old_obj);
			var i = new_n - 1;
			
			while (i >= common) {
				
				stack[i].dispatchEvent (rollOver);
				i--;
				
			}
			
			if (touchInfo == null) {
				
				__mouseOverObjects = stack;
				
			} else {
				
				touchInfo.touchOverObjects = stack;
				
			}
			
		}
		
	}
	
	
	private function __drag (point:Point):Void {
		
		var p = __dragObject.parent;
		
		if (p != null) {
			
			point = p.globalToLocal (point);
			
		}
		
		var x = point.x + __dragOffsetX;
		var y = point.y + __dragOffsetY;
		
		if (__dragBounds != null) {
			
			if (x < __dragBounds.x) {
				
				x = __dragBounds.x;
				
			} else if (x > __dragBounds.right) {
				
				x = __dragBounds.right;
				
			}
			
			if (y < __dragBounds.y) {
				
				y = __dragBounds.y;
				
			} else if (y > __dragBounds.bottom) {
				
				y = __dragBounds.bottom;
				
			}
			
		}
		
		__dragObject.x = x;
		__dragObject.y = y;
		
	}
	
	
	override public function __isOnStage ():Bool {
		
		return true;
		
	}
	
	
	public function __processStageEvent (evt:js.html.Event):Void {
		
		evt.stopPropagation ();
		
		switch (evt.type) {
			
			case "resize":
				
				__onResize(Lib.__getWidth (), Lib.__getHeight ());
			
			case "focus":
				
				__onFocus (this);
				
				if (!__focusObjectActivated) {
					
					__focusObjectActivated = true;
					dispatchEvent (new Event (Event.ACTIVATE));
					
				}
			
			case "blur":
				
				if (__focusObjectActivated) {
					
					__focusObjectActivated = false;
					dispatchEvent (new Event (Event.DEACTIVATE));
					
				}
			
			case "mousemove":
				
				__onMouse (cast evt, MouseEvent.MOUSE_MOVE);
			
			case "mousedown":
				
				__onMouse (cast evt, MouseEvent.MOUSE_DOWN);
			
			case "mouseup":
				
				__onMouse (cast evt, MouseEvent.MOUSE_UP);
			
			case "click":
				
				__onMouse (cast evt, MouseEvent.CLICK);
			
			case "mousewheel":
				
				__onMouse (cast evt, MouseEvent.MOUSE_WHEEL);
			
			case "dblclick":
				
				__onMouse (cast evt, MouseEvent.DOUBLE_CLICK);
			
			case "keydown":
				
				var evt:js.html.KeyboardEvent = cast evt;
				var keyCode = (evt.keyCode != null ? evt.keyCode : evt.which);
				keyCode = Keyboard.__convertMozillaCode (keyCode);
				
				__onKey (keyCode, true, evt.charCode, evt.ctrlKey, evt.altKey, evt.shiftKey, evt.keyLocation);
			
			case "keyup":
				
				var evt:js.html.KeyboardEvent = cast evt;
				var keyCode = (evt.keyCode != null ? evt.keyCode : evt.which);
				keyCode = Keyboard.__convertMozillaCode (keyCode);
				
				__onKey (keyCode, false, evt.charCode, evt.ctrlKey, evt.altKey, evt.shiftKey, evt.keyLocation);
			
			case "touchstart":
				
				var evt:js.html.TouchEvent = cast evt;
				evt.preventDefault ();
				var touchInfo = new TouchInfo ();
				__touchInfo[evt.changedTouches[0].identifier] = touchInfo;
				__onTouch (evt, evt.changedTouches[0], TouchEvent.TOUCH_BEGIN, touchInfo, false);
			
			case "touchmove":
				
				var evt:js.html.TouchEvent = cast evt;
				evt.preventDefault ();
				var touchInfo = __touchInfo[evt.changedTouches[0].identifier];
				__onTouch (evt, evt.changedTouches[0], TouchEvent.TOUCH_MOVE, touchInfo, true);
			
			case "touchend":
				
				var evt:js.html.TouchEvent = cast evt;
				evt.preventDefault ();
				var touchInfo = __touchInfo[evt.changedTouches[0].identifier];
				__onTouch (evt, evt.changedTouches[0], TouchEvent.TOUCH_END, touchInfo, true);
				__touchInfo[evt.changedTouches[0].identifier] = null;
			
			case Lib.HTML_ACCELEROMETER_EVENT_TYPE:
				
				var evt:DeviceMotionEvent = cast evt;
				__handleAccelerometer (evt);
			
			case Lib.HTML_ORIENTATION_EVENT_TYPE:
				
				__handleOrientationChange ();
			
			default:
			
		}
		
	}
	
	
	public function __queueStageEvent (evt:js.html.Event):Void {
		
		__uIEventsQueue[__uIEventsQueueIndex++] = evt;
		
	}
	
	
	public function __renderAll () {
		
		__render (null, null);
		
	}
	
	
	public function __renderToCanvas (canvas:SnapElement):Void {
		__render (canvas);
		
	}
	
	
	private function __stageRender (?_) {
		
		if (!__stageActive) {

			__onResize (__windowWidth, __windowHeight);
			var event = new Event (Event.ACTIVATE);
			event.target = this;
			__broadcast (event);
			__stageActive = true;

		}

		// Dispatch all queued UI events before the main render loop.
		for (i in 0...__uIEventsQueueIndex) {

			if (__uIEventsQueue[i] != null) {

				__processStageEvent (__uIEventsQueue[i]);

			}

		}

		__uIEventsQueueIndex = 0;

		var event = new Event (Event.ENTER_FRAME);
		this.__broadcast (event);

		if (__invalid) {

			var event = new Event (Event.RENDER);
			this.__broadcast (event);

		}
		
		this.__renderAll ();
        var stageRenderedEvent = new Event(Event.STAGE_RENDERED);
        this.__broadcast(stageRenderedEvent);
	}
	
	
	public function __startDrag (sprite:Sprite, lockCenter:Bool = false, bounds:Rectangle = null) {
		
		__dragBounds = (bounds==null) ? null : bounds.clone ();
		__dragObject = sprite;
		
		if (__dragObject != null) {
			
			var mouse = new Point (_mouseX, _mouseY);
			var p = __dragObject.parent;
			
			if (p != null) {
				
				mouse = p.globalToLocal (mouse);
				
			}
			
			if (lockCenter) {
				
				var bounds = sprite.getBounds (this);
				__dragOffsetX = __dragObject.x - (bounds.width / 2 + bounds.x);
				__dragOffsetY = __dragObject.y - (bounds.height / 2 + bounds.y);
				
			} else {
				
				__dragOffsetX = __dragObject.x - mouse.x;
				__dragOffsetY = __dragObject.y - mouse.y;
				
			}
			
		}
		
	}
	
	
	public function __stopDrag (sprite:Sprite):Void {
		
		__dragBounds = null;
		__dragObject = null;
		
	}
	
	
	public function __updateNextWake ():Void {

	    if (__frameRate == 0) {

			var __requestAnimationFrame:Dynamic = untyped __js__("window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame");
			__requestAnimationFrame (__updateNextWake);
			__stageRender ();

		} else {

			Browser.window.clearInterval (__timer);
			//__timer = Browser.window.setInterval(cast __stageRender, __interval, []);
			__timer = Browser.window.setInterval (cast __stageRender, __interval);

		}
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function __handleAccelerometer (evt:DeviceMotionEvent):Void {
		
		__acceleration.x = evt.accelerationIncludingGravity.x;
		__acceleration.y = evt.accelerationIncludingGravity.y;
		__acceleration.z = evt.accelerationIncludingGravity.z;
		
	}
	
	
	private function __handleOrientationChange ():Void {
		
		//js.Lib.alert("orientation: " + getOrientation());
		
	}
	
	
	private function __onKey (code:Int, pressed:Bool, inChar:Int, ctrl:Bool, alt:Bool, shift:Bool, keyLocation:Int):Void {
		
		var stack = new Array <InteractiveObject> ();
		
		if (__focusObject == null) {
			
			this.__getInteractiveObjectStack (stack);
			
		} else {
			
			__focusObject.__getInteractiveObjectStack (stack);
			
		}
		
		if (stack.length > 0) {
			
			var obj = stack[0];
			var evt = new KeyboardEvent (pressed ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP, true, false, inChar, code, keyLocation, ctrl, alt, shift);
			obj.__fireEvent (evt);
			
		}
		
	}
	
	
	private function __onFocus (target:InteractiveObject):Void {
		
		// Don't do MOUSE_FOCUS_CHANGE or KEY_FOCUS_CHANGE events; doing those
		// would imply knowing whether the event was due to a user-initiated
		// mouse or key event, and that's not knowable in this implementation
		
		// If the focus has changed
		if (target != __focusObject) {
			
			// If there was a previously focused object, fire the FOCUS_OUT
			// event for it using the Flash event propogation semantics
			// implemented in __fireEvent
			
			if (__focusObject != null) {
				
				__focusObject.__fireEvent (new FocusEvent (FocusEvent.FOCUS_OUT, true, false, __focusObject, false, 0));
				
			}
			
			// Now dispatch a focus in event similarly using Flash event
			// propogation semantics
			target.__fireEvent (new FocusEvent (FocusEvent.FOCUS_IN, true, false, target, false, 0));
			
			// Finally, store the updated focus object
			__focusObject = target;
			
		}
		
	}
	
	
	private function __onMouse (event:js.html.MouseEvent, type:String) {
		
		var rect:Dynamic = untyped Lib.mMe.__scr.getBoundingClientRect ();
		var point:Point = untyped new Point (event.clientX - rect.left, event.clientY - rect.top);
		
		if (__dragObject != null) {
			
			__drag (point);
			
		}
		
		var obj = __getObjectUnderPoint (point);
		
		// used in drag implementation
		_mouseX = point.x;
		_mouseY = point.y;
		
		var stack = new Array<InteractiveObject> ();
		if (obj != null) obj.__getInteractiveObjectStack (stack);
		
		if (stack.length > 0) {
			
			//var global = obj.localToGlobal(point);
			//var obj = stack[0];
			
			stack.reverse ();
			var local = obj.globalToLocal (point);
			var evt = MouseEvent.__create (type, event, local, cast obj);
			
			__checkInOuts (evt, stack);
			
			// MOUSE_DOWN brings focus to the clicked object, and takes it
			// away from any currently focused object
			if (type == MouseEvent.MOUSE_DOWN) {
				
				__onFocus (stack[stack.length - 1]);
				
			}
			
			obj.__fireEvent (evt);
			
		} else {
			
			var evt = MouseEvent.__create (type, event, point, null);
			__checkInOuts (evt, stack);
			
		}
		
	}
	
	
	public function __onResize (inW:Int, inH:Int):Void {
		
		__windowWidth = inW;
		__windowHeight = inH;
		
		var event = new Event (Event.RESIZE);
		event.target = this;
		__broadcast (event);
		
	}
	
	
	private function __onTouch (event:js.html.TouchEvent, touch:js.html.Touch, type:String, touchInfo:TouchInfo, isPrimaryTouchPoint:Bool):Void {
		
		var rect:Dynamic = untyped Lib.mMe.__scr.getBoundingClientRect ();
		var point : Point = untyped new Point (touch.pageX - rect.left, touch.pageY - rect.top);
		var obj = __getObjectUnderPoint (point);
		
		// used in drag implementation
		_mouseX = point.x;
		_mouseY = point.y;
		
		var stack = new Array<InteractiveObject> ();
		if (obj != null) obj.__getInteractiveObjectStack (stack);
		
		if (stack.length > 0) {
			
			//var obj = stack[0];
			
			stack.reverse ();
			var local = obj.globalToLocal (point);
			var evt = TouchEvent.__create (type, event, touch, local, cast obj);
			
			evt.touchPointID = touch.identifier;
			evt.isPrimaryTouchPoint = isPrimaryTouchPoint;
			
			__checkInOuts (evt, stack, touchInfo);
			obj.__fireEvent (evt);
			
			var mouseType = switch (type) {
				
				case TouchEvent.TOUCH_BEGIN: MouseEvent.MOUSE_DOWN;
				case TouchEvent.TOUCH_END: MouseEvent.MOUSE_UP;
				default: 
					
					if (__dragObject != null) {
						
						__drag (point);
						
					}
					
					MouseEvent.MOUSE_MOVE;
				
			}
			
			obj.__fireEvent (MouseEvent.__create (mouseType, cast evt, local, cast obj));
			
		} else {
			
			var evt = TouchEvent.__create (type, event, touch, point, null);
			evt.touchPointID = touch.identifier;
			evt.isPrimaryTouchPoint = isPrimaryTouchPoint;
			__checkInOuts (evt, stack, touchInfo);
			
		}
		
	}

    private override function __getGraphics ():Graphics {
        return __graphics;
    }

	// Getters & Setters
	
	
	
	
	private function get_backgroundColor ():Int { return __backgroundColour; }
	private function set_backgroundColor (col:Int):Int { return __backgroundColour = col; }
	
	private function get_color ():Int { return __backgroundColour; }
	private function set_color (col:Int):Int { return __backgroundColour = col; }
	
	
	private inline function get_displayState ():StageDisplayState { return this.displayState; }
	private function set_displayState (displayState:StageDisplayState):StageDisplayState {
		
		if (displayState != this.displayState && this.displayState != null) {
			
			switch (displayState) {
				
				case NORMAL: Lib.__disableFullScreen ();
				case FULL_SCREEN, FULL_SCREEN_INTERACTIVE: Lib.__enableFullScreen ();
				
			}
			
		}
		
		this.displayState = displayState;
		return displayState;
		
	}
	
	
	private function get_focus ():InteractiveObject { return __focusObject; }
	private function set_focus (inObj:InteractiveObject):InteractiveObject {
		
		__onFocus (inObj);
		// __onFocus will have set __focusObject to inObj
		return __focusObject;
		
	}
	
	
	private function get_frameRate ():Float { return __frameRate; }
	private function set_frameRate (speed:Float):Float {
		
		if (speed == 0) {
			
			var window = Browser.window;
			var __requestAnimationFrame:Dynamic = untyped __js__("window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame");
			
			if (__requestAnimationFrame == null) {
				
				speed = 60;
				
			}
			
		}
		
		if (speed != 0) {
			
			__interval = Std.int (1000.0 / speed);
			
		}
		
		__frameRate = speed;
		__updateNextWake ();
		
		return speed;
	}
	
	
	private inline function get_fullScreenWidth ():Int { return Lib.__fullScreenWidth (); }
	private inline function get_fullScreenHeight ():Int { return Lib.__fullScreenHeight (); }
	
	
	private override function get_mouseX ():Float { return _mouseX; }
	private override function get_mouseY ():Float { return _mouseY; }
	
	
	private function get_quality ():String { return this.quality != null ? this.quality : StageQuality.BEST; }
	private function set_quality (inQuality:String):String { return this.quality = inQuality; }
	
	
	private inline function get_showDefaultContextMenu ():Bool { return __showDefaultContextMenu; }
	private function set_showDefaultContextMenu (showDefaultContextMenu:Bool):Bool {
		
		if (showDefaultContextMenu != this.showDefaultContextMenu && this.showDefaultContextMenu != null) {
			
			if (!showDefaultContextMenu) {
				
				Lib.__disableRightClick (); 
				
			} else {
				
				Lib.__enableRightClick ();
				
			}
			
		}
		
		__showDefaultContextMenu = showDefaultContextMenu;
		return showDefaultContextMenu;
		
	}
	
	
	override private function get_stage ():Stage {
		
		return Lib.__getStage ();
		
	}
	
	
	private function get_stageHeight ():Int { return __windowHeight; }
	private function get_stageWidth ():Int { return __windowWidth; }
	
	
}


private class TouchInfo {
	
	
	public var touchOverObjects:Array<InteractiveObject>;
	
	
	public function new () {
		
		touchOverObjects = [];
		
	}
	
	
}