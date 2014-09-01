package flash.events;


class KeyboardEvent extends Event {
	
	
	public static var KEY_DOWN = "keyDown";
	public static var KEY_UP = "keyUp";
    public static var KEY_PRESS = "keyPressed";

	public var altKey:Bool;
	public var charCode:Int;
	public var ctrlKey:Bool;
	public var commandKey:Bool;
	public var controlKey:Bool;
	public var keyCode:Int;
	public var keyLocation:Int;
	public var shiftKey:Bool;
	
	
	public function new (type:String, bubbles:Bool = false, cancelable:Bool = false, inCharCode:Int = 0, inKeyCode:Int = 0, inKeyLocation:Int = 0, inCtrlKey:Bool = false, inAltKey:Bool = false, inShiftKey:Bool = false, controlKeyValue:Bool = false, commandKeyValue:Bool = false) {
		
		super (type, bubbles, cancelable);
		
		altKey = (inAltKey == null ? false : inAltKey);
		charCode = (inCharCode == null ? 0 : inCharCode);
		ctrlKey = (inCtrlKey == null ? false : inCtrlKey);
		commandKey = commandKeyValue;
		controlKey = controlKeyValue;
		keyCode = inKeyCode;
		keyLocation = (inKeyLocation == null ? 0 : inKeyLocation);
		shiftKey = (inShiftKey == null ? false : inShiftKey);
		
	}
	
	
}