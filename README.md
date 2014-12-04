Openfl-snapsvg
==============

It's the very beginning of a HTML5 backend for [OpenFL](http://www.openfl.org) based on [Snap.SVG](http://snapsvg.io)

[Demos (Actuate, BunnyMark, Aswing UI, Haxe UI)](http://ngrebenshikov.github.io/openfl-snapsvg/)

Getting Started
==================

For the "openfl-snapsvg" library, you can use a development build like this:

    haxelib git openfl-snapsvg https://github.com/ngrebenshikov/openfl-snapsvg

Navigate to the application.xml of your project and add the following before the inclusion of OpenFL:
```xml
<set name="html5-backend" value="openfl-snapsvg" />
```

Dependencies
------------

* openfl 2.0.1
* lime 1.0.1