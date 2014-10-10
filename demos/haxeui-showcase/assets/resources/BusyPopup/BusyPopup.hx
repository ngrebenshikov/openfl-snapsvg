package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/BusyPopup/BusyPopup.xml"))
class BusyPopup extends XMLController {
	public function new() {
		showButton.onClick = function(e) {
			var theTitle:String = null;
			if (title.text.length > 0) {
				theTitle = title.text;
			}
			PopupManager.instance.showBusy(message.text, Std.parseInt(delay.text), theTitle);
		};
	}
}