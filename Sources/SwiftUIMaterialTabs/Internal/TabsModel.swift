//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

struct TabsModelKey: SwiftUI.EnvironmentKey {
    @MainActor
    static var defaultValue: TabsModel = TabsModel(initialTab: 0)
}

extension EnvironmentValues {
    var materialTabsModel: TabsModel {
        get { self[TabsModelKey.self] }
        set { self[TabsModelKey.self] = newValue }
    }
}

@MainActor
class TabsModel: ObservableObject {

    // MARK: - API

    struct Data: Equatable {
        var titleHeight: CGFloat = 0
        var tabBarHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var headerOffset: CGFloat = 0

        var headerHeight: CGFloat { titleHeight + tabBarHeight }
        var scrollViewHeight: CGFloat { totalHeight - headerHeight }
        var offsetPercentage: CGFloat { (titleHeight - headerOffset) / titleHeight }

        var maxOffset: CGFloat { headerHeight - tabBarHeight }
    }

    @Published fileprivate(set) var data: Data = Data()
    @Published fileprivate(set) var selectedTab: AnyHashable = 0

    init(initialTab: any Hashable) {
        self.selectedTab = AnyHashable(initialTab)
    }

    func heightChanged(_ height: CGFloat) {
        data.totalHeight = height
    }

    func titleHeightChanged(_ height: CGFloat) {
        data.titleHeight = height
    }

    func tabBarHeightChanged(_ height: CGFloat) {
        data.tabBarHeight = height
    }

    func selected(tab: any Hashable) {
        self.selectedTab = AnyHashable(tab)
    }

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - MaterialTabsModel

    func scrolled(tab: any Hashable, offset: CGFloat, deltaOffset: CGFloat) {
        // Any time the offset is less than the max offset, the header offset exactly tracks the offset.
        if offset < data.maxOffset {
            data.headerOffset = offset
        }
        // However, for greater offsets, the header offset only gets adjusted for positive changes in the offset.
        // Once we scroll too far, the header offset hits the limit, so we can't just track the offset. Instead, we
        // use the change in offset.
        else if deltaOffset > 0 {
            let unconstrainedOffset = data.headerOffset + deltaOffset
            data.headerOffset = min(unconstrainedOffset, data.maxOffset)
        }
    }
}
