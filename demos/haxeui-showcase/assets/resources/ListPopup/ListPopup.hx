package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.interfaces.IItemRenderer;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/ListPopup/ListPopup.xml"))
class ListPopup extends XMLController {
	public function new() {
		showButton.onClick = function(e) {
			var index:Int = Std.parseInt(selection.text);
			var itemArray:Array<String> = items.text.split("\r");
			PopupManager.instance.showList(itemArray, index, title.text, null, function(item:IItemRenderer) {
				PopupManager.instance.showSimple("You selected '" + item.data.text + "'", "Selection");
				selection.text = "" + item.data.index;
			});
		};
	}
}