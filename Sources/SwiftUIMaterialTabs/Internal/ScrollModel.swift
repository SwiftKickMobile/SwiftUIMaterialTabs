//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

@MainActor
class ScrollModel<ItemID, Tab>: ObservableObject where ItemID: Hashable, Tab: Hashable {

    // MARK: - API

    @Published var scrollItemID: ItemID?
    @Published var scrollUnitPoint: UnitPoint = .top
    @Published private(set) var appeared = false

    func contentOffsetChanged(_ offset: CGFloat) {
        let oldContentOffset = contentOffset
        contentOffset = -offset
        let deltaOffset = contentOffset - oldContentOffset
        tabsModel?.scrolled(tab: tab, offset: contentOffset, deltaOffset: deltaOffset)
    }

    func appeared(tabsModel: TabsModel<Tab>?) {
        appeared = true
        self.tabsModel = tabsModel
        selectedTab = tabsModel?.state.headerContext.selectedTab
    }

    func disappeared() {
        appeared = false
    }

    func selectedTabChanged() {
        // We shouldn't attempt to scroll before appearance (it isn't reliable) so we just bail out in that case.
        // The selected tab will be updated in `appeared` anyway if we don't do it here.
        guard appeared, let tabsModel else { return }
        selectedTab = tabsModel.state.headerContext.selectedTab
    }

    func scrollItemIDChanged(_ itemID: ItemID?) {
        scrollItemID = itemID
    }

    func scrollUnitPointChanged(_ unitPoint: UnitPoint) {
        scrollUnitPoint = unitPoint
    }

    init(
        tab: Tab,
        firstItemID: ItemID
    ) {
        self.tab = tab
        self.firstItemID = firstItemID
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let firstItemID: ItemID
    private var cachedTabsState: TabsModel<Tab>.State?
    private weak var tabsModel: TabsModel<Tab>?

    private var selectedTab: Tab? {
        didSet {
            guard let tabsModel else { return }
            switch (oldValue == tab, selectedTab == tab) {
            case (true, true): break
            case (false, false): break
            case (false, true):
                // When switching to this tab, update the content offset if needed.
                updateContentOffset()
            case (true, false):
                // When switching away from this tab, remember the current data so we can
                // calculate the delta on return.
                cachedTabsState = tabsModel.state
            }
        }
    }

    private var isSelected: Bool {
        tab == selectedTab
    }

    private var contentOffset: CGFloat = 0

    // MARK: Adjusting scroll and header state

    func updateContentOffset() {
        guard isSelected else { return }
        guard let tabsModel else { return }
        let delta: CGFloat
        if let cachedTabsState {
            let deltaHeaderHeight = tabsModel.state.headerContext.totalHeight - cachedTabsState.headerContext.totalHeight
            let deltaHeaderOffset = tabsModel.state.headerContext.offset - cachedTabsState.headerContext.offset
            delta = deltaHeaderHeight + deltaHeaderOffset
        } else {
            delta = tabsModel.state.headerContext.offset
        }
        cachedTabsState = tabsModel.state
        contentOffset = contentOffset + delta
        scrollItemID = firstItemID
        scrollUnitPoint = UnitPoint(
            x: UnitPoint.top.x,
            y: -contentOffset / tabsModel.state.scrollViewHeight
        )
        // It is essential to set the scroll item back to `nil` so that we can make
        // future scroll adjustments. Placing this in a task is sufficient for the
        // above scrolling to occur.
        Task {
            scrollItemID = nil
        }
    }
}

