package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/DateSelectors/DateSelectors.xml"))
class DateSelectors extends XMLController {
	public function new() {
		width.onChange = function(e) {
			theSelector.width = width.pos;
		}
		
		height.onChange = function(e) {
			theSelector.height = height.pos;
		}
		
		popupMethod.onChange = function(e) {
			theSelector.method = (popupMethod.selected == true) ? "popup" : "";
		}
		
		dropdownMethod.onChange = function(e) {
			theSelector.method = (dropdownMethod.selected == true) ? "dropdown" : "";
		}
	}
}