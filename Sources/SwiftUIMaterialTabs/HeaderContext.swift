//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

public struct HeaderContext<Tab> where Tab: Hashable {

    public var selectedTabBinding: Binding<Tab>

    // The current scroll offset, raning from 0 to `maxOffset`. Use this value
    // to transition header elements between expanded and collapsed states.
    public var offset: CGFloat

    // The scroll offset corresponding to the header's fully collapsed state.
    public var maxOffset: CGFloat

    // The offset as a value ranging from 0 to 1, with 1 corresponding to an absolute offset of `maxOffset`.
    public var unitOffset: CGFloat

    public var selectedTab: Tab {
        selectedTabBinding.wrappedValue
    }

    public init(selectedTab: Binding<Tab>) {
        self.init(selectedTab: selectedTab, offset: 0, maxOffset: 1)
    }

    init(selectedTab: Binding<Tab>, offset: CGFloat, maxOffset: CGFloat) {
        self.selectedTabBinding = selectedTab
        self.offset = offset
        self.maxOffset = maxOffset
        self.unitOffset = maxOffset == 0 ? 0 : offset / maxOffset
    }
}
