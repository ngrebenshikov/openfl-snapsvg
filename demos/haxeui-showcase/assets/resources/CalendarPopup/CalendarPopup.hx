package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/CalendarPopup/CalendarPopup.xml"))
class CalendarPopup extends XMLController {
	public function new() {
		showButton.onClick = function(e) {
			PopupManager.instance.showCalendar(title.text, function(button, date) {
				if (button == PopupButton.CONFIRM) {
					PopupManager.instance.showSimple("You selected '" + date + "'", "Selection");
				}
			});
		};
	}
}