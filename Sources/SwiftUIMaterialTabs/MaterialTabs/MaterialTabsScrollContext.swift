//
//  Created by Timothy Moose on 2/16/24.
//

import Foundation

public struct MaterialTabsScrollContext<Tab> where Tab: Hashable {
    /// The header context
    public var headerContext: MaterialTabsHeaderContext<Tab>

    /// The total safe height available to the scroll view
    public var safeHeight: CGFloat

    /// The total safe height available for content below the header view
    public var contentHeight: CGFloat {
        safeHeight - headerContext.height
    }

    public init(headerContext: MaterialTabsHeaderContext<Tab>, safeHeight: CGFloat) {
        self.headerContext = headerContext
        self.safeHeight = safeHeight
    }
}
