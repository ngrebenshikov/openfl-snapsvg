package openfl.ui;


import openfl.display.Stage;


class Accelerometer {
	
	
	public static function get ():Acceleration {
		
		return Stage.__acceleration;
		
	}
	
	
}