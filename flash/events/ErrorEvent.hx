package flash.events;


class ErrorEvent extends TextEvent {
	
	
	public static var ERROR:String = "error";
	
	public var errorID (default, null):Int;
	
	
	public function new (type:String, ?bubbles:Bool, ?cancelable:Bool, ?text:String, id:Int = 0):Void {
		
		super (type, bubbles, cancelable);
		this.text = text;
		errorID = id;
		
	}
	
	
}