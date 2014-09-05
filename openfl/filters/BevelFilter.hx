package openfl.filters;

class BevelFilter extends BitmapFilter {
	
	
	public var angle:Float;
	public var blurX:Float;
	public var blurY:Float;
	public var distance:Float;
	public var highlightAlpha:Float;
	public var highlightColor:UInt;
	public var knockout:Bool;
	public var quality:Int;
	public var shadowAlpha:Float;
	public var shadowColor:UInt;
	public var strength:Float;
	public var type:BitmapFilterType;
	
	
	public function new (distance:Float = 0, angle:Float = 0, highlightColor:Int = 0xFF, highlightAlpha:Float = 1, shadowColor:Int = 0, shadowAlpha:Float = 1, blurX:Float = 4, blurY:Float = 4, strength:Float = 1, quality:Int = 1, type:BitmapFilterType = null, knockout:Bool = false) {
		
		super ("BevelFilter");
		
		this.distance = distance;
		this.angle = angle;
		this.highlightColor = highlightColor;
		this.highlightAlpha = highlightAlpha;
		this.shadowColor = shadowColor;
		this.shadowAlpha = shadowAlpha;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.type = type;
		this.knockout = knockout;
		
	}

    override public function clone ():BitmapFilter {

        return new BevelFilter (distance, angle, highlightColor, highlightAlpha, shadowColor, shadowAlpha, blurX, blurY, strength, quality, type, knockout);

    }

    override public function __getSvg(): String {
        var highlight = "rgba(" + ((highlightColor >> 16) & 0xFF) + "," + ((highlightColor >> 8) & 0xFF) + "," + (highlightColor & 0xFF) + "," + highlightAlpha + ")";
        var x = - distance * Math.sin (2 * Math.PI * angle / 360.0);
        var y = - distance * Math.cos (2 * Math.PI * angle / 360.0);

        return '<feGaussianBlur in="SourceAlpha" stdDeviation="5" result="blur"/>
            <feSpecularLighting surfaceScale="3" specularConstant="1.75" specularExponent="20" lighting-color="' + highlight + '" in="blur" result="highlight">
                <fePointLight x="' + x + '" y="' + y + '" z="' + distance + '"/>
            </feSpecularLighting>
            <feComposite in="highlight" in2="SourceAlpha" operator="in" result="highlight"/>
            <feComposite in="SourceGraphic" in2="highlight" operator="arithmetic" k1="0" k2="1" k3="1" k4="0" result="highlightText"/>';
    }

}