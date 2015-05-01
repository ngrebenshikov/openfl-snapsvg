package openfl.text;


import openfl.events.TextEvent;
import flash.geom.Rectangle;
import js.html.Document;
import js.html.ClientRect;
import haxe.Timer;
import js.html.svg.SVGElement;
import js.html.svg.TextElement;
import openfl.events.MouseEvent;
import openfl.text.TextField.Paragraph;
import snap.Snap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.InteractiveObject;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.text.TextFormatAlign;
import openfl.ui.Keyboard;
import openfl.Lib;
import js.html.CanvasElement;
import js.html.Element;
import js.Browser;

class TextField extends InteractiveObject {
	
	
	public static var mDefaultFont = Font.DEFAULT_FONT_NAME;
	
	public var antiAliasType:String;
	public var autoSize (default, set_autoSize):TextFieldAutoSize;
	public var background (default,set_background):Bool;
	public var backgroundColor (default, set_backgroundColor):Int;
	public var border (default, set_border):Bool;
	public var borderColor (default, set_borderColor):Int;
	public var bottomScrollV (default, null):Int;
	private var _caretIndex: Int;
	public var caretIndex(get, set):Int;
	public var caretPos (get_caretPos, null):Int;
	public var defaultTextFormat (get_defaultTextFormat, set_defaultTextFormat):TextFormat;
	public var displayAsPassword(default, set):Bool;
	public var embedFonts:Bool;
	public var gridFitType:GridFitType;
	public var htmlText (get_htmlText, set_htmlText):String;
	public var length (default, null):Int;
	public var maxChars:Int;
	public var maxScrollH (default, null):Int;
	public var maxScrollV (default, null):Int;
	public var mDownChar:Int;
	public var mFace:String;
	public var mParagraphs:Paragraphs;
	public var mTextHeight:Int;
	public var mTryFreeType:Bool;
	@:isVar public var multiline (default, default):Bool;
	public var numLines (default, null):Int;
	public var restrict:String;

    private var isValid: Bool;

    public var scrollH(get, set):Int;
    private var _scrollH: Int;
    private function get_scrollH ():Int { return _scrollH; }
    private function set_scrollH (value:Int):Int {
        _scrollH = value;
        textElementOffset = getOffsetByScrollValues();
        return value; }

	public var scrollV(get, set):Int;
    private var _scrollV: Int;
    private function get_scrollV ():Int { return _scrollV; }
    private function set_scrollV (value:Int):Int {
        _scrollV = value;
        textElementOffset = getOffsetByScrollValues();
        bottomScrollV = calculateBottomScrollV();
        return value;
    }

    private function get_multiline ():Bool { return multiline; }
    private function set_multiline (value:Bool):Bool { return multiline = value; }



	public var selectable(get, set): Bool;
	private var _selectable: Bool;
	private function get_selectable(): Bool { return _selectable; }
	private function set_selectable(v: Bool): Bool {
	    _selectable = v;
        updateSelectability();
	    return v;
	}

	public var selectionBeginIndex:Int;
	public var selectionEndIndex:Int;
    private var svgSelectionBeginIndex: Int;
    private var svgSelectionEndIndex: Int;

	public var sharpness:Float;
	public var text (get_text, set_text):String;
	public var textColor (get_textColor, set_textColor):Int;
	public var textHeight (get_textHeight, null):Float;
	public var textWidth (get_textWidth, null):Float;
	public var type (get_type, set_type):String;
	@:isVar public var wordWrap (get_wordWrap, set_wordWrap):Bool;
	
	private static var sSelectionOwner:TextField = null;

	private var textElementOffset(get, set):Point;
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
    private var mUserWidth:Float;
    private var mTextSnap: SnapElement;
	private var __graphics:Graphics;
	private var __inputEnabled:Bool;
	private var _defaultTextFormat:TextFormat;
    private var __textChanged:Bool;
    private var __textFormats:Array<TextFormatInstance>;

    private var shouldCaretShowed: Bool;

