package flash.ui;


import flash.display.Stage;


class Accelerometer {
	
	
	public static function get ():Acceleration {
		
		return Stage.__acceleration;
		
	}
	
	
}