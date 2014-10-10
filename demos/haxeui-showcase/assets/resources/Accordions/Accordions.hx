package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/Accordions/Accordions.xml"))
class Accordions extends XMLController {
	public function new() {
		width.onChange = function(e) {
			theAccordion.width = width.pos;
		};
		
		height.onChange = function(e) {
			theAccordion.height = height.pos;
		};
	}
}