	public function new () {
		
		super ();

        isValid = false;

		mWidth = 100;
		mHeight = 20;
		mHTMLMode = false;
		multiline = false;
        var graphicsSnap = Lib.snap.group().addClass("graphics");
        snap.append(graphicsSnap);
        __graphics = new Graphics(graphicsSnap);
        __graphics.displayObject = this;

        mTextSnap = Lib.snap.text(0,0, "");
        snap.append(mTextSnap);
		mFace = mDefaultFont;
		mAlign = TextFormatAlign.LEFT;
		mParagraphs = new Paragraphs ();
		svgSelectionBeginIndex = selectionBeginIndex = -1;
		svgSelectionEndIndex = selectionEndIndex = -1;
        numLines = 0;
		scrollH = 0;
		scrollV = 1;
		mType = TextFieldType.DYNAMIC;
		autoSize = TextFieldAutoSize.NONE;
		mTextHeight = 12;
		mMaxHeight = mTextHeight;
		mHTMLText = "";
		mText = "";
		mTextColour = 0x000000;
		tabEnabled = false;
		mTryFreeType = true;
		selectable = true;
		mInsertPos = 0;
		__inputEnabled = false;
		mDownChar = 0;
		mSelectDrag = -1;
		
		mLineInfo = [];
        __textFormats = [];
        defaultTextFormat = new TextFormat ();

		borderColor = 0x000000;
		border = false;
		backgroundColor = 0xffffff;
		background = false;
		gridFitType = GridFitType.PIXEL;
		sharpness = 0;

        caretIndex = 0;
        shouldCaretShowed = true;

        updateSelectability();
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(Event.PASTE, onPaste);
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
			invalidateAndRenderNextWake();
			
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
        var text: TextElement = cast(mTextSnap.node);
        var svg: SVGElement = cast(mTextSnap).paper.node;
        var point = svg.createSVGPoint();
        point.x = inX;
        point.y = inY;
        return text.getCharNumAtPosition(point);
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

    private function getLineIndexForCharIndex(charIdx: Int): Int {
        if (mLineInfo.length < 1) return -1;

        for (l in 0...mLineInfo.length) {
            if (mLineInfo[l].mIndex > charIdx) {
                return l == 0 ? 0 : l - 1;
            }
        }

        return mLineInfo.length - 1;
    }
	
	
	public function getTextFormat (beginIndex:Int = -1, endIndex:Int = -1):TextFormat {
        var format = new TextFormat (mFace, mTextHeight, mTextColour);
        if (beginIndex > 0 && beginIndex < text.length) {

            if (null != __textFormats) {
                var formats = Lambda.array(Lambda.map(__textFormats, function(f) { return f; }));
                formats.reverse();
                for(f in formats) {
                    if (beginIndex >= f.begin && beginIndex <= f.end) {
                        format = f.format;
                        break;
                    }
                }
            }
        }
		return format;
	}

	private function Rebuild () {
		
		if (mHTMLMode) return;

        mLineInfo = [];

        var wrap = mLimitRenderX = (wordWrap && !__inputEnabled) ? Std.int (mUserWidth) : 999999;

        if (null != __textFormats)
            for(f in __textFormats) {
                applyTextFormat(f.format, f.begin, f.end);
            }

        var char_idx = 0;
        for (paragraph in mParagraphs) {
            char_idx = wrapParagraph(paragraph, wrap, char_idx, mSelStart, mSelEnd);
        }

        var textNode = mTextSnap.node;
        var spans = [for (i in 0...textNode.childNodes.length) textNode.childNodes.item(i)];
        for (s in spans) {
            textNode.removeChild(s);
        }

        var svgBuf: StringBuf = new StringBuf();
        var firstParagraph = true;
        numLines = 0;
        for (paragraph in mParagraphs) {
            var firstSpan = true;
            for (span in paragraph.spans) {
                svgBuf.add('<tspan xml:space="preserve" height="' + span.rect.height + 'px" ');
				//Commented yet because WebKit doesn't support it correctly
				//TODO: make it working for webkit
				//svgBuf.add('textLength="' + span.rect.width+ 'px" ');
				if (firstSpan) {
					svgBuf.add('x="' + span.startX + '" dy="' + paragraph.firstLineHeight+ 'px" ');
                    numLines += 1;
				} else if (span.startFromNewLine) {
					svgBuf.add('x="' + span.startX + '" dy="' + span.rect.height+ 'px" ');
                    numLines += 1;
				}

                var styleBuf: StringBuf = new StringBuf();
                if (null != span.format) {
                    if (null != span.format.color) {
                        svgBuf.add('fill="#' + StringTools.hex(span.format.color,6) + '" ');
                    }
                    if (null != span.format.kerning) {
                        svgBuf.add('kerning="' + span.format.kerning + 'px" ');
                    }
                    if (null != span.format.letterSpacing) {
                        svgBuf.add('letter-spacing="' + span.format.letterSpacing + 'px" ');
                    }

                    if (null != span.format.font) {
                        styleBuf.add('font-family:\'${span.format.font}\';');
                    }
                    if (null != span.format.size) {
                        styleBuf.add('font-size:' + span.format.size + 'px;');
                    }
                    if (null != span.format.bold && span.format.bold) {
                        styleBuf.add('font-weight:bold;');
                    }
                    if (null != span.format.bold && span.format.italic) {
                        styleBuf.add('font-style:italic;');
                    }
                    if (null != span.format.underline && span.format.underline) {
                        styleBuf.add('text-decoration:underline;');
                    }
                    if (styleBuf.length > 0) {
                        svgBuf.add("style=\"" + styleBuf.toString() + "\"");
                    }
                }
                svgBuf.add('><![CDATA[');
                svgBuf.add(span.text);
                svgBuf.add(']]></tspan>');
                firstSpan = false;
            }
            firstParagraph = false;
        }

        var textElement: js.html.svg.TextElement = cast(mTextSnap.node);
        mTextSnap.append(Snap.parse(svgBuf.toString()));

        textElement.setAttribute("font-family", Std.string(mFace));
        textElement.setAttribute("font-size", Std.string(mTextHeight)+'px');
        textElement.setAttribute("fill", "#" + StringTools.hex(mTextColour, 6));

            //"textLength": width + "px",
            //"lengthAdjust": "spacingAndGlyphs",
            //"kerning": "0",
            //"letter-spacing": "0px",
            //"word-spacing": "0px"

        var rect = if (null != mText && mText.length > 0) {
            var r: ClientRect = textElement.getBoundingClientRect();
            new Rectangle(r.left, r.top, r.width, r.height);
        } else new Rectangle();

        if (autoSize != TextFieldAutoSize.NONE) {
            mWidth = rect.width;
            mHeight = rect.height;
        }

        mMaxWidth = rect.width;
        mMaxHeight = rect.height;

        updateMaxScrollValues();

        updateClipRect(new Rectangle(x, y, width, height));

        __graphics.clear();
        drawBackgoundAndBorder();

        ensureCaretVisible();
	}

    private function updateMaxScrollValues() {
        //calculate maxScrollV
        maxScrollV = 1;
        if (height < textHeight) {
            var rest = textHeight;
            for (paragraph in mParagraphs) {
                var first = true;
                for (s in paragraph.spans) {
                    if (rest > height && (first || s.startFromNewLine)) {
                        rest -= s.rect.height;
                        maxScrollV += 1;
                        first = false;
                    }
                }
            }
        }

        //calculate maxScrollH
        maxScrollH = if (width < textWidth) Std.int(textWidth-width) else 0;
    }

    private function drawBackgoundAndBorder() {
        if (background) {
            __graphics.lineStyle(0);
            __graphics.beginFill (backgroundColor);
            __graphics.drawRect (0, 0, mWidth-.5, mHeight-.5 );
            __graphics.endFill ();
        } else {
            __graphics.lineStyle(0);
            __graphics.beginFill (0,0);
            __graphics.drawRect (0.5, 0.5, mWidth-.5, mHeight-.5 );
            __graphics.endFill ();
        }

        if (border) {
            __graphics.endFill ();
            __graphics.lineStyle (1, borderColor, 1, true);
            __graphics.drawRect (.5, .5, mWidth-.5, mHeight-.5);
        }
    }

    private function getCaretRect(): Rectangle {
        var textElement: TextElement = cast(mTextSnap.node);
        try {
            if (text.length > 0 && caretIndex >= 0) {
                var extent = textElement.getExtentOfChar(if (caretIndex < text.length) caretIndex else caretIndex-1);
                var x = Std.int(if (caretIndex < text.length) extent.x else extent.x+extent.width-1)+0.5;
                return new Rectangle(x, extent.y, 1, extent.height);
            } else {
                return new Rectangle(0, 0, 1, mTextHeight*1.4);
            }
        } catch(e: Dynamic) {
            return new Rectangle(0, 0, 1, mTextHeight*1.4);
        }
    }

    private function getCaretScrollPosition(): Point {
        var caretRect = getCaretRect();
        var v = getLineByCaretIndex(caretIndex);
        return new Point(caretRect.x, if (v < 0) 1 else v + 1);
    }

	public function RebuildText () {
        if (null == mText) return;

        //trace("Adding text through snap.text: '" + mText + "' font-family:" + mFace + "; font-size: " + mTextHeight + "; color: " + "#" + StringTools.hex(mTextColour, 6));

        var paras = mText.split ("\n");

        // building text in graphics
		mParagraphs = [];
		
		if (!mHTMLMode) {
			var font = FontInstance.CreateSolid (mFace, mTextHeight, mTextColour, 1.0);
			var paras = mText.split ("\n");
            for (paragraph in paras) {
				if (displayAsPassword) paragraph = StringTools.rpad("","*",paragraph.length);
				mParagraphs.push ( cast { align: mAlign, spans: [ { font : font, text: paragraph + if (mText.length > 0) "\n" else '', format: defaultTextFormat, startFromNewLine: true } ] } );
			}
		}
        __textChanged = true;
        Rebuild();
        __textChanged = false;
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
		
		var full_height = Std.int (h);
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
        var width_list = new Array<Int>();
		mLineInfo.push ( { mY0: inY, mIndex: inCharIdx - 1, mX: x_list, mHeight: full_height, mWidth: width_list } );
		
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
            width_list.push(adv);
			
//			if (x >= 0) {
//
//				var font = chr.font;
//
//				if (chr.sel) {
//
//					__graphics.lineStyle ();
//					__graphics.beginFill (0x202060);
//					__graphics.drawRect (x, inY, adv, full_height);
//					__graphics.endFill ();
//
//					if (cache_normal_font == chr.font) {
//
////						font = cache_sel_font;
//
//					} else {
//
////						font = FontInstance.CreateSolid (chr.font.GetFace (), chr.fh, 0xffffff, 1.0);
////						cache_sel_font = font;
////						cache_normal_font = chr.font;
//
//					}
//
//				}
//
////				font.RenderChar (__graphics, chr.chr, x, Std.int(inY + (h - chr.fh)));
//
//			}
			
			x += adv;
			
		}

		x += scrollH;
		return full_height;
		
	}

