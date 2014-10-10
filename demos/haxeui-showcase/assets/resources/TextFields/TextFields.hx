package haxe.ui.showcase.views;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/TextFields/TextFields.xml"))
class TextFields extends XMLController {
	public function new() {
		width.pos = theField.width;
		height.pos = theField.height;
		
		text.onChange = function(e) {
			theField.text = text.text;
		};
		
		width.onChange = function(e) {
			theField.width = width.pos;
		};
		
		height.onChange = function(e) {
			theField.height = height.pos;
		};
		
		fontSize.onChange = function(e) {
			theField.style.fontSize = fontSize.pos;
			width.pos = theField.width;
			height.pos = theField.height;
		};
		
		multiline.onClick = function(e) {
			theField.multiline = multiline.selected;
		};
		
		wrapLines.onClick = function(e) {
			theField.wrapLines = wrapLines.selected;
		};
	}
}