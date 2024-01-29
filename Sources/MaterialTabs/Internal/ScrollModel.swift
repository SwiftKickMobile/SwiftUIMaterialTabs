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

    func contentOffsetChanged(_ offset: CGFloat) {
        // Don't report offset change if we've just internally scrolled to sync up with the current header position.
        guard scrollItem != firstItem else { return }
        let oldContentOffset = contentOffset
        contentOffset = -offset
        let deltaOffset = contentOffset - oldContentOffset
        headerModel?.scrolled(tab: tab, offset: contentOffset, deltaOffset: deltaOffset)
    }

    func appeared(headerModel: HeaderModel<Tab>?) {
        appeared = true
        self.headerModel = headerModel
        selectedTab = headerModel?.state.headerContext.selectedTab
        updateContentOffset()
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

    func headerHeightChanged() {
        updateContentOffset()
    }

    init(
        tab: Tab,
        reservedItem: Item?
    ) {
        self.tab = tab
        self.firstItem = reservedItem
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let firstItem: Item?
    private var cachedTabsState: HeaderModel<Tab>.State?
    private weak var headerModel: HeaderModel<Tab>?

    private var selectedTab: Tab? {
        didSet {
            guard let headerModel else { return }
            switch (oldValue == tab, selectedTab == tab) {
            case (true, true): break
            case (false, false): break
            case (false, true):
                // When switching to this tab, update the content offset if needed.
                updateContentOffset()
            case (true, false):
                // When switching away from this tab, remember the current data so we can
                // calculate the delta on return.
                cachedTabsState = headerModel.state
            }
        }
    }

    private var contentOffset: CGFloat = 0

    // MARK: Adjusting scroll and header state

    /// Scrolls to the desired content offset to maintain continuity when switching tabs.
    ///
    /// The formula for calculating the Y component of the unit point for a given item is:
    ///
    /// ````
    /// offset / (scrollView.height - safeArea.top - safeArea.bottom - item.height)
    /// ````
    func updateContentOffset() {
        guard appeared, let headerModel, headerModel.state.tabsRegistered else { return }
        let delta: CGFloat
        if let cachedTabsState {
            delta = headerModel.state.headerContext.offset - cachedTabsState.headerContext.offset
        } else {
            delta = headerModel.state.headerContext.offset
        }
        cachedTabsState = headerModel.state
        contentOffset = contentOffset + delta
        scrollItem = firstItem
        scrollUnitPoint = UnitPoint(
            x: UnitPoint.top.x,
            y: (headerModel.state.headerContext.maxOffset - contentOffset) / (headerModel.state.safeHeight - 1)
        )
        // It is essential to set the scroll item back to `nil` so that we can make
        // future scroll adjustments. Placing this in a task is sufficient for the
        // above scrolling to occur.
        Task {
            scrollItem = nil
        }
    }
}

