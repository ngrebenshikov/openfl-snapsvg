package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/CheckBoxes/CheckBoxes.xml"))
class CheckBoxes extends XMLController {
	public function new() {
		text.onChange = function(e) {
			theCheckbox1.text = text.text + " 1";
			theCheckbox2.text = text.text + " 2";
			theCheckbox3.text = text.text + " 3";
		};
		
		fontSize.onChange = function(e) {
			theCheckbox1.style.fontSize = fontSize.pos;
			theCheckbox2.style.fontSize = fontSize.pos;
			theCheckbox3.style.fontSize = fontSize.pos;
		};
		
		disabled.onClick = function(e) {
			theCheckbox1.disabled = disabled.selected;
			theCheckbox2.disabled = disabled.selected;
			theCheckbox3.disabled = disabled.selected;
		};
	}
	
}