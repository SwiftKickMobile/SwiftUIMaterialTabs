//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

@MainActor
class ScrollModel<Item, Tab>: ObservableObject where Item: Hashable, Tab: Hashable {

    // MARK: - API

    #if canImport(ScrollPosition)
    @Published var scrollPosition: ScrollPosition = ScrollPosition(idType: Item.self)
    #endif
    @Published var scrollItem: Item?
    @Published var scrollUnitPoint: UnitPoint = .top
    @Published private(set) var appeared = false
    @Published private(set) var bottomMargin: CGFloat = 0

    let scrollMode: ScrollMode

    func contentOffsetChanged(_ offset: CGFloat) {
        let oldContentOffset = contentOffset
        contentOffset = -offset
        let deltaOffset = contentOffset - oldContentOffset
        switch scrollMode {
        case .scrollAnchor:
            // This is how we're detecting programatic scroll for lack of a better idea. We don't want to report
            // the programatic sync of content offset with the header because it could result in the header moving.
            if scrollItem != reservedItem {
                headerModel?.scrolled(tab: tab, contentOffset: contentOffset, deltaContentOffset: deltaOffset)
            }
        case .scrollPosition:
            #if canImport(ScrollPosition)
            if expectingContentOffset != contentOffset {
                headerModel?.scrolled(tab: tab, contentOffset: contentOffset, deltaContentOffset: deltaOffset)
            }
            #endif
        }
    }

    func appeared(headerModel: HeaderModel<Tab>?) {
        appeared = true
        self.headerModel = headerModel
        selectedTab = headerModel?.state.headerContext.selectedTab
        syncContentOffsetWithHeader(appearance: true)
        configureBottomMargin()
    }

    func disappeared() {
        appeared = false
    }

    func selectedTabChanged() {
        guard let headerModel else { return }
        let wasSelected = selectedTab == tab
        selectedTab = headerModel.state.headerContext.selectedTab
        let isSelected = selectedTab == tab
        // Sync content offset when this tab becomes selected
        if !wasSelected && isSelected {
            syncContentOffsetWithHeader(appearance: false)
        }
    }

    #if canImport(ScrollPosition)
    func scrollPositionChanged(_ position: ScrollPosition) {
        scrollPosition = position
    }
    #endif

    func scrollItemChanged(_ item: Item?) {
        scrollItem = item
    }

    func scrollUnitPointChanged(_ unitPoint: UnitPoint) {
        scrollUnitPoint = unitPoint
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

    enum ScrollMode {
        case scrollAnchor
        case scrollPosition
    }

    init(
        tab: Tab,
        scrollMode: ScrollMode,
        reservedItem: Item?
    ) {
        self.tab = tab
        self.scrollMode = scrollMode
        self.reservedItem = reservedItem
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let reservedItem: Item?
    private var cachedTabsState: HeaderModel<Tab>.State?
    private weak var headerModel: HeaderModel<Tab>?
    private var expectingContentOffset: CGFloat?
    private var contentSize: CGSize?

    private var selectedTab: Tab? {
        didSet {
            guard let headerModel else { return }
            switch (oldValue == tab, selectedTab == tab) {
            case (true, false):
                // When switching away from this tab, remember the current data so we can
                // calculate the delta on return.
                cachedTabsState = headerModel.state
            default: break
            }
        }
    }

    private var contentOffset: CGFloat = 0

    // MARK: Configuring the bottom margin

    private func configureBottomMargin() {
        guard let headerModel, let contentSize else { return }
        bottomMargin = max(0, headerModel.state.height - contentSize.height - headerModel.state.headerContext.minTotalHeight)
    }

    // MARK: Adjusting scroll and header state

    /// Scrolls to the desired content offset to maintain continuity when switching tabs after a header height change.
    ///
    /// The formula for calculating the Y component of the unit point for a given item is:
    ///
    /// ````
    /// offset / (scrollView.height - safeArea.top - safeArea.bottom - item.height)
    /// ````
    func syncContentOffsetWithHeader(appearance: Bool) {
        guard appeared, let headerModel,
                tab == headerModel.state.headerContext.selectedTab || appearance,
                headerModel.state.tabsRegistered else { return }
        let deltaHeaderOffset: CGFloat
        if let cachedTabsState {
            deltaHeaderOffset = headerModel.state.headerContext.offset - cachedTabsState.headerContext.offset
        } else {
            deltaHeaderOffset = headerModel.state.headerContext.offset
        }
        cachedTabsState = headerModel.state
        switch headerModel.state.config.crossTabSyncMode {
        case .resetScrollPosition where
            appearance &&
                headerModel.state.headerContext.offset < headerModel.state.headerContext.maxOffset &&
                contentOffset > headerModel.state.headerContext.offset:
            contentOffset = headerModel.state.headerContext.offset
        // Otherwise, preserve the relative content offset between the header and the scroll view.
        default:
            contentOffset = contentOffset + deltaHeaderOffset
        }
        // Update the header context with this tab's content offset during programmatic sync
        headerModel.contentOffsetChanged(contentOffset)
        switch scrollMode {
        case .scrollAnchor:
            scrollUnitPoint = UnitPoint(
                x: UnitPoint.top.x,
                y: (headerModel.state.headerContext.maxOffset - contentOffset) / (headerModel.state.safeHeight - 1)
            )
            scrollItem = reservedItem
            // It is essential to set the scroll item back to `nil` so that we can make
            // future scroll adjustments. Placing this in a task is sufficient for the
            // above scrolling to occur.
            Task {
                // Could not find a 100% robust way to detect between a programatic scroll and a user scroll, which we
                // need to be able to do to avoid adjusting the header after a programatic scroll. So, sadly, we're going
                // this instead and rely on checking the value of `scrollItem`.
                try? await Task.sleep(for: .seconds(0.05))
                scrollItem = nil
            }
        case .scrollPosition:
            #if canImport(ScrollPosition)
            scrollPosition = ScrollPosition(point: CGPoint(x: 0.5, y: 150))
            #endif
        }
    }
}

