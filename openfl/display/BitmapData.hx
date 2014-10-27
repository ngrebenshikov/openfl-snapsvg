package openfl.display;


import js.html.Image;
import openfl.display.BlendMode;
import openfl.display.IBitmapDrawable;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.errors.IOError;
import openfl.events.Event;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Uuid;
import openfl.Lib;
import haxe.xml.Check;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;
import js.html.ImageElement;
import js.html.Uint8ClampedArray;
import js.Browser;
import openfl.gl.GLTexture;


@:autoBuild(openfl.Assets.embedBitmap())
class BitmapData implements IBitmapDrawable {
	
	
	public var height (get_height, null):Int;
	public var rect:Rectangle;
	public var transparent (get_transparent, null):Bool;
	public var width (get_width, null):Int;
	
	public var __imageData:ImageData;
	public var __glTexture:GLTexture;
	public var __referenceCount:Int;
	
	private var __assignedBitmaps:Int;
	private var __copyPixelList:Array<CopyPixelAtom>;
	private var __imageDataChanged:Bool;
	private var __initColor:Int;
	private var __lease:ImageDataLease;
	private var __leaseNum:Int;
	private var __locked:Bool;
	private var __transparent:Bool;
	private var __transparentFiller:CanvasElement;
	private var ___id:String;
	private var ___textureBuffer:CanvasElement;

    public var __sourceCanvas: CanvasElement;
    public var __sourceImage: Image;
	
	
	public function new (width:Int, height:Int, transparent:Bool = true, inFillColor:Int = 0xFFFFFFFF) {
		
		__locked = false;
		__referenceCount = 0;
		__leaseNum = 0;
		__lease = new ImageDataLease ();
		__buildLease ();
		
		___textureBuffer = cast Browser.document.createElement ('canvas');
		___textureBuffer.width = width;
		___textureBuffer.height = height;
        __sourceCanvas = ___textureBuffer;

		___id = Uuid.uuid ();
        //TODO: uncomment
		//Lib.__setSurfaceId (___textureBuffer, ___id);
		
		__transparent = transparent;
		rect = new Rectangle (0, 0, width, height);
		
		if (__transparent) {
			
			__transparentFiller = cast Browser.document.createElement ('canvas');
			__transparentFiller.width = width;
			__transparentFiller.height = height;
			
			var ctx = __transparentFiller.getContext ('2d');
			ctx.fillStyle = 'rgba(0,0,0,0);';
			ctx.fill();
			
		}

		if (inFillColor != null && width > 0 && height > 0) {
			
			if (!__transparent) inFillColor |= 0xFF000000;
			
			__initColor = inFillColor;
			__fillRect(rect, inFillColor);
			
		}
		
	}
	
	
	public function applyFilter (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):Void {
		
		if (sourceBitmapData == this && sourceRect.x == destPoint.x && sourceRect.y == destPoint.y) {
			
			filter.__applyFilter (handle (), sourceRect);
			
		} else {
			
			var bitmapData = new BitmapData (Std.int (sourceRect.width), Std.int (sourceRect.height));
			bitmapData.copyPixels (sourceBitmapData, sourceRect, new Point());
			filter.__applyFilter (bitmapData.handle ());
			
			copyPixels (bitmapData, bitmapData.rect, destPoint);
			
		}
		
	}
	
	
	public function clear (color:Int):Void {
		
		fillRect (rect, color);
		
	}
	
	
	private function clipRect (r:Rectangle):Rectangle {
		
		if (r.x < 0) {
			
			r.width -= -r.x;
			r.x = 0;
			
			if (r.x + r.width <= 0) return null;
			
		}
		
		if (r.y < 0) {
			
			r.height -= -r.y;
			r.y = 0;
			
			if (r.y + r.height <= 0) return null;
			
		}
		
		if (r.x + r.width >= this.width) {
			
			r.width -= r.x + r.width - this.width;
			
			if (r.width <= 0) return null;
			
		}
		
		if (r.y + r.height >= this.height) {
			
			r.height -= r.y + r.height - this.height;
			
			if (r.height <= 0) return null;
			
		}
		
		return r;
		
	}
	
	
	public function clone ():BitmapData {
		
		var bitmapData = new BitmapData (width, height, __transparent);
		var rect = new Rectangle (0, 0, width, height);
		
		bitmapData.setPixels (rect, getPixels(rect));
		bitmapData.__buildLease ();
		
		return bitmapData;
		
	}
	
	
	public function colorTransform (rect:Rectangle, colorTransform:ColorTransform) {
		
		if (rect == null) return;
		rect = clipRect (rect);
		
		if (!__locked) {
			
			__buildLease ();
			var ctx:CanvasRenderingContext2D = handle ().getContext ('2d');
			
			var imagedata = ctx.getImageData (rect.x, rect.y, rect.width, rect.height);
			var offsetX:Int;
			
			for (i in 0...imagedata.data.length >> 2) {
				
				offsetX = i * 4;
				imagedata.data[offsetX] = Std.int ((imagedata.data[offsetX] * colorTransform.redMultiplier) + colorTransform.redOffset);
				imagedata.data[offsetX + 1] = Std.int ((imagedata.data[offsetX + 1] * colorTransform.greenMultiplier) + colorTransform.greenOffset);
				imagedata.data[offsetX + 2] = Std.int ((imagedata.data[offsetX + 2] * colorTransform.blueMultiplier) + colorTransform.blueOffset);
				imagedata.data[offsetX + 3] = Std.int ((imagedata.data[offsetX + 3] * colorTransform.alphaMultiplier) + colorTransform.alphaOffset);
				
			}
			
			ctx.putImageData (imagedata, rect.x, rect.y);
			
		} else {
			
			var s = 4 * (Math.round (rect.x) + (Math.round (rect.y) * __imageData.width));
			var offsetY:Int;
			var offsetX:Int;
			
			for (i in 0...Math.round (rect.height)) {
				
				offsetY = (i * __imageData.width);
				
				for (j in 0...Math.round (rect.width)) {
					
					offsetX = 4 * (j + offsetY);
					__imageData.data[s + offsetX] = Std.int ((__imageData.data[s + offsetX] * colorTransform.redMultiplier) + colorTransform.redOffset);
					__imageData.data[s + offsetX + 1] = Std.int ((__imageData.data[s + offsetX + 1] * colorTransform.greenMultiplier) + colorTransform.greenOffset);
					__imageData.data[s + offsetX + 2] = Std.int ((__imageData.data[s + offsetX + 2] * colorTransform.blueMultiplier) + colorTransform.blueOffset);
					__imageData.data[s + offsetX + 3] = Std.int ((__imageData.data[s + offsetX + 3] * colorTransform.alphaMultiplier) + colorTransform.alphaOffset);
					
				}
				
			}
			
			__imageDataChanged = true;
			
		}
		
	}
	
	
	public function compare (inBitmapTexture:BitmapData):Int {
		
		throw "bitmapData.compare is currently not supported for HTML5";
		return 0x00000000;
		
	}
	
	
	public function copyChannel (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, sourceChannel:Int, destChannel:Int):Void {
		
		rect = clipRect (rect);
		if (rect == null) return;
		
		if (destChannel == BitmapDataChannel.ALPHA && !__transparent) return;
		if (sourceBitmapData.handle () == null || ___textureBuffer == null || sourceRect.width <= 0 || sourceRect.height <= 0 ) return;
		if (sourceRect.x + sourceRect.width > sourceBitmapData.handle ().width) sourceRect.width = sourceBitmapData.handle ().width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceBitmapData.handle ().height) sourceRect.height = sourceBitmapData.handle ().height - sourceRect.y;
		