    private function getRowDimension(row:Array<RowChar>): openfl.geom.Rectangle {
        var h = 0;
        var w = 0;
        var str = '';

        for (chr in row) {
            if (chr.fh > h) {
                h = chr.fh;
            }
            w += chr.adv;
            str += String.fromCharCode(chr.chr);
        }

        if (w > mMaxWidth) {
            mMaxWidth = w;
        }

        var full_height = Std.int (h);

        return new Rectangle(0,0,w,full_height);
    }

    private function cacheRowSize(inRow:Array<RowChar>, inY:Int, inCharIdx:Int, inAlign:TextFormatAlign, inInsert:Int = 0) {
         RenderRow(inRow, inY, inCharIdx, inAlign, inInsert);
    }

    private function wrapParagraph(paragraph: Paragraph, wrap: Int, charIdx: Int, s0: Int, s1: Int): Int {

        var row:Array<RowChar> = [];
        var row_width = 0;
        var last_word_break = 0;
        var last_word_break_width = 0;
        var last_word_char_idx = 0;
        var start_idx = charIdx;
        var tx = 0;

        var newSpans: Array<Span> = [];

        for (span in paragraph.spans) {

            var text = span.text;
            var font: FontInstance = if (null != span.format)
                FontInstance.CreateSolid(
                    if (null != span.format.font) span.format.font else span.font.GetFace(),
                    if (null != span.format.size) Std.int(span.format.size) else span.font.height,
                    if (null != span.format.color) span.format.color else span.font.color,
                    1.0)
            else
                span.font;
            var fh = font.height;

            last_word_break = row.length;
            last_word_break_width = row_width;
            last_word_char_idx = charIdx;

//            if (text.length <= 0) {
//                newSpans.push({ font: font, text: '&nbsp;', format: span.format, startFromNewLine: true, rect: new Rectangle(0,0,0,Math.floor(font.height*1.2))});
//            }

            var prevG = 0;
            for (ch in 0...text.length) {
                var g = text.charCodeAt(ch);
                var adv = font.__getAdvance(g);

                if (g == 32 && prevG != 32) {
                    last_word_break = row.length;
                    last_word_break_width = tx;
                    last_word_char_idx = charIdx;
                }

                if ((tx + adv) > wrap) {
                    if (last_word_break > 0) {
                        var row_end = row.splice (last_word_break, row.length - last_word_break);
                        var head = row.slice(0, last_word_break);
                        newSpans.push({ font: font, text: Lambda.fold(head, function(o,s) {return s + String.fromCharCode(o.chr);}, ''), format: span.format, startFromNewLine: true, rect: getRowDimension(head), startX: 0});
                        row = row_end;
                        tx -= last_word_break_width;
                        start_idx = last_word_char_idx;

                        last_word_break = 0;
                        last_word_break_width = 0;
                        last_word_char_idx = 0;
                    } else {
                        newSpans.push({ font: font, text: Lambda.fold(row, function(o,s) {return s + String.fromCharCode(o.chr);}, ''), format: span.format, startFromNewLine: true, rect: getRowDimension(row), startX: 0});
                        row = [];
                        tx = 0;
                        start_idx = charIdx;
                    }

                }


                row.push ( { font: font, chr: g, x: tx, fh: fh, sel:(charIdx >= s0 && charIdx < s1), adv: adv } );
                tx += adv;
                charIdx++;
                prevG = g;
            }

            if (row.length > 0) {
				var startFromNewLine = if (row.length < text.length) true else span.startFromNewLine;
                newSpans.push({ font: font, text: Lambda.fold(row, function(o,s) {return s + String.fromCharCode(o.chr);}, ''), format: span.format, startFromNewLine: startFromNewLine, rect: getRowDimension(row), startX: 0});
                row = [];
            }
        }

        paragraph.firstLineHeight = 0.0;
        var lineWidth = 0.0;
        var startSpan: Span = null;
        for (s in newSpans) {
            if (s.startFromNewLine && paragraph.firstLineHeight > 0.0) break;
            if (s.rect.height > paragraph.firstLineHeight) paragraph.firstLineHeight = s.rect.height;
            if (paragraph.align == TextFormatAlign.CENTER) {
                if (s.startFromNewLine) {
                    if (startSpan != null) {
                        startSpan.startX = Math.floor((mUserWidth - lineWidth)/2);
                        lineWidth = 0.0;
                    }
                    startSpan = s;
                }
                lineWidth += s.rect.width;
            }
        }
        if (paragraph.align == TextFormatAlign.CENTER && null != startSpan) {
            startSpan.startX = Math.floor((mUserWidth - lineWidth)/2);
        }

        paragraph.spans = newSpans;

        return charIdx;
    }

