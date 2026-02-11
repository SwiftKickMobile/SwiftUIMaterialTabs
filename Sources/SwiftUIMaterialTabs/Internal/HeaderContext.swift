//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

/// A context value passed to sticky header components, providing metrics usefuil for creating sticky header scroll effects.
///
/// During scrolling, the header is offset to track the scroll position. The header sticks in its fully collapsed position when the offset
/// reaches `HeaderContext/maxOffset`, which is derived from the measured tab bar height and any minimum title height established by
/// the `minTitleHeight()` view modifier.
///
/// In the other direction, when the scroll is pulled past the top rest position, a.k.a "rubber banding", the title view's height is increased
/// to track the offset.
///
/// Although the collapsed state of the header is just an offset, applying the `headerStyle()` view modifier to header elements can give the
/// impression of shrinking, fading, parallax, etc. All of these effects are achived by manipulating the views based on the `HeaderContext`
/// values provided to the various header view builders. You may also manipulate header elements directly without using `headerStyle()` if you wish.
@Observable
public class HeaderContext<Tab> where Tab: Hashable {

    // MARK: - API

    /// The currently selected tab (evaluates to `noTab` when using `StickyHeaders`.
    public var selectedTab: Tab

    /// The measured height of the title view. Applying `scaleEffect()` as a scroll effect does not affect this value.
    public var titleHeight: CGFloat = 0

    /// The measured height of the tab bar. Applying `scaleEffect()` as a scroll effect does not affect this value.
    public var tabBarHeight: CGFloat = 0

    /// The measured width of the header.
    public var width: CGFloat = 0

    /// The height of the header, i.e. `titleHeight + tabBarHeight`. Does not include the top safe area. Use `backgroundHeight` for the entire
    /// height includeing top safe area. Applying `scaleEffect()` as a scroll effect does not affect this value.
    public var height: CGFloat { titleHeight + tabBarHeight }

    /// The total height of the background view, i.e. `height + [top safe Area]`.
    public var backgroundHeight: CGFloat { height + safeArea.top }

    /// The current scroll offset, ranging from 0 to `maxOffset`. Use this value to transition header elements between expanded and collapsed states.
    public var offset: CGFloat = 0

    /// The scroll offset corresponding to the header's fully collapsed state.
    public var maxOffset: CGFloat { height - tabBarHeight - minTitleHeight }

    /// The offset as a value ranging from -∞ to 1, with 0 corresponding to initial rest position and
    /// 1 corresponding to an absolute offset of `maxOffset`. Negative values occur when the scroll is
    /// rubber-banding and need to be accounted for in any dynamic header effects.
    public var unitOffset: CGFloat {
        switch offset >= 0 {
        case true: maxOffset == 0 ? 0 : 1 - (maxOffset - offset) / maxOffset
        case false: titleHeight == 0 ? 0 : 1 - (titleHeight - offset) / titleHeight
        }
    }

    /// The absolute horizontal content offset of the scroll view.
    public var contentOffset: CGFloat = 0

    /// A value related to sticky titles. See the `minTitleHeight()` vieww modifier.
    public var minTitleHeight: CGFloat {
        switch minTitleMetric {
        case .absolute(let metric): metric.clamped(min: 0, max: titleHeight)
        case .unit(let percent): titleHeight * percent.clamped01()
        }
    }

    /// The minimum effective height of the header in the fully collapsed position.
    public var minTotalHeight: CGFloat { tabBarHeight + minTitleHeight }

    public init(selectedTab: Tab) {
        self.selectedTab = selectedTab
    }

    var rubberBandingTitleHeight: CGFloat? {
        guard offset < 0 else { return nil }
        return titleHeight * (1 - unitOffset)
    }

    var rubberBandingBackgroundHeight: CGFloat {
        guard offset < 0 else { return backgroundHeight }
        return (rubberBandingTitleHeight ?? titleHeight) + tabBarHeight + safeArea.top
    }

    var animationNamespace: Namespace.ID? = nil

    // MARK: - Constants

    // MARK: - Variables

    var minTitleMetric: MinTitleHeightPreferenceKey.Metric = MinTitleHeightPreferenceKey.defaultValue
    var safeArea: EdgeInsets = .init()
}
