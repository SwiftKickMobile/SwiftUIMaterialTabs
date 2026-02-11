//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

@MainActor
@Observable
class HeaderModel<Tab> where Tab: Hashable {

    // MARK: - API

    let headerContext: HeaderContext<Tab>

    /// The height reported by the geometry reader. Includes the additional safe area padding we apply.
    var height: CGFloat = 0

    var tabsRegistered: Bool = false

    /// The height factoring in the additional safe area padding we apply.
    var safeHeight: CGFloat {
        height - headerContext.minTotalHeight
    }

    var config: MaterialTabsConfig = MaterialTabsConfig()

    init(selectedTab: Tab) {
        self.headerContext = HeaderContext(selectedTab: selectedTab)
    }

    func configChanged(_ config: MaterialTabsConfig) {
        self.config = config
    }

    func sizeChanged(_ size: CGSize) {
        height = size.height
        headerContext.width = size.width
    }

    func titleHeightChanged(_ height: CGFloat) {
        headerContext.titleHeight = height
    }

    func minTitleHeightChanged(_ metric: MinTitleHeightPreferenceKey.Metric) {
        headerContext.minTitleMetric = metric
    }

    func tabBarHeightChanged(_ height: CGFloat) {
        headerContext.tabBarHeight = height
    }

    func selected(tab: Tab) {
        hasScrolledSinceSelected = false
        headerContext.selectedTab = tab
    }

    func safeAreaChanged(_ safeArea: EdgeInsets) {
        headerContext.safeArea = safeArea
    }

    func animationNamespaceChanged(_ animationNamespace: Namespace.ID) {
        headerContext.animationNamespace = animationNamespace
    }

    func onTabsRegistered() {
        Task {
            guard !tabsRegistered else { return }
            self.tabsRegistered = true
        }
    }

    func contentOffsetChanged(_ contentOffset: CGFloat) {
        headerContext.contentOffset = contentOffset
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
        guard tab == headerContext.selectedTab else { return }
        switch config.crossTabSyncMode {
        case .resetTitleOnScroll where !hasScrolledSinceSelected:
            withAnimation(.snappy(duration: 0.3)) {
                headerContext.offset = min(headerContext.maxOffset, contentOffset)
            }
        default:
            headerContext.contentOffset = contentOffset
            // When scrolling down (a.k.a. swiping up), the header offset matches the scroll view until it reaches the
            // max offset, at which point it is fully collapsed.
            if deltaContentOffset > 0 {
                // If the scroll view offset is less than the max offset, then the scroll and header offsets should
                // match.
                if contentOffset < headerContext.maxOffset {
                    headerContext.offset = contentOffset
                }
                // However, if the scroll view is past the max offset, the header must move by the same amount until
                // it reaches the max offset.
                else {
                    headerContext.offset = min(
                        headerContext.offset + deltaContentOffset,
                        headerContext.maxOffset
                    )
                }
            // When scrolling up (a.k.a. swiping down), the header offset remains fixed unless it needs to change to
            // prevent the header from separating from the scroll view content. This threshold is reached when the
            // top of the scroll view reaches the bottom of the header.
            } else {
                // If the scroll view's offset is less than the header's offset, the header must match the scroll view
                // offset to avoid separation.
                if contentOffset < headerContext.offset {
                    headerContext.offset = contentOffset
                }
            }
        }
        hasScrolledSinceSelected = true
    }
}