    private function moveCaretToPrevLine() {
        moveCaretToLine(getLineByCaretIndex(caretIndex)-1);
    }

    private function moveCaretToNextLine() {
        moveCaretToLine(getLineByCaretIndex(caretIndex)+1);
    }

    private function moveCaretToLine(lineIndex) {

        if (lineIndex < 0 || lineIndex > getLineByCaretIndex(999999999)) return;

        var pos = getPositionInLine(caretIndex);
        var begin = getCaretIndexOfFirstCharOfLine(lineIndex);
        var dstCaretIndex = begin + pos;
        var dstLineIndex = getLineByCaretIndex(dstCaretIndex);

        var lastCaretIndex = getCaretIndexOfFirstCharOfLine(999999999);


        if (dstLineIndex != lineIndex) {
            dstCaretIndex = getCaretIndexOfFirstCharOfLine(lineIndex+1);
        }

        if (dstCaretIndex < 0) {
            dstCaretIndex = 0;
        } else if (dstCaretIndex > lastCaretIndex) {
            dstCaretIndex = lastCaretIndex;
        }
        caretIndex = dstCaretIndex;
    }

    private function getCaretIndexOfFirstCharOfLine(lineIndex) {
        var lengthBefore = 0;
        var line = -1;
        for (paragraph in mParagraphs) {
            var first = true;
            for (s in paragraph.spans) {
                if (first || s.startFromNewLine) {
                    line += 1;
                    first = false;
                }
                if (line == lineIndex) {
                    return lengthBefore;
                }
                lengthBefore += s.text.length;
            }
        }
        return lengthBefore;
    }

