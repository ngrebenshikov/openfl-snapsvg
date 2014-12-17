Openfl-snapsvg
==============

It's the very beginning of a HTML5 backend for [OpenFL](http://www.openfl.org) based on [Snap.SVG](http://snapsvg.io)

[Demos (Actuate, BunnyMark, Aswing UI, Haxe UI, Stablex UI)](http://ngrebenshikov.github.io/openfl-snapsvg/)

Getting Started
==================

For the "openfl-snapsvg" library, you can use a development build like this:

    haxelib git openfl-snapsvg https://github.com/ngrebenshikov/openfl-snapsvg

Navigate to the application.xml of your project and add the following after the inclusion of OpenFL and all inclusions that depend on OpenFL:
```xml
<haxelib name="openfl-snapsvg" />
```

Parameters
----------

openfl_snapsvg_without_massive_broadcasting - it adds all listerners of `ENTER_FRAME` and `RENDER` to the stage and does not broadcast those events to all display objects.

```xml
<haxedef name="openfl_snapsvg_without_massive_broadcasting"/>
```

Dependencies
------------

* openfl 2.1.7
* lime 2.1.7
