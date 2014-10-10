package haxe.ui.showcase.views;

import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.core.base.HorizontalAlign;
import haxe.ui.toolkit.core.interfaces.InvalidationFlag;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/ScrollViews/ScrollViews.xml"))
class ScrollViews extends XMLController {
	public function new() {
		for (a in 0...100) {
			var button:Button = new Button();
			button.percentWidth = 50 + Std.random(50);
			button.text = "" + button.percentWidth + "%";
			var align = Std.random(3);
			switch (align) {
				//case 0: button.horizontalAlign = HorizontalAlign.LEFT; break;
				//case 1: button.horizontalAlign = HorizontalAlign.CENTER; break;
				//case 2: button.horizontalAlign = HorizontalAlign.RIGHT; break;
				default: 
			}
			theContainer.addChild(button);
		}
		
		width.onChange = function(e) {
			theView.width = width.pos;
		};
		
		height.onChange = function(e) {
			theView.height = height.pos;
		};
	}
	
}