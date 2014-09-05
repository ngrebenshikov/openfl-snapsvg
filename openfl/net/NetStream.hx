package openfl.net;


//import haxe.remoting.Connection;
import openfl.utils.UInt;
import openfl.display.Graphics;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.NetStatusEvent;
import openfl.media.VideoElement;
import openfl.Lib;
import haxe.Timer;
import js.html.VideoElement;
import js.Browser;


class NetStream extends EventDispatcher {
	
	
	public static inline var BUFFER_UPDATED:String = "openfl.net.NetStream.updated";
	public static inline var CODE_PLAY_STREAMNOTFOUND:String = "NetStream.Play.StreamNotFound";
	public static inline var CODE_BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
	public static inline var CODE_BUFFER_FULL:String = "NetStream.Buffer.Full";
	public static inline var CODE_BUFFER_FLUSH:String = "NetStream.Buffer.Flush";
	public static inline var CODE_BUFFER_START:String = "NetStream.Play.Start";
	public static inline var CODE_BUFFER_STOP:String = "NetStream.Play.Stop";
	public static inline var CODE_PLAY_TRANSITIONCOMPLETE:String = "NetStream.Play.TransitionComplete";
	public static inline var CODE_PLAY_SWITCH:String = "NetStream.Play.Switch";
    public static inline var CODE_PLAY_COMPLETE:String = "NetStream.Play.Complete";
	public static inline var CODE_PLAY_UNSUPPORTEDFORMAT:String = "NetStream.Play.UnsupportedFormat";
	public static inline var CODE_PLAY_ERROR:String = "NetStream.Play.error";
	public static inline var CODE_PLAY_WAITING:String = "NetStream.Play.waiting";
	public static inline var CODE_PLAY_SEEKING:String = "NetStream.Play.seeking";
	public static inline var CODE_PLAY_PAUSE:String = "NetStream.Play.pause";
	public static inline var CODE_PLAY_PLAYING:String = "NetStream.Play.playing";
	public static inline var CODE_PLAY_TIMEUPDATE:String = "NetStream.Play.timeupdate";
	public static inline var CODE_PLAY_LOADSTART:String = "NetStream.Play.loadstart";
	public static inline var CODE_PLAY_STALLED:String = "NetStream.Play.stalled";
	public static inline var CODE_PLAY_DURATIONCHANGED:String = "NetStream.Play.durationchanged";
	public static inline var CODE_PLAY_CANPLAYTHROUGH:String = "NetStream.Play.canplaythrough";
	public static inline var CODE_PLAY_CANPLAY:String = "NetStream.Play.canplay";


	/*
	 * todo:
	var audioCodec(default,null) : UInt;
	var bufferLength(default,null) : Float;
	var bufferTime :s Float;
	var bytesLoaded(default,null) : UInt;
	var bytesTotal(default,null) : UInt;
	var checkPolicyFile : Bool;
	var client : Dynamic;
	var currentFPS(default,null) : Float;
	var decodedFrames(default,null) : UInt;
	var liveDelay(default,null) : Float;
	var objectEncoding(default,null) : UInt;
	var soundTransform : openfl.media.SoundTransform;
	var time(default,null) : Float;
	var videoCodec(default,null) : UInt;
	*/
	
	public var bufferTime:Float;
	public var client:Dynamic;
	public var play:Dynamic;
	public var seek:Dynamic;
	public var pause:Dynamic;
	public var resume:Dynamic;
	public var togglePause:Dynamic;
	
	// There are special extra functions, that are not belong to NetStream in ActionScript API
	public var speed:Dynamic;
	public var requestVideoStatus:Dynamic;
	

	public var __videoElement(default, null):VideoElement;

	
	private static inline var fps:Int = 30;
	
	private static var timerAyncOp:Timer;
	
	private var __connection:NetConnection;
	
	
	
	public function new (connection:NetConnection):Void {
		
		super ();
        __videoElement = cast Browser.document.createElement ("video");
        __videoElement.addEventListener ("error", __onerror, false);
        __videoElement.addEventListener ("waiting", __onwaiting, false);
        __videoElement.addEventListener ("ended", __onend, false);
        __videoElement.addEventListener ("pause", __onpause, false);
        __videoElement.addEventListener ("seeking", __onseeking, false);
        __videoElement.addEventListener ("playing", __onplaying, false);
        __videoElement.addEventListener ("timeupdate", __ontimeupdate, false);
        __videoElement.addEventListener ("loadstart", __onloadstart, false);
        __videoElement.addEventListener ("stalled", __onstalled, false);
        __videoElement.addEventListener ("durationchanged", __ondurationchanged, false);
        __videoElement.addEventListener ("canplay", __oncanplay, false);
        __videoElement.addEventListener ("canplaythrough", __oncanplaythrough, false);

		__connection = connection;
		
		play = Reflect.makeVarArgs (__play);
		seek = Reflect.makeVarArgs (__seek);
		pause = Reflect.makeVarArgs (__pause);
		resume = Reflect.makeVarArgs (__resume);
		togglePause = Reflect.makeVarArgs (__togglePause);
		speed = Reflect.makeVarArgs (__speed);
		requestVideoStatus = Reflect.makeVarArgs (__requestVideoStatus);
		
	}
	

