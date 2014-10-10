package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/Buttons/Buttons.xml"))
class Buttons extends XMLController {
	public function new() {
		text.onChange = function(e) {
			theButton.text = text.text;
		};
		
		width.onChange = function(e) {
			theButton.width = width.pos;
		};
		
		height.onChange = function(e) {
			theButton.height = height.pos;
		};
		
		disabled.onClick = function(e) {
			theButton.disabled = disabled.selected;
		};
		
		toggle.onClick = function(e) {
			theButton.toggle = toggle.selected;
		};
		
		icon.onChange = function(e) {
			theButton.style.icon = icon.text;
		};
		
		iconPosition.onChange = function(e) {
			theButton.style.iconPosition = iconPosition.text;
		};
	}
} 