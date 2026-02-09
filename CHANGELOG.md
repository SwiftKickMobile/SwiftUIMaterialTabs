# Change Log
All notable changes to this project will be documented in this file.

## 2.0.7

### Improvements

* Add context-free initializers to `MaterialTabsScroll` and `StickyHeaderScroll`. The existing initializers pass a `MaterialTabsScrollContext` (or `StickyHeaderScrollContext`) to the content view builder, which includes the content offset. Because the content offset changes on every frame during scrolling, this causes the content view `body` to be re-evaluated continuously. The new initializers omit the context, allowing the content to be shielded from these unnecessary re-evaluations via an internal `ContentWrapperView` with `Equatable` conformance. If your content does not need the context, prefer the new initializers for better scroll performance.

## 2.0.6

### Fixes
* Fix bug in `StickyHeaderScroll` header rubber banding

## 2.0.5

### Improvements

* #12 Add more control to how how scroll position is preserved across tabs in relation to the growing and shrinking of the header. When creating `MaterialTabsScroll`, provide an optional `MaterialTabsConfig` and specify the `crossTabSyncMode` as follows (the default is `resetTitleOnScroll()`:

````swift
    /// Specifies how the scroll view and header adjust to maintain continuity when switching tabs. These options affect one specific scenario. Suppose
    /// we have two tabs A and B and a collapsible title view:
    ///
    ///   1. User scrolls down (a.k.a swipes up) in tab A such that the title view is collapsed.
    ///   2. User switches to tab B and scrolls up (a.k.a swipes down) until the title view is expanded
    ///   3. User switches back to tab A
    ///
    /// Since the title view is expanded on tab A, but it would have naturally been collapsed, there are multiple strategies for how continuitity is preserved.
    public enum CrossTabSyncMode: Equatable {
        /// Preserves the scroll position relative to the header. If the header has moved up, the scroll view is moved up. If the header is moved down, the scroll
        /// view is moved down. The benefit of this approach is preserving the user's scroll position. The down side is that the header is expanded when it
        /// should be collapsed and will remain expanded if the user scrolls up, which could severely limit the space for scroll view content if the header
        /// is unusually tall.
        case preserveScrollPosition
        /// Resets the scroll position to align the top of the scroll view content is aligned with the bottom of the header. This is how many apps behave and
        /// it ensures that scroll position and title collapse state are always in sync. The down side is that the user's previous scroll position is lost.
        case resetScrollPosition
        /// Initially preserves the scroll position the same as `preserveContentOffset`. However, if the user scrolls, the title collapse state is
        /// animated to where match the scroll position. This option introduces a title view animation, but eliminates the down sides of other options.
        /// This is the default behavior.
        case resetTitleOnScroll(_ animation: Animation = .snappy(duration: 0.3))
    }
````

### Fixes
* Fix #17 tab bar doesn't animate when switching tabs
* Fix #9 Fix issue where appearing tab doesn't have its content offset adjusted to be in sync with the header until after it appears. This was causing a visible content offset jump when swiping slowly to a new tab. The fix only works on iOS 18+.

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
