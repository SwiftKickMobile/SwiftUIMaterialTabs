//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

/// A context value passed to sticky header components, providing a comprehensive set of metrics useful for creating sticky header scroll effects.
public struct HeaderContext<Tab>: Equatable where Tab: Hashable {

    // MARK: - API

    /// The currently selected tab (evaluates to `noTab` when using `StickyHeaders`.
    public var selectedTab: Tab

    /// The measured height of the title view. Dynamic scroll effects, such as `scaleEffect()` would typically not affect this value.
    public var titleHeight: CGFloat = 0

    /// The measured height of the tab bar. Dynamic scroll effects, such as `scaleEffect()` would typically not affect this value.
    public var tabBarHeight: CGFloat = 0

    /// The measured width of the header.
    public var width: CGFloat = 0

    /// The total height of the header, i.e. `titleHeight + tabBarHeight`. Dynamic scroll effects, such as `scaleEffect()`
    /// would typically not affect this value.
    public var totalHeight: CGFloat { titleHeight + tabBarHeight }

    /// The total height of the background view, i.e. `totalHeight + [top safe Area]`.
    public var backgroundHeight: CGFloat { totalHeight + safeArea.top }

    /// The current scroll offset, raning from 0 to `maxOffset`. Use this value to transition header elements between expanded and collapsed states.
    public var offset: CGFloat = 0

    /// The scroll offset corresponding to the header's fully collapsed state.
    public var maxOffset: CGFloat { totalHeight - tabBarHeight - minTitleHeight }

    /// The offset as a value ranging from -∞ to 1, with 0 corresponding to initial rest position and
    /// 1 corresponding to an absolute offset of `maxOffset`. Negative values occur when the scroll is
    /// rubber-banding and need to be accounted for in any dynamic header effects.
    public var unitOffset: CGFloat {
        // The formula is different based on the sign of the header offset.
        // When positive, the header is moving off of the screen up to some maximum amount.
        // When negative, the title view is stretching.
        switch offset >= 0 {
        case true: maxOffset == 0 ? 0 : 1 - (maxOffset - offset) / maxOffset
        case false: 1 - (titleHeight - offset) / titleHeight
        }
    }

    // A value related to sticky titles. See the `minTitleHeight()` vieww modifier.
    public var minTitleHeight: CGFloat {
        switch minTitleMetric {
        case .absolute(let metric): metric.clamped(min: 0, max: titleHeight)
        case .unit(let percent): titleHeight * percent.clamped01()
        }
    }

    #if DEBUG
    /// A DEBUG-only initializer provided for making previews.
    public init(selectedTab: Tab) {
        self.selectedTab = selectedTab
    }
    #endif

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
