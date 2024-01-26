//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

public struct HeaderContext<Tab>: Equatable where Tab: Hashable {

    // MARK: - API

    public var selectedTab: Tab

    public var titleHeight: CGFloat = 0

    public var tabBarHeight: CGFloat = 0

    public var width: CGFloat = 0

    public var totalHeight: CGFloat { titleHeight + tabBarHeight }

    public var backgroundHeight: CGFloat { totalHeight + topSafeArea }

    // The current scroll offset, raning from 0 to `maxOffset`. Use this value
    // to transition header elements between expanded and collapsed states.
    public var offset: CGFloat = 0

    // The scroll offset corresponding to the header's fully collapsed state.
    public var maxOffset: CGFloat { totalHeight - tabBarHeight - minTitleHeight }

    // The offset as a value ranging from -∞ to 1, with 0 corresponding to initial rest position and
    // 1 corresponding to an absolute offset of `maxOffset` Negative values occur when the scroll is
    // rubber-banding and need to be accounted for in any dynamic header effects.
    public var unitOffset: CGFloat {
        // The formula is different based on the sign of the header offset.
        // When positive, the header is moving off of the screen up to some maximum amount.
        // When negative, the title view is stretching.
        switch offset >= 0 {
        case true: maxOffset == 0 ? 0 : 1 - (maxOffset - offset) / maxOffset
        case false: 1 - (titleHeight - offset) / titleHeight
        }
    }

    public var minTitleHeight: CGFloat {
        switch minTitleDimension {
        case .absolute(let dimension): dimension.clamped(min: 0, max: titleHeight)
        case .unit(let percent): titleHeight * percent.clamped01()
        }
    }

    public init(selectedTab: Tab) {
        self.selectedTab = selectedTab
    }

    var rubberBandingTitleHeight: CGFloat? {
        guard offset < 0 else { return nil }
        return titleHeight * (1 - unitOffset)
    }

    var rubberBandingBackgroundHeight: CGFloat {
        guard offset < 0 else { return backgroundHeight }
        return (rubberBandingTitleHeight ?? titleHeight) + tabBarHeight + topSafeArea
    }

    // MARK: - Constants

    // MARK: - Variables

    var minTitleDimension: MinTitleHeightPreferenceKey.Dimension = MinTitleHeightPreferenceKey.defaultValue
    var topSafeArea: CGFloat = 0
}