package flash.display;


class MovieClip extends Sprite implements Dynamic<Dynamic> {
	
	
	public var currentFrame (get_currentFrame, null):Int;
	public var enabled:Bool;
	public var framesLoaded (get_framesLoaded, null):Int;
	public var totalFrames (get_totalFrames, null):Int;
	
	private var __currentFrame:Int;
	private var __totalFrames:Int;
	
	
	public function new () {
		
		super ();
		
		enabled = true;
		__currentFrame = 0;
		__totalFrames = 0;
		
		this.loaderInfo = LoaderInfo.create (null);
		
	}
	
	
	public function gotoAndPlay (frame:Dynamic, scene:String = ""):Void {
		
		
		
	}
	
	
	public function gotoAndStop (frame:Dynamic, scene:String = ""):Void {
		
		
		
	}
	
	
	public function nextFrame ():Void {
		
		
		
	}
	
	
	public function play ():Void {
		
		
		
	}
	
	
	public function prevFrame ():Void {
		
		
		
	}
	
	
	public function stop ():Void {
		
		
		
	}
	
	
	override public function toString ():String {
		
		return "[MovieClip name=" + this.name + " id=" + ___id + "]";
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_currentFrame ():Int { return __currentFrame; }
	private function get_framesLoaded ():Int { return __totalFrames; }
	private function get_totalFrames ():Int { return __totalFrames; }
	
	
}