    private function raisePlayStatusDefault(code: String):Void {
        raisePlayStatus({
            code : code
           ,duration: __videoElement.duration
           ,speed:  __videoElement.playbackRate
           ,position: __videoElement.currentTime
           ,start: __videoElement.startTime
            });
    }

    private function __onerror(error:Dynamic):Void {
        __bufferStop(null);
        raisePlayStatusDefault(CODE_PLAY_ERROR);
    }

    private function __onwaiting(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_WAITING);
    }

	private function __onend(param:Dynamic):Void {
        __bufferStop(null);
        raisePlayStatusDefault(CODE_PLAY_COMPLETE);
    }

    private function __onseeking(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_SEEKING);
    }

    private function __onpause(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_PAUSE);
    }

    private function __onplaying(param:Dynamic):Void {
        __bufferStart(null);
        raisePlayStatusDefault(CODE_PLAY_PLAYING);
    }

    private function __ontimeupdate(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_TIMEUPDATE);
    }

    private function __onloadstart(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_LOADSTART);
    }

    private function __onstalled(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_STALLED);
    }

    private function __ondurationchanged(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_DURATIONCHANGED);
    }

    private function __oncanplaythrough(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_CANPLAYTHROUGH);
    }

    private function __oncanplay(param:Dynamic):Void {
        raisePlayStatusDefault(CODE_PLAY_CANPLAY);
    }


    private function __speed (val:Array<Dynamic>):Void {
        var newSpeed = val[0];
        __videoElement.playbackRate = newSpeed;
    }


    private function __requestVideoStatus (val:Array<Dynamic>):Void {
        if(null == timerAyncOp) {
            timerAyncOp = new Timer(1);
        }
        timerAyncOp.run = function() {
            if(__videoElement.paused) {
                raisePlayStatusDefault(CODE_PLAY_PAUSE);
            } else {
                raisePlayStatusDefault(CODE_PLAY_PLAYING);
            }
            timerAyncOp.stop();
        };
    }	


	private function __play (val:Array<Dynamic>):Void {
		var url = Std.string (val[0]);

		__videoElement.src = url;
		// we have to make explicit call 
		// because browser can disable auto play feature for video tag
		__videoElement.play();
	}
	
    private function __pause(val:Array<Dynamic>) : Void {
        __videoElement.pause();
    }

    private function __resume(val:Array<Dynamic>) : Void {
        __videoElement.play();
    }

    private function __seek(val:Array<Dynamic>) : Void {
        var offset:Float = val[0];
        var seekToTime = __videoElement.currentTime + offset;

        // there are two approaches to validate parameters
        /*
        if( (seekToTime < 0) || (seekToTime > __videoElement.duration) ) {
            return;
        }
        */

        if (seekToTime < 0) {
            seekToTime = 0;
        } else if(seekToTime > __videoElement.duration) {
            seekToTime = __videoElement.duration;
        }
        __videoElement.currentTime = seekToTime;
    }

    private function __togglePause(val:Array<Dynamic>) : Void {
       if(__videoElement.paused) {
           __videoElement.play();
       } else {
           // TODO: check once again if pause operation is possible in current state
           __videoElement.pause();
       }
    }

    // raise play status
    private function raisePlayStatus(info:Dynamic) {
        if(null != client) {
            try{
                var handler: Dynamic;
                handler = client.onPlayStatus;
                handler(info);
            } catch(err: Dynamic) {
            
            }
        }
    }
	
	
	// Event Handlers
	
	
	
	
	public function __bufferEmpty (e) {
		
		__connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_EMPTY } ));
		
	}
	
	
	public function __bufferStop (e) {
		
		__connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_STOP } ));
		
	}
	
	
	public function __bufferStart(e) {
		
		__connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_START } ));
		
	}
	
	
	public function __notFound(e) {
		
		__connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_PLAY_STREAMNOTFOUND } ));
		
	}

    public function __unsupportedFormat(e) {
        __connection.dispatchEvent (new NetStatusEvent (NetStatusEvent.NET_STATUS, false, false, { code : CODE_PLAY_UNSUPPORTEDFORMAT } ));
        
    }

	/*
	todo:
	function attachAudio(microphone : openfl.media.Microphone) : Void;
	function attachCamera(theCamera : openfl.media.Camera, ?snapshotMilliseconds : Int) : Void;
	function close() : Void;
	function publish(?name : String, ?type : String) : Void;
	
	function receiveVideoFPS(FPS : Float) : Void;
	function send(handlerName : String, ?p1 \: Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Void;
	function togglePause() : Void;

	#if flash10
	var maxPauseBufferTime : Float;
	var farID(default,null) : String;
	var farNonce(default,null) : String;
	var info(default,null) : NetStreamInfo;
	var nearNonce(default,null) : String;
	var peerStreams(default,null) : Array<Dynamic>;

	function onPeerConnect( subscriber : NetStream ) : Bool;
	function play2( param : NetStreamPlayOptions ) : Void;

	static var DIRECT_CONNECTIONS : String;
	#end
	*/
	
	
}