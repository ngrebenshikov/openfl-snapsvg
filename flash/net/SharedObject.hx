package flash.net;


import flash.errors.Error;
import flash.events.EventDispatcher;
import flash.net.SharedObjectFlushStatus;
import flash.Lib;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;
import js.html.Storage;
import js.Browser;


class SharedObject extends EventDispatcher {
	
	
	public var data (default, null):Dynamic;
	public var size (get_size, never):Int;
	
	private var __key:String;
	

	private function new () {
		
		super ();
		
	}
	
	
	public function clear ():Void {
		
		data = { };
		
		try {
			
			__getLocalStorage ().removeItem (__key);
			
		} catch (e:Dynamic) {}
		
		flush ();
		
	}
	
	
	public function flush ():SharedObjectFlushStatus {
		
		var data = Serializer.run (data);
		
		try {
			
			__getLocalStorage ().removeItem (__key);
			__getLocalStorage ().setItem (__key, data);
			
		} catch (e:Dynamic) {
			
			// user may have privacy settings which prevent writing
			return SharedObjectFlushStatus.PENDING;
			
		}
		
		return SharedObjectFlushStatus.FLUSHED;
		
	}
	
	
	public static function getLocal (name:String, localPath:String = null, secure:Bool = false /* note: unsupported */) {
		
		if (localPath == null) {
			
			localPath = Browser.window.location.href;
			
		}
		
		var so = new SharedObject ();
		so.__key = localPath + ":" + name;
		var rawData = null;
		
		try {
			
			// user may have privacy settings which prevent reading
			rawData = __getLocalStorage ().getItem (so.__key);
			
		} catch (e:Dynamic) {}
		
		so.data = { };
		
		if (rawData != null && rawData != "") {
			
			var unserializer = new Unserializer (rawData);
			unserializer.setResolver (cast { resolveEnum: Type.resolveEnum, resolveClass: resolveClass } );
			so.data = unserializer.unserialize ();
			
		}
		
		if (so.data == null) {
			
			so.data = { };
			
		}
		
		return so;
		
	}
	
	
	private static function __getLocalStorage ():Storage {
		
		var res = Browser.getLocalStorage ();
		if (res == null) throw new Error ("SharedObject not supported");
		return res;
		
	}
	
	
	private static function resolveClass (name:String):Class <Dynamic> {
		
		if (name != null) {
			
			return Type.resolveClass (StringTools.replace (StringTools.replace (name, "jeash.", "flash."), "browser.", "flash."));
			
		}
		
		return null;
		
	}
	
	
	public function setProperty (propertyName:String, ?value:Dynamic):Void {
		
		if (data != null) {
			
			Reflect.setField (data, propertyName, value);
		}
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_size ():Int {
		
		var d = Serializer.run (data);
		return Bytes.ofString (d).length;
		
	}
	
	
}