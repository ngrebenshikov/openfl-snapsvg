package haxe.ui.showcase.views;

import haxe.ui.showcase.views.CustomPopup.CustomPopupController;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/CustomPopup/CustomPopup.xml"))
class CustomPopup extends XMLController {
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
			var controller:CustomPopupController = new CustomPopupController();
			PopupManager.instance.showCustom(controller.view, title.text, buttons, function (button) {
				if (button == PopupButton.OK || button == PopupButton.YES || button == PopupButton.CONFIRM) {
					PopupManager.instance.showSimple("Hello, " + controller.name, "Hello!");
				}
			});
		};
	}
}

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/CustomPopup/CustomPopupContent.xml"))
class CustomPopupController extends XMLController {
	public function new() {
	}
	
	public var name(get, null):String;
	private function get_name():String {
		return firstName.text + " " + lastName.text;
	}
}