    private function getPositionInLine(caretIndex: Int): Int {
        var lengthBefore = 0;
        var lengthOfPrevLines = 0;
        for (paragraph in mParagraphs) {
            var first = true;
            for (s in paragraph.spans) {
                if (first || s.startFromNewLine) {
                    lengthOfPrevLines = lengthBefore;
                    first = false;
                }
                if (s.text.length + lengthBefore > caretIndex) {
                    return caretIndex - lengthOfPrevLines;
                }
                lengthBefore += s.text.length;
            }
        }
        return caretIndex;
    }

    private function getLineByCaretIndex(caretIndex: Int): Int {
        var lengthBefore = 0;
        var line = -1;
        for (paragraph in mParagraphs) {
            var first = true;
            for (s in paragraph.spans) {
                if (first || s.startFromNewLine) {
                    line += 1;
                    first = false;
                }
                if (s.text.length + lengthBefore > caretIndex) {
                    return line ;
                }
                lengthBefore += s.text.length;
            }
        }
        return line;
    }

	public function setSelection (beginIndex:Int, endIndex:Int) {
        selectionBeginIndex = beginIndex;
        selectionEndIndex = endIndex;
        invalidateAndRenderNextWake();
	}
	
	
	public function setTextFormat (inFmt:TextFormat, beginIndex:Int = 0, endIndex:Int = 0) {
        if (beginIndex < 0 || endIndex < 0 ) {
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
            __textFormats = [];
            invalidateAndRenderNextWake();
        } else {
            __textFormats.push({format:inFmt, begin:beginIndex, end:endIndex});
        }

		__invalidateBounds ();
		
		return getTextFormat ();
	}

    private function applyTextFormat(format: TextFormat, beginIndex: Int, endIndex: Int) {
        var font = FontInstance.CreateSolid (format.font, Std.int(format.size), format.color, 1.0);
		endIndex -= 1;
        var spanStartCharIndex: Int = 0;
        for (paragraph in mParagraphs) {
            var newSpans: Array<Span> = [];
            for (span in paragraph.spans) {
                var spanEndCharIndex = spanStartCharIndex + span.text.length - 1;
                if (beginIndex <= spanEndCharIndex && beginIndex >= spanStartCharIndex) {
                    var parts = splitStringByInerval(span.text, beginIndex-spanStartCharIndex, Std.int(Math.min(endIndex-spanStartCharIndex, spanEndCharIndex - spanStartCharIndex)));
                    if (null != parts[0] && '' != parts[0]) newSpans.push({ font: span.font, text: parts[0], format: span.format, startFromNewLine: span.startFromNewLine, rect: null, startX: 0});
                    if (null != parts[1] && '' != parts[1]) newSpans.push({ font: font, text: parts[1], format: format, startFromNewLine: false, rect: null, startX: 0});
                    if (null != parts[2] && '' != parts[2]) newSpans.push({ font: span.font, text: parts[2], format: span.format, startFromNewLine: false, rect: null, startX: 0});
                    if (endIndex > spanEndCharIndex) {
                        beginIndex = spanEndCharIndex+1;
                    }
                } else {
                    newSpans.push(span);
                }
                spanStartCharIndex = spanEndCharIndex + 1;
            }
            paragraph.spans = newSpans;
        }
    }

