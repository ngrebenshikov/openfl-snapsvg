package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/BoxLayout/BoxLayout.xml"))
class BoxLayout extends XMLController {
	private static var VALIGNS:Array<String> = ["top", "center", "bottom"];
	private static var HALIGNS:Array<String> = ["left", "center", "right"];
	
	public function new() {
		theBox.onReady = function(e) {
			width.pos = theBox.width;
			height.pos = theBox.height;
			
			widthLabel.text = "" + width.pos;
			heightLabel.text = "" + height.pos;
		};
		
		getComponent(child.text).onReady = function(e) {
			childWidth.pos = getComponent(child.text).width;
			childHeight.pos = getComponent(child.text).height;
			
			childWidthLabel.text = "" + childWidth.pos;
			childHeightLabel.text = "" + childHeight.pos;
		};
		
		width.onChange = function(e) {
			theBox.width = width.pos;
			widthLabel.text = "" + width.pos;
		}
		
		height.onChange = function(e) {
			theBox.height = height.pos;
			heightLabel.text = "" + height.pos;
		}
		
		disabled.onChange = function(e) {
			theBox.disabled = disabled.selected;
		};
		
		child.onChange = function(e) {
			var c:Component = getComponent(child.text);
			if (c.percentWidth == -1) {
				childWidthAsPercent.selected = false;
				childWidth.pos = c.width;
				childWidthLabel.text = "" + c.width;
			} else {
				childWidthAsPercent.selected = true;
				childWidth.pos = c.percentWidth;
				childWidthLabel.text = "" + c.percentWidth;
			}
			
			if (c.percentHeight == -1) {
				childHeightAsPercent.selected = false;
				childHeight.pos = c.height;
				childHeightLabel.text = "" + c.height;
			} else {
				childHeightAsPercent.selected = true;
				childHeight.pos = c.percentHeight;
				childHeightLabel.text = "" + c.percentHeight;
			}
			
			halign.selectedIndex = Lambda.indexOf(HALIGNS, c.horizontalAlign);
			valign.selectedIndex = Lambda.indexOf(VALIGNS, c.verticalAlign);
		}
		
		childWidth.onChange = function(e) {
			var c:Component = getComponent(child.text);
			if (childWidthAsPercent.selected == false) {
				c.percentWidth = -1;
				c.width = childWidth.pos;
				childWidthLabel.text = "" + c.width;
			} else {
				c.percentWidth = Std.int(childWidth.pos / 2);
				childWidthLabel.text = "" + c.percentWidth;
			}
		}

		childHeight.onChange = function(e) {
			var c:Component = getComponent(child.text);
			if (childHeightAsPercent.selected == false) {
				c.percentHeight = -1;
				c.height = childHeight.pos;
				childHeightLabel.text = "" + c.height;
			} else {
				c.percentHeight = Std.int(childHeight.pos / 2);
				childHeightLabel.text = "" + c.percentHeight;
			}
		}
		
		childWidthAsPercent.onClick = function(e) {
			var c:Component = getComponent(child.text);
			if (childWidthAsPercent.selected == false) {
				c.percentWidth = -1;
				c.width = childWidth.pos;
				childWidthLabel.text = "" + c.width;
			} else {
				c.percentWidth = Std.int(childWidth.pos / 2);
				childWidthLabel.text = "" + c.percentWidth;
			}
		}
		
		childHeightAsPercent.onClick = function(e) {
			var c:Component = getComponent(child.text);
			if (childHeightAsPercent.selected == false) {
				c.percentHeight = -1;
				c.height = childHeight.pos;
				childHeightLabel.text = "" + c.height;
			} else {
				c.percentHeight = Std.int(childHeight.pos / 2);
				childHeightLabel.text = "" + c.percentHeight;
			}
		}
		
		halign.onChange = function(e) {
			var c:Component = getComponent(child.text);
			c.horizontalAlign = halign.text;
		}

		valign.onChange = function(e) {
			var c:Component = getComponent(child.text);
			c.verticalAlign = valign.text;
		}
	}
}