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
        let oldContentOffset = contentOffset
        contentOffset = -offset
        let deltaOffset = contentOffset - oldContentOffset
        headerModel?.scrolled(tab: tab, offset: contentOffset, deltaOffset: deltaOffset)
    }

    func appeared(headerModel: HeaderModel<Tab>?) {
        appeared = true
        self.headerModel = headerModel
        selectedTab = headerModel?.state.headerContext.selectedTab
    }

    func disappeared() {
        appeared = false
    }

    func selectedTabChanged() {
        // We shouldn't attempt to scroll before appearance (it isn't reliable) so we just bail out in that case.
        // The selected tab will be updated in `appeared` anyway if we don't do it here.
        guard appeared, let headerModel else { return }
        selectedTab = headerModel.state.headerContext.selectedTab
    }

    func scrollItemChanged(_ item: Item?) {
        scrollItem = item
    }

    func scrollUnitPointChanged(_ unitPoint: UnitPoint) {
        scrollUnitPoint = unitPoint
    }

    init(
        tab: Tab,
        firstItem: Item
    ) {
        self.tab = tab
        self.firstItem = firstItem
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let firstItem: Item
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

    private var isSelected: Bool {
        tab == selectedTab
    }

    private var contentOffset: CGFloat = 0

    // MARK: Adjusting scroll and header state

    func updateContentOffset() {
        guard isSelected else { return }
        guard let headerModel else { return }
        let delta: CGFloat
        if let cachedTabsState {
            let deltaHeaderHeight = headerModel.state.headerContext.totalHeight - cachedTabsState.headerContext.totalHeight
            let deltaHeaderOffset = headerModel.state.headerContext.offset - cachedTabsState.headerContext.offset
            delta = deltaHeaderHeight + deltaHeaderOffset
        } else {
            delta = headerModel.state.headerContext.offset
        }
        cachedTabsState = headerModel.state
        contentOffset = contentOffset + delta
        scrollItem = firstItem
        scrollUnitPoint = UnitPoint(
            x: UnitPoint.top.x,
            y: -contentOffset / headerModel.state.scrollViewHeight
        )
        // It is essential to set the scroll item back to `nil` so that we can make
        // future scroll adjustments. Placing this in a task is sufficient for the
        // above scrolling to occur.
        Task {
            scrollItem = nil
        }
    }
}

