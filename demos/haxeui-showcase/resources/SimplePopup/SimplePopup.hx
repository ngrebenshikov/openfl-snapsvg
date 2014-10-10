package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/SimplePopup/SimplePopup.xml"))
class SimplePopup extends XMLController {
	public function new() {
		showButton.onClick = function(e) {
			var buttons:Int = 0;
			if (okButton.selected == true) {
				buttons |= PopupButton.OK;
			}
			if (cancelButton.selected == true) {
				buttons |= PopupButton.CANCEL;
			}
			if (confirmButton.selected == true) {
				buttons |= PopupButton.CONFIRM;
			}
			if (yesButton.selected == true) {
				buttons |= PopupButton.YES;
			}
			if (noButton.selected == true) {
				buttons |= PopupButton.NO;
			}
			PopupManager.instance.showSimple(text.text, title.text, buttons);
		};
	}
}