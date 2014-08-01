package flash.text;


import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import flash.Lib;
import js.html.CanvasElement;
import js.html.Element;
import js.Browser;


class TextField extends InteractiveObject {
	
	
	public static var mDefaultFont = Font.DEFAULT_FONT_NAME;
	
	public var antiAliasType:String;
	public var autoSize (default, set_autoSize):String;
	public var background (default,set_background):Bool;
	public var backgroundColor (default, set_backgroundColor):Int;
	public var border (default, set_border):Bool;
	public var borderColor (default, set_borderColor):Int;
	public var bottomScrollV (get_bottomScrollV, null):Int;
	public var caretIndex:Int;
	public var caretPos (get_caretPos, null):Int;
	public var defaultTextFormat (get_defaultTextFormat, set_defaultTextFormat):TextFormat;
	public var displayAsPassword:Bool;
	public var embedFonts:Bool;
	public var gridFitType:GridFitType;
	public var htmlText (get_htmlText, set_htmlText):String;
	public var length (default, null):Int;
	public var maxChars:Int;
	public var maxScrollH (get_maxScrollH, null):Int;
	public var maxScrollV (get_maxScrollV, null):Int;
	public var mDownChar:Int;
	public var mFace:String;
	public var mParagraphs:Paragraphs;
	public var mTextHeight:Int;
	public var mTryFreeType:Bool;
	@:isVar public var multiline (default, default):Bool;
	public var numLines (get_numLines, null):Int;
	public var restrict:String;
	public var scrollH:Int;
	public var scrollV:Int;
	public var selectable:Bool;
	public var selectionBeginIndex:Int;
	public var selectionEndIndex:Int;
	public var sharpness:Float;
	public var text (get_text, set_text):String;
	public var textColor (get_textColor, set_textColor):Int;
	public var textHeight (get_textHeight, null):Float;
	public var textWidth (get_textWidth, null):Float;
	public var type (get_type, set_type):String;
	@:isVar public var wordWrap (get_wordWrap, set_wordWrap):Bool;
	
	private static var sSelectionOwner:TextField = null;
	
