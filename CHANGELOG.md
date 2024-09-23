# Change Log
All notable changes to this project will be documented in this file.

## 2.0.4

### Fixes

* Fix #17 Animate tab bar scroll position changes

## 2.0.3

### Fixes
* Fix #12 Scroll doesn't reset when switching the tabs while scrolled to top
* Fix the bottom padding on `MaterialTabsScroll` in iOS 18

## 2.0.2

### Fixes

* Automatically pad the bottom of `MaterialTabsScroll` when the content of a tab is too small to scroll to the fully collapsed header state.

## 2.0.1

### Improvements

* Add two new configuration options to `MaterialTabBar` that can be useful when implementing custom tab labels:
  * `fillAvailableSpace`: Applicable when tab labels don't inherently fill the width of the tab bar. When `true` (the default), the label widths are expanded proportionally to fill the tab bar. When `false`, the labels are not expanded and centered horizontally within the tab bar.
  * `spacing`: The amount of horizontal spacing to use between tab labels. Primary and Secondary tabs should use the default spacing of 0 to form a continuous line across the bottom of the tab bar.

## 2.0.0

### Improvements

* Add a context argument to the `MaterialTabsScroll` and `StickyHeaderScroll` view builders, providing useful metrics, such as the available safe height for content under the header.
