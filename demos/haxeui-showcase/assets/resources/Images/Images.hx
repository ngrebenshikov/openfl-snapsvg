package haxe.ui.showcase.views;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/Images/Images.xml"))
class Images extends XMLController {
	public function new() {
		width.onChange = function(e) {
			theImage.width = width.pos;
		};
		
		height.onChange = function(e) {
			theImage.height = height.pos;
		};
		
		resource.onChange = function(e) {
			theImage.resource = "resources/" + resource.text;
		};
	}
	
}