	private var mAlign:TextFormatAlign;
	private var mHeight:Float;
	private var mHTMLText:String;
	private var mHTMLMode:Bool;
	private var mInsertPos:Int;
	private var mLimitRenderX:Int;
	private var mLineInfo:Array<LineInfo>;
	private var mMaxHeight:Float;
	private var mMaxWidth:Float;
	private var mSelectionAnchor:Int;
	private var mSelectionAnchored:Bool;
	private var mSelEnd:Int;
	private var mSelStart:Int;
	private var mSelectDrag:Int;
	private var mText:String;
	private var mTextColour:Int;
	private var mType:String;
	private var mWidth:Float;
	private var __graphics:Graphics;
	private var __inputEnabled:Bool;
	private var _defaultTextFormat:TextFormat;
	
	
	public function new () {
		
		super ();
		
		mWidth = 100;
		mHeight = 20;
		mHTMLMode = false;
		multiline = false;
		__graphics = new Graphics ();
		mFace = mDefaultFont;
		mAlign = TextFormatAlign.LEFT;
		mParagraphs = new Paragraphs ();
		mSelStart = -1;
		mSelEnd = -1;
		scrollH = 0;
		scrollV = 1;
		
		mType = TextFieldType.DYNAMIC;
		autoSize = TextFieldAutoSize.NONE;
		mTextHeight = 12;
		mMaxHeight = mTextHeight;
		mHTMLText = " ";
		mText = " ";
		mTextColour = 0x000000;
		tabEnabled = false;
		mTryFreeType = true;
		selectable = true;
		mInsertPos = 0;
		__inputEnabled = false;
		mDownChar = 0;
		mSelectDrag = -1;
		
		mLineInfo = [];
		defaultTextFormat = new TextFormat ();
		
		borderColor = 0x000000;
		border = false;
		backgroundColor = 0xffffff;
		background = false;
		gridFitType = GridFitType.PIXEL;
		sharpness = 0;
		
	}
	
	
	public function appendText (newText:String):Void {
		
		this.text += newText;
		
	}
	
	
	public function ConvertHTMLToText (inUnSetHTML:Bool):Void {
		
		mText = "";
		
		for (paragraph in mParagraphs) {
			
			for (span in paragraph.spans) {
				
				mText += span.text;
				
			}
			
			// + \n ?
			
		}
		
		if (inUnSetHTML) {
			
			mHTMLMode = false;
			RebuildText ();
			
		}
		
	}
	
	
	private function DecodeColour (col:String):Int {
		
		return Std.parseInt ("0x" + col.substr(1));
		
	}
	
	
	public function getCharBoundaries (a:Int):Rectangle {
		
		// TODO
		return null;
		
	}
	
	
	public function getCharIndexAtPoint (inX:Float, inY:Float):Int {
		
		var li = getLineIndexAtPoint (inX, inY);
		
		if (li < 0) {
			
			return -1;
			
		}
		
		var line = mLineInfo[li];
		var idx = line.mIndex;
		
		for (x in line.mX) {
			
			if (x > inX) return idx;
			idx++;
			
		}
		
		return idx;
		
	}
	
	
	public function getLineIndexAtPoint (inX:Float, inY:Float):Int {
		
		if (mLineInfo.length < 1) return -1;
		if (inY <= 0) return 0;
		
		for (l in 0...mLineInfo.length) {
			
			if (mLineInfo[l].mY0 > inY) {
				
				return l == 0 ? 0 : l - 1;
				
			}
			
		}
		
		return mLineInfo.length - 1;
		
	}
	
	
	public function getTextFormat (beginIndex:Int = 0, endIndex:Int = 0):TextFormat {
		
		return new TextFormat (mFace, mTextHeight, mTextColour);
		
	}
	
	
	private function Rebuild () {
		
		if (mHTMLMode) return;
		
		mLineInfo = [];
		__graphics.clear ();
		
		if (background) {
			
			__graphics.beginFill (backgroundColor);
			__graphics.drawRect (0, 0, width, height );
			__graphics.endFill ();
			
		}

		__graphics.lineStyle (mTextColour);
		var insert_x:Null<Int> = null;
		mMaxWidth = 0;
		
		//mLimitRenderX = (autoSize == flash.text.TextFieldAutoSize.NONE) ? Std.int(width) : 999999;
		var wrap = mLimitRenderX = (wordWrap && !__inputEnabled) ? Std.int (mWidth) : 999999;
		var char_idx = 0;
		var h:Int = 0;
		
		var s0 = mSelStart;
		var s1 = mSelEnd;
		
		for (paragraph in mParagraphs) {
			
			var row:Array<RowChar> = [];
			var row_width = 0;
			var last_word_break = 0;
			var last_word_break_width = 0;
			var last_word_char_idx = 0;
			var start_idx = char_idx;
			var tx = 0;
			
			for (span in paragraph.spans) {
				
				var text = span.text;
				var font = span.font;
				var fh = font.height;
				
				last_word_break = row.length;
				last_word_break_width = row_width;
				last_word_char_idx = char_idx;
				
				for (ch in 0...text.length) {
					
					var g = text.charCodeAt (ch);
					var adv = font.__getAdvance (g);
					
					if (g == 32) {
						
						last_word_break = row.length;
						last_word_break_width = tx;
						last_word_char_idx = char_idx;
						
					}
					
					if ((tx + adv) > wrap) {
						
						if (last_word_break > 0) {
							
							var row_end = row.splice (last_word_break, row.length - last_word_break);
							h += RenderRow (row, h, start_idx, paragraph.align);
							row = row_end;
							tx -= last_word_break_width;
							start_idx = last_word_char_idx;
							
							last_word_break = 0;
							last_word_break_width = 0;
							last_word_char_idx = 0;
							
							if (row_end.length > 0 && row_end[0].chr == 32) {
								
								row_end.shift ();
								start_idx ++;
								
							}
							
						} else {
							
							h += RenderRow (row, h, char_idx, paragraph.align);
							row = [];
							tx = 0;
							start_idx = char_idx;
							
						}
						
					}
					
					row.push ( { font: font, chr: g, x: tx, fh: fh, sel:(char_idx >= s0 && char_idx < s1), adv: adv } );
					tx += adv;
					char_idx++;
					
				}
				
			}
			
			if (row.length > 0) {
				
				h += RenderRow (row, h, start_idx, paragraph.align, insert_x);
				insert_x = null;
				
			}
			
		}
		
		var w = mMaxWidth;
		
		if (h < mTextHeight) {
			
			h = mTextHeight;
			
		}
		
		mMaxHeight = h;
		
		switch (autoSize) {
			
			case TextFieldAutoSize.LEFT:
			case TextFieldAutoSize.RIGHT:
				
				var x0 = x + width;
				x = mWidth - x0;
			
			case TextFieldAutoSize.CENTER:
				
				var x0 = x + width/2;
				x = mWidth / 2 - x0;
			
			default:
				
				if (wordWrap)
					height = h;
			
		}
		
		if (border) {
			
			__graphics.endFill ();
			__graphics.lineStyle (1, borderColor, 1, true);
			__graphics.drawRect (.5, .5, width-.5, height-.5);
			
		}
		
	}
	
	
	public function RebuildText () {
		
		mParagraphs = [];
		
		if (!mHTMLMode) {
			
			var font = FontInstance.CreateSolid (mFace, mTextHeight, mTextColour, 1.0);
			var paras = mText.split ("\n");
			
			for (paragraph in paras) {
				
				mParagraphs.push ( { align: mAlign, spans: [ { font : font, text: paragraph + "\n" } ] } );
				
			}
			
		}
		
		Rebuild();
		
	}
	
	
	private function RenderRow (inRow:Array<RowChar>, inY:Int, inCharIdx:Int, inAlign:TextFormatAlign, inInsert:Int = 0):Int {
		
		var h = 0;
		var w = 0;
		
		for (chr in inRow) {
			
			if (chr.fh > h) {
				
				h = chr.fh;
				
			}
			
			w += chr.adv;
			
		}
		
		if (w > mMaxWidth) {
			
			mMaxWidth = w;
			
		}
		
		var full_height = Std.int (h * 1.2);
		var align_x = 0;
		var insert_x = 0;
		
		if (inInsert != null) {
			
			// TODO: check if this is necessary.
			if (autoSize != TextFieldAutoSize.NONE) {
				
				scrollH = 0;
				insert_x = inInsert;
				
			} else {
				
				insert_x = inInsert - scrollH;
				
				if (insert_x < 0) {
					
					scrollH -= ((mLimitRenderX * 3) >> 2 ) - insert_x;
					
				} else if (insert_x > mLimitRenderX) {
					
					scrollH +=  insert_x - ((mLimitRenderX * 3) >> 2);
					
				}
				
				if (scrollH < 0) {
					
					scrollH = 0;
					
				}
				
			}
			
		}
		
		if (autoSize == TextFieldAutoSize.NONE && w <= mLimitRenderX) {
			
			if (inAlign == TextFormatAlign.CENTER) {
			
				align_x = (Math.round (mWidth)-w)>>1;
			
			} else if (inAlign == TextFormatAlign.RIGHT) {
				
				align_x = Math.round (mWidth)-w;
				
			}
			
		}
		
		var x_list = new Array<Int> ();
		mLineInfo.push ( { mY0: inY, mIndex: inCharIdx - 1, mX: x_list } );
		
		var cache_sel_font:FontInstance = null;
		var cache_normal_font:FontInstance = null;
		var x = align_x - scrollH;
		var x0 = x;
		
		for (chr in inRow) {
			
			var adv = chr.adv;
			
			if (x + adv > mLimitRenderX) {
				
				break;
				
			}
			
			x_list.push (x);
			
			if (x >= 0) {
				
				var font = chr.font;
				
				if (chr.sel) {
					
					__graphics.lineStyle ();
					__graphics.beginFill (0x202060);
					__graphics.drawRect (x, inY, adv, full_height);
					__graphics.endFill ();
					
					if (cache_normal_font == chr.font) {
						
						font = cache_sel_font;
						
					} else {
						
						font = FontInstance.CreateSolid (chr.font.GetFace (), chr.fh, 0xffffff, 1.0);
						cache_sel_font = font;
						cache_normal_font = chr.font;
						
					}
					
				}
				
				font.RenderChar (__graphics, chr.chr, x, Std.int(inY + (h - chr.fh)));
				
			}
			
			x += adv;
			
		}
		
		x += scrollH;
		return full_height;
		
	}
	
	
	public function setSelection (beginIndex:Int, endIndex:Int) {
		
		// TODO:
		
	}
	
	
	public function setTextFormat (inFmt:TextFormat, beginIndex:Int = 0, endIndex:Int = 0) {
		
		if (inFmt.font != null) {
			
			mFace = inFmt.font;
			
		}
		
		if (inFmt.size != null) {
			
			mTextHeight = Std.int (inFmt.size);
			
		}
		
		if (inFmt.align != null) {
			
			mAlign = inFmt.align;
			
		}
		
		if (inFmt.color != null) {
			
			mTextColour = inFmt.color;
			
		}
		
		RebuildText ();
		__invalidateBounds ();
		
		return getTextFormat ();
		
	}
	
	
	override public function toString ():String {
		
		return "[TextField name=" + this.name + " id=" + ___id + "]";
		
	}
	
	
	private override function __getGraphics ():Graphics {
		
		return __graphics;
		
	}
	
	
	override public function __getObjectUnderPoint (point:Point):DisplayObject {
		
		if (!visible) {
			
			return null; 
			
		} else if (this.mText.length > 1) {
			
			var local = globalToLocal (point);
			
			if (local.x < 0 || local.y < 0 || local.x > mMaxWidth || local.y > mMaxHeight) {
				
				return null;
				
			} else {
				
				return cast this;
				
			}
			
		} else {
			
			return super.__getObjectUnderPoint (point);
			
		}
		
	}
	
	
	override public function __render (inMask:CanvasElement = null, clipRect:Rectangle = null):Void {
		
		if (!__combinedVisible) return;
		if (_matrixInvalid || _matrixChainInvalid) __validateMatrix ();
		
		//if (__graphics.__surface != null) {
			//
			//Lib.__setImageSmoothing (__graphics.__surface.getContext ("2d"), (gridFitType != GridFitType.PIXEL));
			//
		//}
		
		if (__graphics.__render (inMask, __filters, 1, 1)) {
			
			handleGraphicsUpdated (__graphics);
			
		}
//TODO: uncomment
//		if (!mHTMLMode && inMask != null) {
//
//			var m = getSurfaceTransform (__graphics);
//			Lib.__drawToSurface (__graphics.__surface, inMask, m, (parent != null ? parent.__combinedAlpha : 1) * alpha, clipRect, (gridFitType != GridFitType.PIXEL));
//
//		} else {
//
//			if (__testFlag (DisplayObject.TRANSFORM_INVALID)) {
//
//				var m = getSurfaceTransform (__graphics);
//				Lib.__setSurfaceTransform (__graphics.__surface, m);
//				__clearFlag (DisplayObject.TRANSFORM_INVALID);
//
//			}
//
//			Lib.__setSurfaceOpacity (__graphics.__surface, (parent != null ? parent.__combinedAlpha : 1) * alpha);
//
//			/*if (clipRect != null) {
//				var rect = new Rectangle();
//				rect.topLeft = this.globalToLocal(this.parent.localToGlobal(clipRect.topLeft));
//				rect.bottomRight = this.globalToLocal(this.parent.localToGlobal(clipRect.bottomRight));
//				Lib.__setSurfaceClipping(__graphics.__surface, rect);
//			}*/
//
//		}
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_autoSize ():String {
		
		return autoSize;
		
	}
	
	
	private function set_autoSize (inAutoSize:String):String {
		
		autoSize = inAutoSize;
		Rebuild ();
		return inAutoSize;
		
	}
	
	
	private function set_background (inBack:Bool):Bool {
		
		background = inBack;
		Rebuild ();
		return inBack;
		
	}
	
	
	private function set_backgroundColor (inCol:Int):Int {
		
		backgroundColor = inCol;
		Rebuild ();
		return inCol;
		
	}
	
	
	private function set_border (inBorder:Bool):Bool {
		
		border = inBorder;
		Rebuild ();
		return inBorder;
		
	}
	
	
	private function set_borderColor (inBorderCol:Int):Int {
		
		borderColor = inBorderCol;
		Rebuild ();
		return inBorderCol;
		
	}
	
	
	private function get_bottomScrollV ():Int { return 0; }
	
	
	private function get_caretPos ():Int {
		
		return mInsertPos;
		
	}
	
	
	private function get_defaultTextFormat ():TextFormat {
		
		return _defaultTextFormat;
		
	}
	
	
	private function set_defaultTextFormat (inFmt:TextFormat):TextFormat {
		
		setTextFormat (inFmt);
		_defaultTextFormat = inFmt;
		return inFmt;
		
	}
	
	
	private override function get_height ():Float {
		
		return Math.max (mHeight,getBounds (this.stage).height);
		
	}
	
	
	override private function set_height (inValue:Float):Float {
		
		if (parent != null) {
			
			parent.__invalidateBounds ();
			
		}
		
		if (_boundsInvalid) {
			
			validateBounds ();
			
		}
		
		if (inValue != mHeight) {
			
			mHeight = inValue;
			Rebuild ();
			
		}
		
		return mHeight;
		
	}
	
	
	public function get_htmlText ():String {
		
		return mHTMLText;
		
	}
	
	
	public function set_htmlText (inHTMLText:String):String {
		
		mParagraphs = new Paragraphs ();
		mHTMLText = inHTMLText;
//TODO: uncomment
//		if (!mHTMLMode) {
//
//			var domElement:Dynamic = Browser.document.createElement ("div");
//
//			if (background || border) {
//
//				domElement.style.width = mWidth + "px";
//				domElement.style.height = mHeight + "px";
//
//			}
//
//			if (background) {
//
//				domElement.style.backgroundColor = "#" + StringTools.hex (backgroundColor,6);
//
//			}
//
//			if (border) {
//
//				domElement.style.border = "1px solid #" + StringTools.hex (borderColor,6);
//
//			}
//
//
//			// ---
//			// This will set: font-face, color, font-size, align in <div style="..." />
//			// It assumes that, the font-face used is already loaded by the browser.
//			// As it uses canvas wrapper tags, this is the best possible here.
//			//
//			// WARNING: do not set (domElement.style.cssText), or (domElement.style.font)
//			//
//			// TODO (Encore): we need to script our custom font loading into a .css file
//			// TODO (Service): app server should send correct mime-type for .ttf files
//			//                 not application/octet-stream, may be application/x-font-ttf
//			//
//			//
//			// TODO HAXE: compiler needs to be fixed to link .css files into html header.
//			//
//
//			domElement.style.color = "#" + StringTools.hex (mTextColour, 6);
//			domElement.style.fontFamily = mFace;
//			domElement.style.fontSize = mTextHeight + "px";
//			domElement.style.textAlign = Std.string (mAlign);
//
//			var wrapper:CanvasElement = cast domElement;
//			wrapper.innerHTML = inHTMLText;
//
//			var destination = new Graphics (wrapper);
//			var __surface = __graphics.__surface;
//
//			if (Lib.__isOnStage (__surface)) {
//
//				Lib.__appendSurface (wrapper);
//				Lib.__copyStyle (__surface, wrapper);
//				Lib.__swapSurface (__surface, wrapper);
//				Lib.__removeSurface (__surface);
//
//			}
//
//			__graphics = destination;
//			__graphics.__extent.width = wrapper.width;
//			__graphics.__extent.height = wrapper.height;
//
//		} else {
//
//			__graphics.__surface.innerHTML = inHTMLText;
//
//		}
//
//		mHTMLMode = true;
//		RebuildText ();
//		__invalidateBounds ();
		
		return mHTMLText;
		
	}
	
	
	private function get_maxScrollH ():Int { return 0; }
	private function get_maxScrollV ():Int { return 0; }
	private function get_multiline ():Bool { return multiline; }
	private function set_multiline (value:Bool):Bool { return multiline = value; }
	private function get_numLines ():Int { return 0; }
	private function get_scrollH ():Int { return scrollH; }
	private function set_scrollH (value:Int):Int { return scrollH = value; }
	private function get_scrollV ():Int { return scrollV; }
	private function set_scrollV (value:Int):Int { return scrollV = value; }
	
	
	public function get_text ():String {
		
		if (mHTMLMode) {
			
			ConvertHTMLToText (false);
			
		}
		
		return mText;
		
	}
	
	
	public function set_text (inText:String):String {
		
		mText = Std.string (inText);
		//mHTMLText = inText;
		mHTMLMode = false;
		RebuildText ();
		__invalidateBounds ();
		
		return mText;
		
	}
	
	
	public function get_textColor ():Int { return mTextColour; }
	public function set_textColor (inCol:Int):Int {
		
		mTextColour = inCol;
		RebuildText ();
		return inCol;
		
	}
	
	
	public function get_textWidth ():Float { return mMaxWidth; }
	public function get_textHeight ():Float { return mMaxHeight; }
	
	
	public function get_type ():String { return mType; }
	public function set_type (inType:String):String {
		
		mType = inType;
		__inputEnabled = (mType == TextFieldType.INPUT);
		
//TODO: uncomment
//		if (mHTMLMode) {
//
//			if (__inputEnabled) {
//
//				Lib.__setContentEditable(__graphics.__surface, true);
//
//			} else {
//
//				Lib.__setContentEditable(__graphics.__surface, false);
//
//			}
//
//		} else if (__inputEnabled) {
//
//			// implicitly convert text to a HTML field, and set contenteditable
//			set_htmlText (StringTools.replace (mText, "\n", "<BR />"));
//			Lib.__setContentEditable (__graphics.__surface, true);
//
//		}
		
		tabEnabled = (type == TextFieldType.INPUT);
		
		Rebuild ();
		
		return inType;
		
	}
	
	
	override public function get_width ():Float {
		
		return Math.max (mWidth, getBounds (this.stage).width);
		
	}
	
	
	override public function set_width (inValue:Float):Float {
		
		if (parent != null) {
			
			parent.__invalidateBounds ();
			
		}
		
		if (_boundsInvalid) {
			
			validateBounds ();
			
		}
		
		if (inValue != mWidth) {
			
			mWidth = inValue;
			Rebuild ();
			
		}
		
		return mWidth;
		
	}
	
	
	public function get_wordWrap ():Bool {
		
		return wordWrap;
		
	}
	public function set_wordWrap (inWordWrap:Bool):Bool {
		
		wordWrap = inWordWrap;
		Rebuild ();
		return wordWrap;
		
	}
	
	
}


enum FontInstanceMode {
	