		var doChannelCopy = function (imageData:ImageData) {
			
			var srcCtx:CanvasRenderingContext2D = sourceBitmapData.handle ().getContext ('2d');
			var srcImageData = srcCtx.getImageData (sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
			
			var destIdx = -1;
			
			if (destChannel == BitmapDataChannel.ALPHA) { 
				
				destIdx = 3;
				
			} else if (destChannel == BitmapDataChannel.BLUE) {
				
				destIdx = 2;
				
			} else if (destChannel == BitmapDataChannel.GREEN) {
				
				destIdx = 1;
				
			} else if (destChannel == BitmapDataChannel.RED) {
				
				destIdx = 0;
				
			} else {
				
				throw "Invalid destination BitmapDataChannel passed to BitmapData::copyChannel.";
				
			}
			
			var pos = 4 * (Math.round (destPoint.x) + (Math.round (destPoint.y) * imageData.width)) + destIdx;
			var boundR = Math.round (4 * (destPoint.x + sourceRect.width));
			
			var setPos = function (val:Int) {
				
				if ((pos % (imageData.width * 4)) > boundR - 1) {
					
					pos += imageData.width * 4 - boundR;
					
				}
				
				imageData.data[pos] = val;
				pos += 4;
				
			}
			
			var srcIdx = -1;
			
			if (sourceChannel == BitmapDataChannel.ALPHA) {
				
				srcIdx = 3;
				
			} else if (sourceChannel == BitmapDataChannel.BLUE) {
				
				srcIdx = 2;
				
			} else if (sourceChannel == BitmapDataChannel.GREEN) {
				
				srcIdx = 1;
				
			} else if (sourceChannel == BitmapDataChannel.RED) {
				
				srcIdx = 0;
				
			} else {
				
				throw "Invalid source BitmapDataChannel passed to BitmapData::copyChannel.";
				
			}
			
			while (srcIdx < srcImageData.data.length) {
				
				setPos (srcImageData.data[srcIdx]);
				srcIdx += 4;
				
			}
			
		}
		
		if (!__locked) {
			
			__buildLease ();
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imageData = ctx.getImageData (0, 0, width, height);
			
			doChannelCopy (imageData);
			ctx.putImageData (imageData, 0, 0);
			
		} else {
			
			doChannelCopy (__imageData);
			__imageDataChanged = true;
			
		}
		
	}
	
	
	public function copyPixels (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Bool = false):Void {
		
		if (sourceBitmapData.handle () == null || ___textureBuffer == null || sourceBitmapData.handle ().width == 0 || sourceBitmapData.handle ().height == 0 || sourceRect.width <= 0 || sourceRect.height <= 0 ) return;
		if (sourceRect.x + sourceRect.width > sourceBitmapData.handle ().width) sourceRect.width = sourceBitmapData.handle ().width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceBitmapData.handle ().height) sourceRect.height = sourceBitmapData.handle ().height - sourceRect.y;
		
