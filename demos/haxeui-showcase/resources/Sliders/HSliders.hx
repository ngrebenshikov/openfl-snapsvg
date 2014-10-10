package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/Sliders/HSliders.xml"))
class HSliders extends XMLController {
	public function new() {
		theScroll.onReady = function(e) {
			width.pos = theScroll.width;
			height.pos = theScroll.height;
			min.pos = theScroll.min;
			max.pos = theScroll.max;
			pos.pos = theScroll.pos;
			
			widthLabel.text = "" + width.pos;
			heightLabel.text = "" + height.pos;
			minLabel.text = "" + min.pos;
			maxLabel.text = "" + max.pos;
			posLabel.text = "" + pos.pos;
		};
		
		theScroll.onChange = function(e) {
			pos.pos = theScroll.pos;
			posLabel.text = "" + pos.pos;
		};
		
		width.onChange = function(e) {
			theScroll.width = width.pos;
			widthLabel.text = "" + width.pos;
		};
		
		height.onChange = function(e) {
			theScroll.height = height.pos;
			heightLabel.text = "" + height.pos;
		};

		min.onChange = function(e) {
			theScroll.min = min.pos;
			pos.min = min.pos;
			minLabel.text = "" + min.pos;
		};
		
		max.onChange = function(e) {
			theScroll.max = max.pos;
			pos.max = max.pos;
			maxLabel.text = "" + max.pos;
		};
		
		pos.onChange = function(e) {
			theScroll.pos = pos.pos;
			posLabel.text = "" + pos.pos;
		};
		
		disabled.onChange = function(e) {
			theScroll.disabled = disabled.selected;
		}
	}
}