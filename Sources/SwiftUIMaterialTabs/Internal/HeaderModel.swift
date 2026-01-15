//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

@MainActor
class HeaderModel<Tab>: ObservableObject where Tab: Hashable {

    // MARK: - API

    struct State: Equatable {
        var headerContext: HeaderContext<Tab>

        /// The height reported by the geometry reader. Includes the additional safe area padding we apply.
        var height: CGFloat = 0

        var tabsRegistered: Bool = false

        /// The height factoring in the additional safe area padding we apply.
        var safeHeight: CGFloat {
            height - headerContext.minTotalHeight
        }

        var config: MaterialTabsConfig = MaterialTabsConfig()
    }

    @Published fileprivate(set) var state: State

    init(selectedTab: Tab) {
        _state = Published(
            wrappedValue: State(headerContext: HeaderContext(selectedTab: selectedTab))
        )
    }

    func configChanged(_ config: MaterialTabsConfig) {
        state.config = config
    }

    func sizeChanged(_ size: CGSize) {
        state.height = size.height
        state.headerContext.width = size.width
    }

    func titleHeightChanged(_ height: CGFloat) {
        state.headerContext.titleHeight = height
    }

    func minTitleHeightChanged(_ metric: MinTitleHeightPreferenceKey.Metric) {
        state.headerContext.minTitleMetric = metric
    }

    func tabBarHeightChanged(_ height: CGFloat) {
        state.headerContext.tabBarHeight = height
    }

    func selected(tab: Tab) {
        hasScrolledSinceSelected = false
        self.state.headerContext.selectedTab = tab
    }

    func safeAreaChanged(_ safeArea: EdgeInsets) {
        self.state.headerContext.safeArea = safeArea
    }

    func animationNamespaceChanged(_ animationNamespace: Namespace.ID) {
        state.headerContext.animationNamespace = animationNamespace
    }

    func tabsRegistered() {
        Task {
            guard !state.tabsRegistered else { return }
            state.tabsRegistered = true
        }
    }

    func contentOffsetChanged(_ contentOffset: CGFloat) {
        state.headerContext.contentOffset = contentOffset
    }

    // MARK: - Constants

    // MARK: - Variables

    private var hasScrolledSinceSelected = false

    // MARK: - Scroll tracking

    /// Adjust the header offset as the scroll view's offset changes. As discussed elsewhere in this library, the header view itself doesn't shrink—instead its vertical
    /// position is shifted up until it reaches a maximum corresponding to a fully collapsed header state. Scroll effects can be applied to subviews within the
    /// header to give the appearance of shrinking, among other things.
    ///
    /// In the basic case, the header offset matches the scroll view up calculated max offset. However, in a multi-tab environment, scrolling on another tab
    /// can change the header offset, introducing edge cases that need to be handled.
    func scrolled(tab: Tab, contentOffset: CGFloat, deltaContentOffset: CGFloat) {
        guard tab == state.headerContext.selectedTab else { return }
        switch state.config.crossTabSyncMode {
        case .resetTitleOnScroll where !hasScrolledSinceSelected:
            withAnimation(.snappy(duration: 0.3)) {
                state.headerContext.offset = min(state.headerContext.maxOffset, contentOffset)
            }
        default:
            state.headerContext.contentOffset = contentOffset
            // When scrolling down (a.k.a. swiping up), the header offset matches the scroll view until it reaches the
            // max offset, at which point it is fully collapsed.
            if deltaContentOffset > 0 {
                // If the scroll view offset is less than the max offset, then the scroll and header offsets should
                // match.
                if contentOffset < state.headerContext.maxOffset {
                    state.headerContext.offset = contentOffset
                }
                // However, if the scroll view is past the max offset, the header must move by the same amount until
                // it reaches the max offset.
                else {
                    state.headerContext.offset = min(
                        state.headerContext.offset + deltaContentOffset,
                        state.headerContext.maxOffset
                    )
                }
            // When scrolling up (a.k.a. swiping down), the header offset remains fixed unless it needs to change to
            // prevent the header from separating from the scroll view content. This threshold is reached when the
            // top of the scroll view reaches the bottom of the header.
            } else {
                // If the scroll view's offset is less than the header's offset, the header must match the scroll view
                // offset to avoid separation.
                if contentOffset < state.headerContext.offset {
                    state.headerContext.offset = contentOffset
                }
            }
        }
        hasScrolledSinceSelected = true
    }
}