		if (alphaBitmapData != null && alphaBitmapData.__transparent) {
			
			if (alphaPoint == null) alphaPoint = new Point ();
			
			var bitmapData = new BitmapData (sourceBitmapData.width, sourceBitmapData.height, true);
			bitmapData.copyPixels (sourceBitmapData, sourceRect, new Point (sourceRect.x, sourceRect.y));
			bitmapData.copyChannel (alphaBitmapData, new Rectangle (alphaPoint.x, alphaPoint.y, sourceRect.width, sourceRect.height), new Point (sourceRect.x, sourceRect.y), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			
			sourceBitmapData = bitmapData;
			
		}
		
		if (!__locked) {
			
			__buildLease ();
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			
			if (!mergeAlpha) {
				
				if (__transparent && sourceBitmapData.__transparent) {
					
					var trpCtx:CanvasRenderingContext2D = sourceBitmapData.__transparentFiller.getContext ('2d');
					var trpData = trpCtx.getImageData (sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
					ctx.putImageData (trpData, destPoint.x, destPoint.y);
					
				}
				
			}
			
			ctx.drawImage (sourceBitmapData.handle (), sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, destPoint.x, destPoint.y, sourceRect.width, sourceRect.height);
			
		} else {
			
			//var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			//ctx.putImageData (sourceBitmapData.___textureBuffer.getContext ('2d').getImageData (sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height), destPoint.x, destPoint.y);
			
			
			//var offsetX = Std.int (destPoint.x - sourceRect.x);
			//var offsetY = Std.int (destPoint.y - sourceRect.y);
			//
			//var wasLocked = sourceBitmapData.__locked;
			//if (!wasLocked) sourceBitmapData.lock();
			//
			//var sourceRectX = Std.int (sourceRect.x);
			//var sourceRectY = Std.int (sourceRect.y);
			//var sourceRectWidth = Std.int (sourceRect.width);
			//var sourceRectHeight = Std.int (sourceRect.height);
			//var targetData = __imageData.data;
			//var sourceData = sourceBitmapData.__imageData.data;
			//var targetWidth = width;
			//var sourceWidth = sourceBitmapData.width;
			//
			//if (sourceBitmapData.__imageData != null) {
				//
				//for (sourceX in sourceRectX...sourceRectWidth + 1) {
					//
					//for (sourceY in sourceRectY...sourceRectHeight + 1) {
						//
						//var sourceOffset = ((sourceX * sourceWidth) * 4 + sourceX * 4);
						//var targetOffset = (((sourceX + offsetX) * targetWidth) * 4 + (sourceX + offsetX) * 4);
						//
						//targetData[targetOffset] = sourceData[sourceOffset];
						//targetData[targetOffset+1] = sourceData[sourceOffset+1];
						//targetData[targetOffset+2] = sourceData[sourceOffset+2];
						//targetData[targetOffset+3] = sourceData[sourceOffset+3];
						//
					//}
					//
				//}
				//
			//}
			//
			//if (!wasLocked) sourceBitmapData.unlock();
			
			//
			//
			//
			//__imageData.data[offset] = (color & 0x00FF0000) >>> 16;
			//__imageData.data[offset + 1] = (color & 0x0000FF00) >>> 8;
			//__imageData.data[offset + 2] = (color & 0x000000FF);
			//
			//if (__transparent) {
				//
				//__imageData.data[offset + 3] = (color & 0xFF000000) >>> 24;
				//
			//} else {
				//
				//__imageData.data[offset + 3] = (0xFF);
				//
			//}
			//
			//__imageDataChanged = true;
			//
			__copyPixelList[__copyPixelList.length] = { handle: sourceBitmapData.handle (), transparentFiller: (mergeAlpha ? null : sourceBitmapData.__transparentFiller), sourceX: sourceRect.x, sourceY: sourceRect.y, sourceWidth: sourceRect.width, sourceHeight: sourceRect.height, destX: destPoint.x, destY: destPoint.y };
			
		}
		
	}
	
	
	public function destroy ():Void {
		
		___textureBuffer = null;
		
	}
	
	
	public function dispose ():Void {
		
		__clearCanvas ();
		___textureBuffer = null;
		__leaseNum = 0;
		__lease = null;
		__imageData = null;
		
	}
	
	
	public function draw (source:IBitmapDrawable, matrix:Matrix = null, inColorTransform:ColorTransform = null, blendMode:BlendMode = null, clipRect:Rectangle = null, smoothing:Bool = false):Void {
		
		__buildLease ();
		source.drawToSurface (handle (), matrix, inColorTransform, blendMode, clipRect, smoothing);
		
		if (inColorTransform != null) {
			
			var rect = new Rectangle ();
			var object:DisplayObject = cast source;
			
			rect.x = matrix != null ? matrix.tx : 0;
			rect.y = matrix != null ? matrix.ty : 0;
			
			try {
				
				rect.width = Reflect.getProperty (source, "width");
				rect.height = Reflect.getProperty (source, "height");
				
			} catch(e:Dynamic) {
				
				rect.width = handle ().width;
				rect.height = handle ().height;
				
			}
			
			this.colorTransform (rect, inColorTransform);
			
		}
		
	}
	
	
	public function drawToSurface (inSurface:Dynamic, matrix:Matrix, inColorTransform:ColorTransform, blendMode:BlendMode, clipRect:Rectangle, smoothing:Bool):Void {
		
		__buildLease ();
		var ctx:CanvasRenderingContext2D = inSurface.getContext ('2d');
		if ( blendMode == BlendMode.ADD )
		{
			ctx.globalCompositeOperation = "lighter";
		}
		if (matrix != null) {
			
			ctx.save ();
			
			if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1) {
				
				ctx.translate (matrix.tx, matrix.ty);
				
			} else {
				
				Lib.__setImageSmoothing (ctx, smoothing);
				ctx.setTransform (matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
				
			}
			
			ctx.drawImage (handle (), 0, 0);
			ctx.restore();
			
		} else {
			
			ctx.drawImage (handle (), 0, 0);
			
		}
		
		if (inColorTransform != null) {
			
			this.colorTransform (new Rectangle(0, 0, handle ().width, handle ().height), inColorTransform);
			
		}
		if ( blendMode == BlendMode.ADD )
		{
			ctx.globalCompositeOperation = "source-over";
		}
		
	}
	
	
	public function fillRect (rect:Rectangle, color:Int):Void {
		
		if (rect == null) return;
		if (rect.width <= 0 || rect.height <= 0) return;
		
		if (rect.x == 0 && rect.y == 0 && rect.width == ___textureBuffer.width && rect.height == ___textureBuffer.height) {
			
			if (__transparent) {
				
				if ((color >>> 24 == 0) || color == __initColor) {
					
					return __clearCanvas ();
					
				}
				
			} else {
				
				if ((color | 0xFF000000) == (__initColor | 0xFF000000)) {
					
					return __clearCanvas ();
					
				}
				
			}
			
		}
		
		return __fillRect (rect, color);
		
	}
	
	
	public function floodFill (x:Int, y:Int, color:Int):Void {
		
		var wasLocked = __locked;
		if (!__locked) lock ();
		
		var queue = new Array<Point> ();
		queue.push (new Point (x, y));
		
		var old = getPixel32 (x, y);
		var iterations = 0;
		
		var search = new Array ();
		
		for (i in 0...width + 1) {
			
			var column = new Array ();
			
			for (i in 0...height + 1) {
				
				column.push (false);
				
			}
			
			search.push (column);
			
		}
		
		var currPoint, newPoint;
		
		while (queue.length > 0) {
			
			currPoint = queue.shift ();
			++iterations;
			
			var x = Std.int (currPoint.x);
			var y = Std.int (currPoint.y);
			
			if (x < 0 || x >= width) continue;
			if (y < 0 || y >= height) continue;
			
			search[x][y] = true;
			
			if (getPixel32 (x, y) == old) {
				
				setPixel32 (x, y, color);
				
				if (!search[x + 1][y]) {
					queue.push (new Point (x + 1, y));
				} 
				if (!search[x][y + 1]) {
					queue.push (new Point (x, y + 1));
				} 
				if (x > 0 && !search[x - 1][y]) {
					queue.push (new Point (x - 1, y));
				} 
				if (y > 0 && !search[x][y - 1]) {
					queue.push (new Point (x, y - 1));
				}
			}
		}
		
		if (!wasLocked) unlock ();
		
   }
	
	
	public function getColorBoundsRect (mask:Int, color:Int, findColor:Bool = true):Rectangle {
		
		var me = this;
		
		var doGetColorBoundsRect = function (data:Uint8ClampedArray) {
			
			var minX = me.width, maxX = 0, minY = me.height, maxY = 0, i = 0;
			
			while (i < data.length) {
				
				var value = me.getInt32(i, data);
				
				if (findColor) {
					
					if ((value & mask) == color) {
						
						var x = Math.round ((i % (me.width * 4)) / 4);
						var y = Math.round (i / (me.width * 4));
						
						if (x < minX) minX = x;
						if (x > maxX) maxX = x;
						if (y < minY) minY = y;
						if (y > maxY) maxY = y;
						
					}
					
				} else {
					
					if ((value & mask) != color) {
						
						var x = Math.round ((i % (me.width * 4)) / 4);
						var y = Math.round (i / (me.width * 4));
						
						if (x < minX) minX = x;
						if (x > maxX) maxX = x;
						if (y < minY) minY = y;
						if (y > maxY) maxY = y;
						
					}
					
				}
				
				i += 4;
				
			}
			
			if (minX < maxX && minY < maxY) {
				
				return new Rectangle (minX, minY, maxX - minX + 1 /* +1 - bug? */, maxY - minY);
				
			} else {
				
				return new Rectangle (0, 0, me.width, me.height);
				
			}
			
		}
		
		if (!__locked) {
			
			var ctx = ___textureBuffer.getContext ('2d');
			var imageData = ctx.getImageData (0, 0, width, height);
			
			return doGetColorBoundsRect (imageData.data);
			
		} else {
			
			return doGetColorBoundsRect (__imageData.data);
			
		}
		
	}
	
	
	private function getInt32 (offset:Int, data:Uint8ClampedArray) {
		
		return (__transparent ? data[offset + 3] : 0xFF) << 24 | data[offset] << 16 | data[offset + 1] << 8 | data[offset + 2]; 
		
		// code to deal with 31-bit ints.
		
		//var b5, b6, b7, b8, pow = Math.pow;
		//
		//b5 = if (!__transparent) 0xFF; else data[offset + 3] & 0xFF;
		//b6 = data[offset] & 0xFF;
		//b7 = data[offset + 1] & 0xFF;
		//b8 = data[offset + 2] & 0xFF;
		//
		//return untyped {
			//
			//parseInt(((b5 >> 7) * pow(2, 31)).toString(2), 2) + parseInt((((b5 & 0x7F) << 24) |(b6 << 16) |(b7 << 8) | b8).toString(2), 2);
			//
		//}
		
	}
	
	
	public function getPixel (x:Int, y:Int):Int {
		
		if (x < 0 || y < 0 || x >= this.width || y >= this.height) return 0;
		
		if (!__locked) {
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imagedata = ctx.getImageData (x, y, 1, 1);
			
			return (imagedata.data[0] << 16) | (imagedata.data[1] << 8) | (imagedata.data[2]);
			
		} else {
			
			var offset = (4 * y * width + x * 4);
			
			return (__imageData.data[offset] << 16) | (__imageData.data[offset + 1] << 8) | (__imageData.data[offset + 2]);
			
		}
		
	}
	
	
	public function getPixel32 (x:Int, y:Int) {
		
		if (x < 0 || y < 0 || x >= this.width || y >= this.height) return 0;
		
		if (!__locked) {
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			return getInt32 (0, ctx.getImageData (x, y, 1, 1).data);
			
		} else {
			
			return getInt32 ((4 * y * ___textureBuffer.width + x * 4), __imageData.data);
			
		}
		
	}
	
	
	public function getPixels (rect:Rectangle):ByteArray {
		
		var len = Math.round (4 * rect.width * rect.height);
		var byteArray = new ByteArray ();
		byteArray.length = len;
		//var byteArray = new ByteArray(len);
		
		rect = clipRect (rect);
		if (rect == null) return byteArray;
		
		if (!__locked) {
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imagedata = ctx.getImageData (rect.x, rect.y, rect.width, rect.height);
			
			for (i in 0...len) {
				
				byteArray.writeByte (imagedata.data[i]);
				
			}
			
		} else {
			
			var offset = Math.round (4 * __imageData.width * rect.y + rect.x * 4);
			var pos = offset;
			var boundR = Math.round (4 * (rect.x + rect.width));
			
			for (i in 0...len) {
				
				if (((pos) % (__imageData.width * 4)) > boundR - 1) {
					
					pos += __imageData.width * 4 - boundR;
					
				}
				
				byteArray.writeByte (__imageData.data[pos]);
				pos++;
				
			}
			
		}
		
		byteArray.position = 0;
		return byteArray;
		
	}

	inline public static function getRGBAPixels (bitmapData:BitmapData):ByteArray {

		var p = bitmapData.getPixels (new Rectangle (0, 0, bitmapData.width, bitmapData.height));
		var num = bitmapData.width * bitmapData.height;

        p.position = 0;
		for (i in 0...num) {
            var pos = p.position;

			var alpha = p.readByte();
			var red = p.readByte();
			var green = p.readByte();
			var blue = p.readByte();

            p.position = pos;
			p.writeByte (red);
			p.writeByte (green);
			p.writeByte (blue);
			p.writeByte (alpha);

		}

		return p;
	}
	
	
	public inline function handle () {
		
		return ___textureBuffer;
		
	}
	
	
	public function hitTest(firstPoint:Point, firstAlphaThreshold:Int, secondObject:Dynamic, secondBitmapDataPoint:Point = null, secondAlphaThreshold:Int = 1):Bool {
		
		var type = Type.getClassName (Type.getClass (secondObject));
		firstAlphaThreshold = firstAlphaThreshold & 0xFFFFFFFF;
		
		var me = this;
		var doHitTest = function (imageData:ImageData) {
			
			// TODO: Use standard Haxe Type and Reflect classes?
			if (secondObject.__proto__ == null || secondObject.__proto__.__class__ == null || secondObject.__proto__.__class__.__name__ == null) return false;
			
			switch (secondObject.__proto__.__class__.__name__[2]) {
				
				case "Rectangle":
					
					var rect:Rectangle = cast secondObject;
					rect.x -= firstPoint.x;
					rect.y -= firstPoint.y;
					
					rect = me.clipRect (me.rect);
					if (me.rect == null) return false;
					
					var boundingBox = new Rectangle (0, 0, me.width, me.height);
					if (!rect.intersects(boundingBox)) return false;
					
					var diff = rect.intersection(boundingBox);
					var offset = 4 * (Math.round (diff.x) + (Math.round (diff.y) * imageData.width)) + 3;
					var pos = offset;
					var boundR = Math.round (4 * (diff.x + diff.width));
					
					while (pos < offset + Math.round (4 * (diff.width + imageData.width * diff.height))) {
						
						if ((pos % (imageData.width * 4)) > boundR - 1) {
							
							pos += imageData.width * 4 - boundR;
							
						}
						
						if (imageData.data[pos] - firstAlphaThreshold >= 0) return true;
						pos += 4;
						
					}
					
					return false;
				
				case "Point":
					
					var point : Point = cast secondObject;
					var x = point.x - firstPoint.x;
					var y = point.y - firstPoint.y;
					
					if (x < 0 || y < 0 || x >= me.width || y >= me.height) return false;
					if (imageData.data[Math.round (4 * (y * me.width + x)) + 3] - firstAlphaThreshold > 0) return true;
					
					return false;
				
				case "Bitmap":
					
					throw "bitmapData.hitTest with a second object of type Bitmap is currently not supported for HTML5";
					return false;
				
				case "BitmapData":
					
					throw "bitmapData.hitTest with a second object of type BitmapData is currently not supported for HTML5";
					return false;
				
				default:
					
					throw "BitmapData::hitTest secondObject argument must be either a Rectangle, a Point, a Bitmap or a BitmapData object.";
					return false;
				
			}
			
		}
		
		if (!__locked) {
			
			__buildLease ();
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imageData = ctx.getImageData (0, 0, width, height);
			
			return doHitTest (imageData);
			
		} else {
			
			return doHitTest (__imageData);
			
		}
		
	}
	
	
	public static function loadFromBase64 (base64:String, type:String, onload:BitmapData -> Void) {
		
		var bitmapData = new BitmapData (0, 0);
		bitmapData.__loadFromBase64 (base64, type, onload);
		return bitmapData;
		
	}
	
	
	public static function loadFromBytes (bytes:ByteArray, inRawAlpha:ByteArray = null, onload:BitmapData -> Void) {
		
		var bitmapData = new BitmapData (0, 0);
		bitmapData.__loadFromBytes (bytes, inRawAlpha, onload);
		return bitmapData;
		
	}
	
	
	public function lock ():Void {
		
		__locked = true;
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		__imageData = ctx.getImageData (0, 0, width, height);
		__imageDataChanged = false;
		__copyPixelList = [];
		
	}
	
	
	public function noise (randomSeed:Int, low:Int = 0, high:Int = 255, channelOptions:Int = 7, grayScale:Bool = false):Void {
		
		var generator = new MinstdGenerator (randomSeed);
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		
		var imageData = null;
		
		if (__locked) {
			
			imageData = __imageData;
			
		} else {
			
			imageData = ctx.createImageData (___textureBuffer.width, ___textureBuffer.height);
			
		}
		
		for (i in 0...(___textureBuffer.width * ___textureBuffer.height)) {
			
			if (grayScale) {
				
				imageData.data[i * 4] = imageData.data[i * 4 + 1] = imageData.data[i * 4 + 2] = low + generator.nextValue () % (high - low + 1);
				
			} else {
				
				imageData.data[i * 4] = if (channelOptions & BitmapDataChannel.RED == 0) 0 else low + generator.nextValue () % (high - low + 1);
				imageData.data[i * 4 + 1] = if (channelOptions & BitmapDataChannel.GREEN == 0) 0 else low + generator.nextValue () % (high - low + 1);
				imageData.data[i * 4 + 2] = if (channelOptions & BitmapDataChannel.BLUE == 0) 0 else low + generator.nextValue () % (high - low + 1);
				
			}
			
			imageData.data[i * 4 + 3] = if (channelOptions & BitmapDataChannel.ALPHA == 0) 255 else low + generator.nextValue () % (high - low + 1);
			
		}
		
		if (__locked) {
			
			__imageDataChanged = true;
			
		} else {
			
			ctx.putImageData (imageData, 0, 0);
			
		}
		
	}
	
	
	public function scroll (x:Int, y:Int):Void {
		
		throw ("bitmapData.scroll is currently not supported for HTML5");
		
	}
	
	
	public function setPixel (x:Int, y:Int, color:Int):Void {
		
		if (x < 0 || y < 0 || x >= this.width || y >= this.height) return;
		
		if (!__locked) {
			
			__buildLease ();
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			
			var imageData = ctx.createImageData (1, 1);
			imageData.data[0] = (color & 0xFF0000) >>> 16;
			imageData.data[1] = (color & 0x00FF00) >>> 8;
			imageData.data[2] = (color & 0x0000FF);
			if (__transparent) imageData.data[3] = (0xFF);
			
			ctx.putImageData (imageData, x, y);
			
		} else {
			
			var offset = (4 * y * __imageData.width + x * 4);
			
			__imageData.data[offset] = (color & 0xFF0000) >>> 16;
			__imageData.data[offset + 1] = (color & 0x00FF00) >>> 8;
			__imageData.data[offset + 2] = (color & 0x0000FF);
			if (__transparent) __imageData.data[offset + 3] = (0xFF);
			
			__imageDataChanged = true;
			
		}
		
	}
	
	
	public function setPixel32 (x:Int, y:Int, color:Int):Void {
		
		if (x < 0 || y < 0 || x >= this.width || y >= this.height) return;
		
		if (!__locked) {
			
			__buildLease ();
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imageData = ctx.createImageData (1, 1);
			
			imageData.data[0] = (color & 0xFF0000) >>> 16;
			imageData.data[1] = (color & 0x00FF00) >>> 8;
			imageData.data[2] = (color & 0x0000FF);
			
			if (__transparent) {
				
				imageData.data[3] = (color & 0xFF000000) >>> 24;
				
			} else {
				
				imageData.data[3] = (0xFF);
				
			}
			
			ctx.putImageData (imageData, x, y);
			
		} else {
			
			var offset = (4 * y * __imageData.width + x * 4);
			
			__imageData.data[offset] = (color & 0x00FF0000) >>> 16;
			__imageData.data[offset + 1] = (color & 0x0000FF00) >>> 8;
			__imageData.data[offset + 2] = (color & 0x000000FF);
			
			if (__transparent) {
				
				__imageData.data[offset + 3] = (color & 0xFF000000) >>> 24;
				
			} else {
				
				__imageData.data[offset + 3] = (0xFF);
				
			}
			
			__imageDataChanged = true;
			
		}
		
	}
	
	
	public function setPixels (rect:Rectangle, byteArray:ByteArray):Void {
		
		rect = clipRect (rect);
		if (rect == null) return;
		
		var len = Math.round (4 * rect.width * rect.height);
		
		if (!__locked) {
			
			var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
			var imageData = ctx.createImageData (rect.width, rect.height);
			
			for (i in 0...len) {
				
				imageData.data[i] = byteArray.readByte ();
				
			}
			
			ctx.putImageData (imageData, rect.x, rect.y);
			
		} else {
			
			var offset = Math.round (4 * __imageData.width * rect.y + rect.x * 4);
			var pos = offset;
			var boundR = Math.round (4 * (rect.x + rect.width));
			
			for (i in 0...len) {
				
				if (((pos) % (__imageData.width * 4)) > boundR - 1) {
					
					pos += __imageData.width * 4 - boundR;
					
				}
				
				__imageData.data[pos] = byteArray.readByte();
				pos++;
				
			}
			
			__imageDataChanged = true;
			
		}
		
	}
	
	
	public function threshold (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, operation:String, threshold:Int, color:Int = 0, mask:Int = 0xFFFFFFFF, copySource:Bool = false):Int {
		
		trace ("BitmapData.threshold not implemented");
		return 0;
		
	}
	
	
	public function unlock (changeRect:Rectangle = null):Void {
		
		__locked = false;
		
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		
		if (__imageDataChanged) {
			
			if (changeRect != null) {
				
				ctx.putImageData (__imageData, 0, 0, changeRect.x, changeRect.y, changeRect.width, changeRect.height);
				
			} else {
				
				ctx.putImageData (__imageData, 0, 0);
				
			}
			
		}
		
		for (copyCache in __copyPixelList) {
			
			if (__transparent && copyCache.transparentFiller != null) {
				
				var trpCtx:CanvasRenderingContext2D = copyCache.transparentFiller.getContext ('2d');
				var trpData = trpCtx.getImageData (copyCache.sourceX, copyCache.sourceY, copyCache.sourceWidth, copyCache.sourceHeight);
				ctx.putImageData (trpData, copyCache.destX, copyCache.destY);
				
			}
			
			ctx.drawImage (copyCache.handle, copyCache.sourceX, copyCache.sourceY, copyCache.sourceWidth, copyCache.sourceHeight, copyCache.destX, copyCache.destY, copyCache.sourceWidth, copyCache.sourceHeight);
			
		}
		
		__buildLease ();
		
	}
	
	
	private static function __base64Encode (bytes:ByteArray) {
		
		var blob = "";
		var codex = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		bytes.position = 0;
		
		while (bytes.position < bytes.length) {
			
			var by1 = 0, by2 = 0, by3 = 0;
			
			by1 = bytes.readByte ();
			
			if (bytes.position < bytes.length) by2 = bytes.readByte ();
			if (bytes.position < bytes.length) by3 = bytes.readByte ();
			
			var by4 = 0, by5 = 0, by6 = 0, by7 = 0;
			
			by4 = by1 >> 2;
			by5 = ((by1 & 0x3) << 4) | (by2 >> 4);
			by6 = ((by2 & 0xF) << 2) | (by3 >> 6);
			by7 = by3 & 0x3F;
			
			blob += codex.charAt (by4);
			blob += codex.charAt (by5);
			
			if (bytes.position < bytes.length) {
				
				blob += codex.charAt (by6);
				
			} else {
				
				blob += "=";
				
			}
			
			if (bytes.position < bytes.length) {
				
				blob += codex.charAt (by7);
				
			} else {
				
				blob += "=";
				
			}
			
		}
		
		return blob;
		
	}
	
	
	private inline function __buildLease ():Void {
		
		__lease.set (__leaseNum++, Date.now ().getTime ());
		
	}
	
	
	public inline function __clearCanvas ():Void {
		
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		ctx.clearRect (0, 0, ___textureBuffer.width, ___textureBuffer.height);
		//___textureBuffer.width = ___textureBuffer.width;
		
	}
	
	
	public static function __createFromHandle (inHandle:CanvasElement):BitmapData {
		
		var result = new BitmapData (0, 0);
		result.___textureBuffer = inHandle;
		return result;
		
	}
	
	
	public function __decrNumRefBitmaps ():Void {
		
		__assignedBitmaps--;
		
	}
	
	
	private function __fillRect (rect:Rectangle, color:Int) {
		
		__buildLease ();
		
		var ctx:CanvasRenderingContext2D = ___textureBuffer.getContext ('2d');
		
		var r = (color & 0xFF0000) >>> 16;
		var g = (color & 0x00FF00) >>> 8;
		var b = (color & 0x0000FF);
		var a = (__transparent) ? (color >>> 24) : 0xFF;
		
		if (!__locked) {
			
			//if (__transparent) {
				//
				//var trpCtx:CanvasRenderingContext2D = __transparentFiller.getContext ('2d');
				//var trpData = trpCtx.getImageData (rect.x, rect.y, rect.width, rect.height);
				//
				//ctx.putImageData (trpData, rect.x, rect.y);
				//
			//}
			
			var style = 'rgba(' + r + ', ' + g + ', ' + b + ', ' + (a / 255) + ')';
			
			ctx.fillStyle = style;
			ctx.fillRect (rect.x, rect.y, rect.width, rect.height);
			
		} else {
			
			var s = 4 * (Math.round (rect.x) + (Math.round (rect.y) * __imageData.width));
			var offsetY:Int;
			var offsetX:Int;
			
			for (i in 0...Math.round (rect.height)) {
				
				offsetY = (i * __imageData.width);
				
				for (j in 0...Math.round (rect.width)) {
					
					offsetX = 4 * (j + offsetY);
					__imageData.data[s + offsetX] = r;
					__imageData.data[s + offsetX + 1] = g;
					__imageData.data[s + offsetX + 2] = b;
					__imageData.data[s + offsetX + 3] = a;
					
				}
				
			}
			
			__imageDataChanged = true;
			//ctx.putImageData (__imageData, 0, 0, rect.x, rect.y, rect.width, rect.height);
			
		}
		
	}
	
	
	public inline function __getLease ():ImageDataLease {
		return __lease;
	}
	
	
	private inline function __loadFromBase64 (base64:String, type:String, ?onload:BitmapData -> Void):Void {
		
		var img:ImageElement = cast Browser.document.createElement ("img");
		var canvas = ___textureBuffer;
		
		var drawImage = function (_) {
			canvas.width = img.width;
			canvas.height = img.height;
			
			var ctx = canvas.getContext ('2d');
			ctx.drawImage (img, 0, 0);
			
			rect = new Rectangle (0, 0, canvas.width, canvas.height);
            __buildLease ();

            __sourceImage = cast(img);

			if (onload != null) {
				onload (this);
			}
			
		}
		
		img.addEventListener ("load", drawImage, false);
		img.src = "data:" + type + ";base64," + base64;
		
	}
	
	
	private inline function __loadFromBytes (bytes:ByteArray, inRawAlpha:ByteArray = null, ?onload:BitmapData -> Void):Void {
		
		var type = "";
		
		if (__isPNG (bytes)) {
			
			type = "image/png";
			
		} else if (__isJPG (bytes)) {
			
			type = "image/jpeg";
		} else if (__isGIF (bytes)) {
			
			type = "image/gif";
		} else {
			
			throw new IOError ("BitmapData tried to read a PNG/JPG ByteArray, but found an invalid header.");
			
		}
		
		if (inRawAlpha != null) {
			
			__loadFromBase64 (__base64Encode (bytes), type, function (_) {
				
				var ctx = ___textureBuffer.getContext ('2d');
				var pixels = ctx.getImageData (0, 0, ___textureBuffer.width, ___textureBuffer.height);
				
				for (i in 0...inRawAlpha.length) {
					
					pixels.data[i * 4 + 3] = inRawAlpha.readUnsignedByte ();
					
				}
				
				ctx.putImageData (pixels, 0, 0);
				
				if (onload != null) {
					
					onload (this);
					
				}
				
			});
			
		} else {
			
			__loadFromBase64 (__base64Encode (bytes), type, onload);
			
		}
		
	}
	
	
	public function __getNumRefBitmaps ():Int {
		
		return __assignedBitmaps;
		
	}
	
	
	public function __incrNumRefBitmaps ():Void {
		
		__assignedBitmaps++;
		
	}
	
	
	private static function __isJPG (bytes:ByteArray) {
		
		bytes.position = 0;
		return bytes.readByte () == 0xFF && bytes.readByte () == 0xD8;
		/*if (bytes.readByte() == 0xFF && bytes.readByte() == 0xD8 && bytes.readByte() == 0xFF) {
			
			bytes.readByte();
			bytes.readByte();
			bytes.readByte();
			
			if (bytes.readByte() == 0x4A && bytes.readByte() == 0x46 && bytes.readByte() == 0x49 && bytes.readByte() == 0x46 && bytes.readByte() == 0x00) {
				
				return true;
				
			}
			
		}
		
		return false;
        */
	}
	
	
	private static function __isPNG (bytes:ByteArray) {
		
		bytes.position = 0;
		return (bytes.readByte () == 0x89 && bytes.readByte () == 0x50 && bytes.readByte () == 0x4E && bytes.readByte () == 0x47 && bytes.readByte () == 0x0D && bytes.readByte () == 0x0A && bytes.readByte () == 0x1A && bytes.readByte () == 0x0A);
		
	}
	
	private static function __isGIF (bytes:ByteArray) {
		
		bytes.position = 0;
		
		//GIF8
		if  (bytes.readByte () == 0x47 && bytes.readByte () == 0x49 && bytes.readByte () == 0x46 && bytes.readByte () == 38 )
		{
			var b = bytes.readByte();
			
			return ((b==7 || b==9) && bytes.readByte()==0x61 ); //(7|8)a
		}
		
		return false;
	}
	
	
	public function __loadFromFile (inFilename:String, inLoader:LoaderInfo = null) {
		
		var image:ImageElement = cast Browser.document.createElement ("img");
		
		if (inLoader != null) {
			
			var data:LoadData = { image: image, texture: ___textureBuffer, inLoader: inLoader, bitmapData: this };
			
			image.addEventListener ("load", __onLoad.bind (data), false);
			// IE9 bug, force a load, if error called and complete is false.
			image.addEventListener ("error", function(e) { if (!image.complete) __onLoad (data, e); }, false);
			
		}
		
		image.src = inFilename;
		
		// Another IE9 bug: loading 20+ images fails unless this line is added.
		// (issue #1019768)
		if (image.complete) { }
		
	}

	
	// Event Handlers

	private function __onLoad (data:LoadData, e) {
		
		var canvas:CanvasElement = cast data.texture;
		var width = data.image.width;
		var height = data.image.height;
		canvas.width = width;
		canvas.height = height;
		
		// TODO: Should copy later, only if the bitmapData is going to be modified
		
		var ctx:CanvasRenderingContext2D = canvas.getContext ("2d");
		ctx.drawImage (data.image, 0, 0, width, height);

        __sourceImage = cast(data.image);
		
		data.bitmapData.width = width;
		data.bitmapData.height = height;
		data.bitmapData.rect = new Rectangle (0, 0, width, height);
		data.bitmapData.__buildLease ();

		if (data.inLoader != null) {
            data.inLoader.bytesTotal = 1;
            data.inLoader.bytesLoaded = 1;
			var e = new Event (Event.COMPLETE);
			e.target = data.inLoader;
			data.inLoader.dispatchEvent (e);
		} else {
            trace("Error: loader is null");
        }
		
	}
	
	// Getters & Setters
	
	private inline function get_height ():Int {
		
		if ( ___textureBuffer != null ) {
			
			return ___textureBuffer.height;
			
		} else {
			
			return 0;
			
		}
		
	}
	
	
	private function get_transparent ():Bool {
		
		return __transparent;
		
	}
	
	
	private inline function get_width ():Int {
		
		if ( ___textureBuffer != null ) {
			
			return ___textureBuffer.width;
			
		} else {
			
			return 0;
			
		}
		
	}
	
	
}


typedef LoadData = {
	
	var image:ImageElement;
	var texture:CanvasElement;
	var inLoader:Null<LoaderInfo>;
	var bitmapData:BitmapData;
	
}


class ImageDataLease {
	
	
	public var seed:Float;
	public var time:Float;
	
	
	public function new () {
		
		
		
	}
	
	
	public function clone ():ImageDataLease {
		
		var leaseClone = new ImageDataLease ();
		leaseClone.seed = seed;
		leaseClone.time = time;
		return leaseClone;
		
	}
	
	
	public function set (s:Float, t:Float):Void { 
		
		this.seed = s;
		this.time = t;
		
	}
	
	
}


typedef CopyPixelAtom = {
	
	var handle:CanvasElement;
	var transparentFiller:CanvasElement;
	var sourceX:Float;
	var sourceY:Float;
	var sourceWidth:Float;
	var sourceHeight:Float;
	var destX:Float;
	var destY:Float;
	
}


private class MinstdGenerator {
	
	/** A MINSTD pseudo-random number generator.
	 *
	 * This generates a pseudo-random number sequence equivalent to std::minstd_rand0 from the C++ standard library, which
	 * is the generator that Flash uses to generate noise for BitmapData.noise().
	 *
	 * MINSTD was originally suggested in "A pseudo-random number generator for the System/360", P.A. Lewis, A.S. Goodman,
	 * J.M. Miller, IBM Systems Journal, Vol. 8, No. 2, 1969, pp. 136-146 */
	
	private static inline var a = 16807;
	private static inline var m = (1 << 31) - 1;

	private var value:Int;
	

	public function new (seed:Int) {
		
		if (seed == 0) {
			
			this.value = 1;
			
		} else {
			
			this.value = seed;
			
		}
		
	}
	
	
	public function nextValue():Int {
		
		var lo = a * (value & 0xffff);
		var hi = a * (value >>> 16);
		lo += (hi & 0x7fff) << 16;
		
		if (lo < 0 || lo > m) {
			
			lo &= m;
			++lo;
			
		}
		
		lo += hi >>> 15;
		
		if (lo < 0 || lo > m) {
			
			lo &= m;
			++lo;
			
		}
		
		return value = lo;
		
	}
	
	
}
