package flash.display;


import flash.display.IGraphicsData;
import flash.display.IGraphicsFill;
import flash.utils.UInt;


class GraphicsSolidFill implements IGraphicsData implements IGraphicsFill {
	
	
	public var alpha:Float;
	public var color:UInt;
	
	public var __graphicsDataType (default, null):GraphicsDataType;
	public var __graphicsFillType (default, null):GraphicsFillType;
	
	
	public function new (color:UInt = 0, alpha:Float = 1) {
		
		this.alpha = alpha;
		this.color = color;
		this.__graphicsDataType = SOLID;
		this.__graphicsFillType = SOLID_FILL;
		
	}
	
	
}