	fimSolid;
	
}


class FontInstance {
	
	
	public var height (get_height, null):Int;
	public var mTryFreeType:Bool;
	
	private static var mSolidFonts = new Map<String, FontInstance> ();
	
	private var mMode:FontInstanceMode;
	private var mColour:Int;
	private var mAlpha:Float;
	private var mFont:Font;
	private var mHeight:Int;
	private var mGlyphs:Array<Element>;
	private var mCacheAsBitmap:Bool;
	
	
	private function new (inFont:Font, inHeight:Int) {
		
		mFont = inFont;
		mHeight = inHeight;
		mTryFreeType = true;
		mGlyphs = [];
		mCacheAsBitmap = false;
		
	}
	
	
	static public function CreateSolid (inFace:String, inHeight:Int, inColour:Int, inAlpha:Float):FontInstance {
		
		var id = "SOLID:" + inFace+ ":" + inHeight + ":" + inColour + ":" + inAlpha;
		var f:FontInstance =  mSolidFonts.get (id);
		
		if (f != null) {
			
			return f;
			
		}
		
		var font:Font = new Font ();
		font.__setScale (inHeight);
		font.fontName = inFace;
		
		if (font == null) {
			
			return null;
			
		}
		
		f = new FontInstance (font, inHeight);
		f.SetSolid (inColour, inAlpha);
		mSolidFonts.set (id, f);
		
		return f;
		
	}
	
	
	public function GetFace ():String {
		
		return mFont.fontName;
		
	}
	
	
	private function SetSolid (inCol:Int, inAlpha:Float):Void {
		
		mColour = inCol;
		mAlpha = inAlpha;
		mMode = fimSolid;
		
	}
	
	
	public function RenderChar (inGraphics:Graphics, inGlyph:Int, inX:Int, inY:Int):Void {
		
		inGraphics.__clearLine ();
		inGraphics.beginFill (mColour, mAlpha);
		mFont.__render (inGraphics, inGlyph, inX, inY, mTryFreeType);
		inGraphics.endFill ();
		
	}
	
	
	public function toString ():String {
		
		return "FontInstance:" + mFont + ":" + mColour + "(" + mGlyphs.length + ")";
		
	}
	
	
	public function __getAdvance (inChar:Int):Int {
		
		if (mFont == null) return 0;
		return mFont.__getAdvance (inChar, mHeight);
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_height ():Int {
		
		return mHeight;
		
	}
	
	
}


typedef SpanAttribs = {
	
	var face:String;
	var height:Int;
	var colour:Int;
	var align:TextFormatAlign;
	
}


typedef Span = {
	
	var font:FontInstance;
	var text:String;
	
}


typedef Paragraph = {
	
	var align:TextFormatAlign;
	var spans: Array<Span>;
	
}


typedef Paragraphs = Array<Paragraph>;


typedef LineInfo = {
	
	var mY0:Int;
	var mIndex:Int;
	var mX:Array<Int>;
	
}


typedef RowChar = {
	
	var x:Int;
	var fh:Int;
	var adv:Int;
	var chr:Int;
	var font:FontInstance;
	var sel:Bool;
	
}


typedef RowChars = Array<RowChar>;