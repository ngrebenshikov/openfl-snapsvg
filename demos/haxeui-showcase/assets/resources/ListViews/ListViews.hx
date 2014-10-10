package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.interfaces.InvalidationFlag;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/ListViews/ListViews.xml"))
class ListViews extends XMLController {
	public function new() {
		for (a in 0...100) {
			theList.dataSource.add({text: "Item " + (a + 1)});
		}
		
		width.onChange = function(e) {
			theList.width = width.pos;
		};
		
		height.onChange = function(e) {
			theList.height = height.pos;
		};
	}
}