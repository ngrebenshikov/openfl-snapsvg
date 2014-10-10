package haxe.ui.showcase.views;

import haxe.ui.toolkit.core.XMLController;

@:build(haxe.ui.toolkit.core.Macros.buildController("assets/resources/AbsoluteLayout/AbsoluteLayout.xml"))
class AbsoluteLayout extends XMLController {
	public function new() {
		theBox.onReady = function(e) {
			width.pos = theBox.width;
			height.pos = theBox.height;
			
			widthLabel.text = "" + width.pos;
			heightLabel.text = "" + height.pos;
		};
		
		getComponent(child.text).onReady = function(e) {
			childLeft.pos = getComponent(child.text).x;
			childTop.pos = getComponent(child.text).y;
			childWidth.pos = getComponent(child.text).width;
			childHeight.pos = getComponent(child.text).height;
			
			childLeftLabel.text = "" + childLeft.pos;
			childTopLabel.text = "" + childTop.pos;
			childWidthLabel.text = "" + childWidth.pos;
			childHeightLabel.text = "" + childHeight.pos;
		};
		
		width.onChange = function(e) {
			theBox.width = width.pos;
			widthLabel.text = "" + width.pos;
		};
		
		height.onChange = function(e) {
			theBox.height = height.pos;
			heightLabel.text = "" + height.pos;
		};
		
		disabled.onChange = function(e) {
			theBox.disabled = disabled.selected;
		};
		
		clipContent.onChange = function(e) {
			theBox.clipContent = clipContent.selected;
		};
		
		child.onChange = function(e) {
			childLeft.pos = getComponent(child.text).x;
			childTop.pos = getComponent(child.text).y;
			childWidth.pos = getComponent(child.text).width;
			childHeight.pos = getComponent(child.text).height;
			
			childLeftLabel.text = "" + childLeft.pos;
			childTopLabel.text = "" + childTop.pos;
			childWidthLabel.text = "" + childWidth.pos;
			childHeightLabel.text = "" + childHeight.pos;
		}
		
		childLeft.onChange = function(e) {
			getComponent(child.text).x = childLeft.pos;
			childLeftLabel.text = "" + childLeft.pos;
		}

		childTop.onChange = function(e) {
			getComponent(child.text).y = childTop.pos;
			childTopLabel.text = "" + childTop.pos;
		}

		childWidth.onChange = function(e) {
			getComponent(child.text).width = childWidth.pos;
			childWidthLabel.text = "" + childWidth.pos;
		}

		childHeight.onChange = function(e) {
			getComponent(child.text).height = childHeight.pos;
			childHeightLabel.text = "" + childHeight.pos;
		}
	}
}