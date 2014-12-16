import lime.Assets;

class ApplicationMain {


	public static var config:lime.app.Config;
	public static var preloader:openfl.display.Preloader;

	public static function create ():Void {

		var display = ::if (PRELOADER_NAME != "")::new ::PRELOADER_NAME:: ()::else::new NMEPreloader ()::end::;

		preloader = new openfl.display.Preloader (display);
		preloader.onComplete = init;
		preloader.create (config);

#if js
		var urls = [];
		var types = [];
		
		::foreach assets::::if (embed)::
		if(urls.indexOf("::resourceName::") < 0) {
			urls.push ("::resourceName::");
			::if (type == "image")::types.push (AssetType.IMAGE);
			::elseif (type == "binary")::types.push (AssetType.BINARY);
			::elseif (type == "text")::types.push (AssetType.TEXT);
			::elseif (type == "font")::types.push (AssetType.FONT);
			::elseif (type == "sound")::types.push (AssetType.SOUND);
			::elseif (type == "music")::types.push (AssetType.MUSIC);
			::else::types.push (null);::end::
		}
		::end::::end::
		
		preloader.load (urls, types);
		#end

		#if sys
		Sys.exit (result);
		#end

	}


	public static function init ():Void {

		var loaded = 0;
		var total = 0;
		var library_onLoad = function (_) {

			loaded++;

			if (loaded == total) {

				start ();

			}

		}

		preloader = null;

		::if (libraries != null)::::foreach libraries::::if (preload)::
		total++;
		openfl.Assets.loadLibrary ("::name::", library_onLoad);
		::end::::end::::end::

		if (loaded == total) {

		start ();

		}

	}


	public static function main () {

		config = {

		antialiasing: Std.int (::WIN_ANTIALIASING::),
		background: Std.int (::WIN_BACKGROUND::),
		borderless: ::WIN_BORDERLESS::,
		depthBuffer: ::WIN_DEPTH_BUFFER::,
		fps: Std.int (::WIN_FPS::),
		fullscreen: ::WIN_FULLSCREEN::,
		height: Std.int (::WIN_HEIGHT::),
		orientation: "::WIN_ORIENTATION::",
		resizable: ::WIN_RESIZABLE::,
		stencilBuffer: ::WIN_STENCIL_BUFFER::,
		title: "::APP_TITLE::",
		vsync: ::WIN_VSYNC::,
		width: Std.int (::WIN_WIDTH::),

		}

		#if munit
		flash.Lib.embed (null, ::WIN_WIDTH::, ::WIN_HEIGHT::, "::WIN_FLASHBACKGROUND::");
		#else
		create ();
		#end

	}


	public static function start ():Void {

		openfl.Lib.current.stage.align = openfl.display.StageAlign.TOP_LEFT;
		openfl.Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;

		var hasMain = false;

		for (methodName in Type.getClassFields (::APP_MAIN::)) {

			if (methodName == "main") {

				hasMain = true;
				break;

			}

		}

		if (hasMain) {

			Reflect.callMethod (::APP_MAIN::, Reflect.field (::APP_MAIN::, "main"), []);

		} else {

			var instance:DocumentClass = Type.createInstance (DocumentClass, []);

			if (Std.is (instance, openfl.display.DisplayObject)) {

				openfl.Lib.current.addChild (cast instance);

			}

		}

		openfl.Lib.current.stage.dispatchEvent (new openfl.events.Event (openfl.events.Event.RESIZE, false, false));

	}


#if neko
	@:noCompletion public static function __init__ () {
		
		var loader = new neko.vm.Loader (untyped $loader);
		loader.addPath (haxe.io.Path.directory (Sys.executablePath ()));
		loader.addPath ("./");
		loader.addPath ("@executable_path/");
		
	}
	#end


}


@:keep class DocumentClass extends ::APP_MAIN:: {}