    private function splitStringByInerval(str: String, beginIndex: Int, endIndex: Int): Array<String> {
        return [str.substr(0, beginIndex), str.substr(beginIndex, endIndex-beginIndex+1), str.substr(endIndex+1, str.length - endIndex)];
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
	
	
	override public function __render (inMask:SnapElement = null, clipRect:Rectangle = null, force:Bool = false):Void {
		
        if (!__combinedVisible && !force) return;

        if (!isValid) validate();

		if (_matrixInvalid || _matrixChainInvalid) __validateMatrix ();

        if (__graphics.__render (inMask, __filters, 1, 1)) {
			handleGraphicsUpdated (__graphics);
		}

		if (!mHTMLMode && inMask != null) {
			var m = getSurfaceTransform ();
			//Lib.__drawToSurface (__graphics.__surface, inMask, m, (parent != null ? parent.__combinedAlpha : 1) * alpha, clipRect, (gridFitType != GridFitType.PIXEL));

		} else {
			if (__testFlag (DisplayObject.TRANSFORM_INVALID)) {
				var m = getSurfaceTransform ();
				__setTransform (m);
				__clearFlag (DisplayObject.TRANSFORM_INVALID);
			}
			Lib.__setSurfaceOpacity (snap, alpha);
		}

        var el: js.html.svg.TextElement = cast(mTextSnap.node);
        if (el.textContent.length > 0) {
            if (selectionBeginIndex != svgSelectionBeginIndex || selectionEndIndex != svgSelectionEndIndex) {
                try {
                    if (selectionBeginIndex >= 0) {
                        el.selectSubString(selectionBeginIndex, selectionEndIndex - selectionBeginIndex+1);
                    } else {
                        el.selectSubString(0, 0);
                    }
                } catch (e: Dynamic) {}
                svgSelectionBeginIndex = selectionBeginIndex;
                svgSelectionEndIndex = selectionEndIndex;
            }
        }
        updateClipRect(new Rectangle(x, y, width, height));
    }

    private var caretTimer: Timer;
    private function onFocus(e: Dynamic) {
        if (e.type == FocusEvent.FOCUS_IN) {
            caretTimer = new Timer(400);
            caretTimer.run = showCaret;
        } else {
            if (null != caretTimer) {
                hideCaret();
                caretTimer.stop();
                caretTimer = null;
            }
        }
    }

    private function showCaret() {
        if (__inputEnabled && stage.focus == this && shouldCaretShowed) {
            var rect = getCaretRect();
			var offset = textElementOffset;
            __graphics.clear();
            drawBackgoundAndBorder();
            if (rect.x <= mWidth - offset.x) {
                __graphics.lineStyle(0.5, 0, 1, true);
                __graphics.moveTo(rect.x + offset.x, rect.y + offset.y);
                __graphics.lineTo(rect.x + offset.x, rect.bottom + offset.y);
                __graphics.flush();
            }
            caretTimer.run = hideCaret;
        }
    }

    private function hideCaret() {
        __graphics.clear();
        drawBackgoundAndBorder();
        caretTimer.run = showCaret;
    }


    private function onKeyDown(e: Dynamic) {
        var evt: openfl.events.KeyboardEvent = e;
        if ((null == selectionInteractionStartIndex || selectionInteractionStartIndex < 0) && evt.shiftKey) {
            selectionInteractionStartIndex = caretIndex;
        }

        if (evt.keyCode == Keyboard.LEFT && caretIndex > 0) {
            caretIndex -= 1;
        } else if (evt.keyCode == Keyboard.RIGHT && caretIndex < text.length) {
            caretIndex += 1;
        } else if (evt.keyCode == Keyboard.DOWN) {
            moveCaretToNextLine();
        } else if (evt.keyCode == Keyboard.UP) {
            moveCaretToPrevLine();
        } else if (evt.keyCode == Keyboard.BACKSPACE && caretIndex > 0) {
            if (isSelected()) {
                removeSelectedText();
            } else {
                removeText(caretIndex-1,caretIndex-1);
            }
            clearSelection();
        } else if (evt.keyCode == Keyboard.DELETE && caretIndex < text.length) {
            if (isSelected()) {
                removeSelectedText();
            } else {
                removeText(caretIndex, caretIndex);
            }
            clearSelection();
        } else if (evt.keyCode == Keyboard.ENTER) {
            insertText("\n", caretIndex);
            caretIndex += 1;
        }

        if (!evt.shiftKey && !evt.ctrlKey && !evt.altKey) {
            clearSelection();
            selectionInteractionStartIndex = -1;
        } else if (evt.shiftKey){
            adjustSelectionByCaret(caretIndex);
        }

        e.stopPropagation();
    }

    private var selectionInteractionStartIndex: Int;

    private function adjustSelectionByCaret(caretIndex: Int) {
        if (caretIndex > selectionInteractionStartIndex) {
            selectionBeginIndex = selectionInteractionStartIndex;
            selectionEndIndex = caretIndex - 1;
        } else if (caretIndex < selectionInteractionStartIndex) {
            selectionBeginIndex = caretIndex;
            selectionEndIndex = selectionInteractionStartIndex-1;
        } else {
            clearSelection();
        }
    }

    private function isSelected() {
        return selectionBeginIndex >=0 && selectionEndIndex >= 0 && selectionEndIndex >= selectionBeginIndex;
    }

    private function clearSelection() {
        selectionBeginIndex = -1;
        selectionEndIndex = -1;
    }

    private function removeSelectedText() {
        if (isSelected()) {
            removeText(selectionBeginIndex, selectionEndIndex);
        }
    }

    private function insertText(s: String, index: Int) {
        dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, false, false, s));
        if (null != __textFormats) for(f in __textFormats) {
            if (index < f.begin) {
                f.begin += s.length;
                f.end += s.length;
            } else if (index >= f.begin && index <= f.end) {
                f.end += s.length;
            }
        }
        text = text.substring(0,index) + s + text.substring(index,text.length);
        dispatchEvent(new Event(Event.CHANGE, true));
    }

    private function removeText(beginIndex: Int, endIndex: Int) {
        var length = endIndex - beginIndex + 1;

        if (null != __textFormats) for(f in __textFormats) {
            if (f.begin > endIndex) {
                f.begin -= length;
                f.end -= length;
            } else if (f.end < beginIndex) {
                //Do nothing
            } else if (f.begin <= beginIndex && f.end >= endIndex) {
                f.end -= length;
            } else if (f.begin > beginIndex && f.end >= endIndex) {
                f.begin -= f.begin - beginIndex + 1;
                f.end -= length;
            } else if (f.begin <= beginIndex && f.end < endIndex) {
                f.end -= f.end - beginIndex + 1;
            }
        }

        if (text.length > 1) {
            text = text.substr(0,beginIndex) + text.substr(endIndex+1,text.length-endIndex);
            caretIndex = beginIndex;
        } else {
            text = '';
            caretIndex = 0;
        }
        dispatchEvent(new Event(Event.CHANGE, true));
    }


    private function onKeyPress(e: Dynamic) {
        if (null != e.charCode && 31 < e.charCode && !e.ctrlKey && !e.altKey && !e.controlKey && !e.commandKey) {
            insertText(String.fromCharCode(e.charCode), caretIndex);
            caretIndex += if (caretIndex < 0) 2 else 1;
        }
        e.stopPropagation();
    }

    private function onMouseDown(e: Dynamic) {
        if (selectable || stage.focus == this) {
            var textElement: TextElement = cast(mTextSnap.node);
            caretIndex = getCharIndexAtPoint(e.localX - textElementOffset.x, e.localY - textElementOffset.y);
            if (null != text && text.length > 0 && text.length > caretIndex) {
                try {
                    var extent = textElement.getExtentOfChar(caretIndex);
                    if (e.localX - textElementOffset.x - extent.x > extent.width/2) {
                        caretIndex += 1;
                    }
                } catch(e: Dynamic) {}
            }

            if (e.localX > textElement.clientWidth) {
                caretIndex = text.length;
            }
        }

        if (selectable) {
            selectionBeginIndex = caretIndex;
            selectionEndIndex = caretIndex-1;
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        shouldCaretShowed = false;
    }



    private function onMouseUp(e: Dynamic) {
        removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        if (e.target == this && stage.focus == this) {
            shouldCaretShowed = true;
            caretIndex = getCharIndexAtPoint(e.localX - textElementOffset.x, e.localY - textElementOffset.y);
            var textElement: TextElement = cast(mTextSnap.node);
            try {
                var extent = textElement.getExtentOfChar(caretIndex);
                if (e.localX - textElementOffset.x - extent.x > extent.width/2) {
                    caretIndex += 1;
                }
            } catch(e: Dynamic) {}

            if (e.localX > textElement.clientWidth) {
                caretIndex = text.length;
            }
        } else {
            shouldCaretShowed = false;
        }
    }

    private function onMouseMove(e: Dynamic) {
        var index: Int = getCharIndexAtPoint(e.localX, e.localY);
        if (index > caretIndex) {
            svgSelectionBeginIndex = selectionBeginIndex = caretIndex;
            svgSelectionEndIndex = selectionEndIndex = index-1;
        } else if (index < selectionBeginIndex && index < selectionEndIndex) {
            svgSelectionBeginIndex = selectionBeginIndex = index;
            svgSelectionEndIndex = selectionEndIndex = caretIndex-1;
        }
    }

    private function onPaste(e: Dynamic) {
        insertText(e.text, caretIndex);
        caretIndex += e.text.length + (if (caretIndex < 0) 1 else 0);
    }


    // Getters & Setters
	
	
	private function get_autoSize ():TextFieldAutoSize {
		
		return autoSize;
		
	}
	
	
	private function set_autoSize (inAutoSize:TextFieldAutoSize):TextFieldAutoSize {
		autoSize = inAutoSize;
		invalidateAndRenderNextWake();
		return inAutoSize;
	}
	
	
	private function set_background (inBack:Bool):Bool {
		background = inBack;
		invalidateAndRenderNextWake();
		return inBack;
	}
	
	
	private function set_backgroundColor (inCol:Int):Int {
		backgroundColor = inCol;
		invalidateAndRenderNextWake();
		return inCol;
		
	}
	
	
	private function set_border (inBorder:Bool):Bool {
		border = inBorder;
		invalidateAndRenderNextWake();
		return inBorder;
	}
	
	
	private function set_borderColor (inBorderCol:Int):Int {
		borderColor = inBorderCol;
        invalidateAndRenderNextWake();
		return inBorderCol;
	}
	
	
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
		
		return Math.max (mHeight,getBounds(this.stage).height);
		
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
			invalidateAndRenderNextWake();
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

	public function get_text ():String {
		
		if (mHTMLMode) {
			
			ConvertHTMLToText (false);
			
		}
		
		return mText;
		
	}
	
	
	public function set_text (inText:String):String {
        if (mText == inText) return inText;

		mText = inText;
        if (null == mText) mText = '';

        if (!multiline) {
            mText = StringTools.replace(mText, '\n', '');
        }

		//mHTMLText = inText;
		mHTMLMode = false;
		invalidateAndRenderNextWake();
		__invalidateBounds ();
		dispatchEvent(new Event(Event.CHANGE));

        return mText;
	}
	
	
	public function get_textColor ():Int { return mTextColour; }
	public function set_textColor (inCol:Int):Int {
		
		mTextColour = inCol;
		invalidateAndRenderNextWake();
		return inCol;
		
	}
	
	
	public function get_textWidth ():Float {
        if (!isValid) validate();
        return mMaxWidth;
    }
	public function get_textHeight ():Float {
        if (!isValid) validate();
        return mMaxHeight;
    }
	
	
    private inline function updateSelectability() {
        mTextSnap.attr({ style: if (selectable) '' else '-webkit-user-select:none; -moz-user-select:none; -ms-user-select:none; user-select:none;' });
    }

	public function get_type ():String { return mType; }
	public function set_type (inType:String):String {
		
		mType = inType;
		__inputEnabled = (mType == TextFieldType.INPUT);
		updateSelectability();
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

        if (__inputEnabled) {
            addEventListener(FocusEvent.FOCUS_IN, onFocus);
            addEventListener(FocusEvent.FOCUS_OUT, onFocus);
            addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            addEventListener(KeyboardEvent.KEY_PRESS, onKeyPress);
        } else {
            removeEventListener(FocusEvent.FOCUS_IN, onFocus);
            removeEventListener(FocusEvent.FOCUS_OUT, onFocus);
            removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            removeEventListener(KeyboardEvent.KEY_PRESS, onKeyPress);
        }
		
		invalidateAndRenderNextWake();
		
		return inType;
		
	}
	
	
	override public function get_width ():Float {
		if (!isValid) validate();
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
			mUserWidth = mWidth = inValue;
            invalidateAndRenderNextWake();
		}
		
		return mWidth;
		
	}
	
	
	public function get_wordWrap ():Bool {
		return wordWrap;
	}

	public function set_wordWrap (inWordWrap:Bool):Bool {
		wordWrap = inWordWrap;
		invalidateAndRenderNextWake();
		return wordWrap;
		
	}

	public function get_caretIndex(): Int { return _caretIndex;	}
	public function set_caretIndex(v: Int): Int {
		_caretIndex = v;
        ensureCaretVisible();
		return v;
	}

    private function getOffsetByScrollValues(): Point {
        return new Point(-scrollH, -getOffsetByLineIndex(scrollV));
    }

    private function ensureCaretVisible() {
        var curPos = getCaretScrollPosition();
        var y = 0;
        if (curPos.x < scrollH) scrollH = Std.int(curPos.x);
        else if (curPos.y < scrollV) scrollV = Std.int(curPos.y);
        else if (curPos.x > scrollH + width) scrollH = Std.int(width - curPos.x);
        else if (curPos.y >= bottomScrollV) scrollV += Std.int(curPos.y - bottomScrollV);
    }

    private function getOffsetByLineIndex(index: Int): Int {
        var offset = 0.0;
        for (paragraph in mParagraphs) {
            var first = true;
            for (s in paragraph.spans) {
                if (first || s.startFromNewLine) {
                    index -= 1;
                    if (index <= 0) {
                        return Std.int(offset);
                    }
                    offset += s.rect.height;
                    first = false;
                }
            }
        }
        return Std.int(offset);
    }

    private function calculateBottomScrollV(): Int {
        if (scrollV <= 0) return numLines;
        var skipLines = scrollV - 1;
        var index = 0;
        var h = height;
        for (paragraph in mParagraphs) {
            var first = true;
            for (s in paragraph.spans) {
                if (first || s.startFromNewLine) {
                    index += 1;
                    if (skipLines <= 0) {
                        h -= s.rect.height;
                    } else {
                        skipLines -= 1;
                    }
                    if (h <= 0) return index;
                }
            }
        }
        return index;
    }

	private function get_textElementOffset(): Point {
		var textElement: js.html.svg.TextElement = cast(mTextSnap.node);
		var xStr = textElement.getAttribute("offset-x");
		var yStr = textElement.getAttribute("offset-y");
		return new Point(if (null == xStr) 0.0 else Std.parseFloat(xStr), if (null == xStr) 0.0 else Std.parseFloat(yStr));
	}

	private function set_textElementOffset(v: Point): Point {
		var textElement: js.html.svg.TextElement = cast(mTextSnap.node);
		textElement.setAttribute("offset-x", Std.string(v.x));
		textElement.setAttribute("offset-y", Std.string(v.y));
		textElement.setAttribute("transform", 'matrix(1,0,0,1,${v.x},${v.y})');
		return v;
	}

	private function set_displayAsPassword(v: Bool): Bool {
		displayAsPassword = v;
		invalidateAndRenderNextWake();
		return v;
	}

    public function invalidate() {
        isValid = false;
    }

    public inline function validate() {
        if (isValid) return;
        isValid = true;
        RebuildText();
    }

    private inline function invalidateAndRenderNextWake() {
        invalidate();
        renderNextWake();
    }
}


enum FontInstanceMode {
	fimSolid;
}


class FontInstance {
	
	
	public var height (get_height, null):Int;
    public var color (get_color, null):Int;
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

    private function get_color ():Int {
        return mColour;
    }

}

typedef Span = {
	var font: FontInstance;
	var text: String;
    var format: TextFormat;
    var startFromNewLine: Bool;
    var startX: Int;
    var rect: Rectangle;
}


typedef Paragraph = {
	var align:TextFormatAlign;
	var spans: Array<Span>;
    var firstLineHeight: Float;
}

typedef Paragraphs = Array<Paragraph>;

typedef TextFormatInstance = {
    var format: TextFormat;
    var begin: Int;
    var end: Int;
}


typedef LineInfo = {
	var mY0:Int;
	var mIndex:Int;
	var mX:Array<Int>;
    var mWidth:Array<Int>;
    var mHeight: Int;
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