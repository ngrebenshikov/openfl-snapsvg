package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/TextInputs/TextInputs.xml"))
class TextInputs extends XMLController {
	public function new() {
		width.onChange = function(e) {
			theInput.width = width.pos;
		}
		
		height.onChange = function(e) {
			theInput.height = height.pos;
		}
		
		disabled.onClick = function(e) {
			theInput.disabled = disabled.selected;
		}
		
		password.onClick = function(e) {
			theInput.displayAsPassword = password.selected;
		}
		
		placeholderText.onChange = function(e) {
			theInput.placeholderText = placeholderText.text;
		}
		
		multiline.onClick = function(e) {
			theInput.multiline = multiline.selected;
		}
		
		wrapLines.onClick = function(e) {
			theInput.wrapLines = wrapLines.selected;
		}
	}
}