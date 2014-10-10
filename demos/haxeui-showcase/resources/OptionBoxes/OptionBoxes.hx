package haxe.ui.showcase.views;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/OptionBoxes/OptionBoxes.xml"))
class OptionBoxes extends XMLController {
	public function new() {
		text.onChange = function(e) {
			theOptionbox1.text = text.text + " 1";
			theOptionbox2.text = text.text + " 2";
			theOptionbox3.text = text.text + " 3";
		};
		
		fontSize.onChange = function(e) {
			theOptionbox1.style.fontSize = fontSize.pos;
			theOptionbox2.style.fontSize = fontSize.pos;
			theOptionbox3.style.fontSize = fontSize.pos;
		};
		
		disabled.onClick = function(e) {
			theOptionbox1.disabled = disabled.selected;
			theOptionbox2.disabled = disabled.selected;
			theOptionbox3.disabled = disabled.selected;
		};
	}
}