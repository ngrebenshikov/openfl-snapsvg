package openfl.filters;


import openfl.display.BitmapData;
import openfl.geom.Point;


class DisplacementMapFilter extends BitmapFilter {
	
	
	public var alpha:Float;
	public var color:Int;
	public var componentX:Int;
	public var componentY:Int;
	public var mapBitmap:BitmapData;
	public var mapPoint:Point;
	public var mode:DisplacementMapFilterMode;
	public var scaleX:Float;
	public var scaleY:Float;
	
	
	public function new (mapBitmap:BitmapData = null, mapPoint:Point = null, componentX:Int = 0, componentY:Int = 0, scaleX:Float = 0, scaleY:Float = 0, mode:DisplacementMapFilterMode = null, color:Int = 0, alpha:Float = 0) {
		
		super ("DisplacementMapFilter");
		
		this.mapBitmap = mapBitmap;
		this.mapPoint = mapPoint;
		this.componentY = componentY;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.mode = mode;
		this.color = color;
		this.alpha = alpha;
		
	}


    override public function clone ():BitmapFilter {
        return new DisplacementMapFilter (mapBitmap, mapPoint, componentX, componentY, scaleX, scaleY, mode, color, alpha);
    }

    override public function __getSvg(): String {
        //TODO: implement
        return null;
    }
	
	
}