//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

public struct HeaderContext<Tab> where Tab: Hashable {

    public var selectedTabBinding: Binding<Tab>
    public var offset: CGFloat

    public var selectedTab: Tab {
        selectedTabBinding.wrappedValue
    }

    public init(selectedTab: Binding<Tab>) {
        self.init(selectedTab: selectedTab, offset: 0)
    }

    init(selectedTab: Binding<Tab>, offset: CGFloat) {
        self.selectedTabBinding = selectedTab
        self.offset = offset
    }
}
