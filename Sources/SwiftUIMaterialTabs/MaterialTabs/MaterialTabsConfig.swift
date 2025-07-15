//
//  Created by Timothy Moose on 9/19/24.
//

import SwiftUI

public struct MaterialTabsConfig: Equatable {

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

    /// Specifies how the scroll view and header adjust to maintain continuity when switching tabs.
    public var crossTabSyncMode: CrossTabSyncMode = .resetTitleOnScroll()
    
    /// Configuration for sticky header behavior, including scroll-up snap behavior.
    public var headerConfig: HeaderConfig = HeaderConfig()

    /// Creates a new MaterialTabsConfig.
    /// - Parameters:
    ///   - crossTabSyncMode: The cross-tab synchronization mode. Defaults to `.resetTitleOnScroll()`.
    ///   - headerConfig: The header configuration. Defaults to `HeaderConfig()` with current behavior.
    public init(
        crossTabSyncMode: CrossTabSyncMode = .resetTitleOnScroll(),
        headerConfig: HeaderConfig = HeaderConfig()
    ) {
        self.crossTabSyncMode = crossTabSyncMode
        self.headerConfig = headerConfig
    }
}
