//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

@MainActor
class ScrollModel<Item, Tab>: ObservableObject where Item: Hashable, Tab: Hashable {

    // MARK: - API

    @Published var scrollItem: Item?
    @Published var scrollUnitPoint: UnitPoint = .top
    @Published private(set) var appeared = false
    @Published private(set) var bottomMargin: CGFloat = 0

    func contentOffsetChanged(_ offset: CGFloat) {
        let oldContentOffset = contentOffset
        contentOffset = -offset
        let deltaOffset = contentOffset - oldContentOffset
        // This is how we're detecting programatic scroll for lack of a better idea. We don't want to report
        // the programatic sync of content offset with the header because it could result in the header moving.
        guard scrollItem != reservedItem else { return }
        headerModel?.scrolled(tab: tab, contentOffset: contentOffset, deltaContentOffset: deltaOffset)
    }

    func appeared(headerModel: HeaderModel<Tab>?) {
        appeared = true
        self.headerModel = headerModel
        selectedTab = headerModel?.state.headerContext.selectedTab
        syncContentOffsetWithHeader()
        configureBottomMargin()
    }

    func disappeared() {
        appeared = false
    }

    func selectedTabChanged() {
        guard let headerModel else { return }
        selectedTab = headerModel.state.headerContext.selectedTab
    }

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
        syncContentOffsetWithHeader()
    }

    func headerStateChanged() {
        configureBottomMargin()
    }

    init(
        tab: Tab,
        reservedItem: Item?
    ) {
        self.tab = tab
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
            case (true, true): break
            case (false, false): break
            case (false, true):
                // When switching to this tab, update the content offset if needed.
                syncContentOffsetWithHeader()
            case (true, false):
                // When switching away from this tab, remember the current data so we can
                // calculate the delta on return.
                cachedTabsState = headerModel.state
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
    func syncContentOffsetWithHeader() {
        guard appeared, let headerModel,
                tab == headerModel.state.headerContext.selectedTab,
                headerModel.state.tabsRegistered else { return }
        let deltaHeaderOffset: CGFloat
        if let cachedTabsState {
            deltaHeaderOffset = headerModel.state.headerContext.offset - cachedTabsState.headerContext.offset
        } else {
            deltaHeaderOffset = headerModel.state.headerContext.offset
        }
        cachedTabsState = headerModel.state
        //print("syncContentOffsetWithHeader tab=\(tab), contentOffset=\(contentOffset), targetContentOffset=\(contentOffset + deltaHeaderOffset), deltaHeaderOffset=\(deltaHeaderOffset)")
        contentOffset = contentOffset + deltaHeaderOffset
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
    }
}

