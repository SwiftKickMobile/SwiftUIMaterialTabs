//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

@MainActor
@Observable
class ScrollModel<Tab> where Tab: Hashable {

    // MARK: - API

    var scrollPosition = ScrollPosition()
    private(set) var appeared = false
    private(set) var bottomMargin: CGFloat = 0

    func contentOffsetChanged(_ offset: CGFloat) {
        let oldContentOffset = contentOffset
        contentOffset = -offset
        let deltaOffset = contentOffset - oldContentOffset
        // Only report user-initiated scrolls to the header model. After a programmatic
        // scrollTo(y:), isPositionedByUser is false until the user scrolls again.
        // This replaces the old reservedItem check and the fragile expectingContentOffset
        // single-shot filter.
        if scrollPosition.isPositionedByUser {
            headerModel?.scrolled(tab: tab, contentOffset: contentOffset, deltaContentOffset: deltaOffset)
        }
    }

    func appeared(headerModel: HeaderModel<Tab>?) {
        appeared = true
        self.headerModel = headerModel
        selectedTab = headerModel?.headerContext.selectedTab
        syncContentOffsetWithHeader(appearance: true)
        configureBottomMargin()
    }

    func disappeared() {
        appeared = false
    }

    func selectedTabChanged() {
        guard let headerModel else { return }
        let wasSelected = selectedTab == tab
        selectedTab = headerModel.headerContext.selectedTab
        let isSelected = selectedTab == tab
        // Sync content offset when this tab becomes selected
        if !wasSelected && isSelected {
            syncContentOffsetWithHeader(appearance: false)
        }
    }

    func contentSizeChanged(_ contentSize: CGSize) {
        self.contentSize = contentSize
        configureBottomMargin()
    }

    func headerHeightChanged() {
        syncContentOffsetWithHeader(appearance: false)
    }

    func headerStateChanged() {
        configureBottomMargin()
    }

    init(tab: Tab) {
        self.tab = tab
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    /// Cached header offset from when this tab was last active.
    /// Was previously a copy of the HeaderContext struct; now that HeaderContext is a class,
    /// we cache the individual values instead.
    private var cachedOffset: CGFloat?
    private var cachedHeight: CGFloat?
    private weak var headerModel: HeaderModel<Tab>?
    private var contentSize: CGSize?

    private var selectedTab: Tab? {
        didSet {
            guard let headerModel else { return }
            switch (oldValue == tab, selectedTab == tab) {
            case (true, false):
                // When switching away from this tab, remember the current data so we can
                // calculate the delta on return.
                cachedOffset = headerModel.headerContext.offset
                cachedHeight = headerModel.height
            default: break
            }
        }
    }

    private var contentOffset: CGFloat = 0

    // MARK: Configuring the bottom margin

    private func configureBottomMargin() {
        guard let headerModel, let contentSize else { return }
        bottomMargin = max(0, headerModel.height - contentSize.height - headerModel.headerContext.minTotalHeight)
    }

    // MARK: Adjusting scroll and header state

    /// Scrolls to the desired content offset to maintain continuity when switching tabs after a header height change.
    func syncContentOffsetWithHeader(appearance: Bool) {
        guard appeared, let headerModel,
                tab == headerModel.headerContext.selectedTab || appearance,
                headerModel.tabsRegistered else { return }
        let deltaHeaderOffset: CGFloat
        if let cachedOffset {
            deltaHeaderOffset = headerModel.headerContext.offset - cachedOffset
        } else {
            deltaHeaderOffset = headerModel.headerContext.offset
        }
        cachedOffset = headerModel.headerContext.offset
        cachedHeight = headerModel.height
        switch headerModel.config.crossTabSyncMode {
        case .resetScrollPosition where
            appearance &&
                headerModel.headerContext.offset < headerModel.headerContext.maxOffset &&
                contentOffset > headerModel.headerContext.offset:
            contentOffset = headerModel.headerContext.offset
        // Otherwise, preserve the relative content offset between the header and the scroll view.
        default:
            contentOffset = contentOffset + deltaHeaderOffset
        }
        // Update the header context with this tab's content offset during programmatic sync
        headerModel.contentOffsetChanged(contentOffset)
        // Reset scroll position before setting the target. ScrollPosition conforms to
        // Equatable, so if the target y value is the same as the current position, SwiftUI's
        // binding change detection would ignore it. Resetting to a known-different state first
        // ensures the subsequent scrollTo(y:) is always seen as a change.
        scrollPosition = ScrollPosition()
        scrollPosition.scrollTo(y: contentOffset)
    }
}
