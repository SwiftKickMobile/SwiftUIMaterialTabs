//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

@MainActor
class TabsModel<Tab>: ObservableObject where Tab: Hashable {

    // MARK: - API

    struct State: Equatable {
        var headerContext: HeaderContext<Tab>
        var totalHeight: CGFloat = 0

        var scrollViewHeight: CGFloat { totalHeight - headerContext.totalHeight }
    }

    @Published fileprivate(set) var state: State

    init(selectedTab: Tab) {
        _state = Published(
            wrappedValue: State(headerContext: HeaderContext(selectedTab: selectedTab))
        )
    }

    func heightChanged(_ height: CGFloat) {
        state.totalHeight = height
    }

    func titleHeightChanged(_ height: CGFloat) {
        state.headerContext.titleHeight = height
    }

    func minTitleHeightChanged(_ dimension: MinTitleHeightPreferenceKey.Dimension) {
        state.headerContext.minTitleDimension = dimension
    }

    func tabBarHeightChanged(_ height: CGFloat) {
        state.headerContext.tabBarHeight = height
    }

    func selected(tab: Tab) {
        self.state.headerContext.selectedTab = tab
    }

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - MaterialTabsModel

    func scrolled(tab: Tab, offset: CGFloat, deltaOffset: CGFloat) {
        // Any time the offset is less than the max offset, the header offset exactly tracks the offset.
        if offset < state.headerContext.maxOffset {
            state.headerContext.offset = offset
        }
        // However, for greater offsets, the header offset only gets adjusted for positive changes in the offset.
        // Once we scroll too far, the header offset hits the limit, so we can't just track the offset. Instead, we
        // use the change in offset.
        else if deltaOffset > 0 {
            let unconstrainedOffset = state.headerContext.offset + deltaOffset
            state.headerContext.offset = min(unconstrainedOffset, state.headerContext.maxOffset)
        }
    }
}
