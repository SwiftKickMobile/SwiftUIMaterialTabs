//
//  Created by Timothy Moose on 2/16/24.
//

import Foundation

public struct MaterialTabsScrollContext<Tab> where Tab: Hashable {
    /// The header context
    var headerContext: MaterialTabsHeaderContext<Tab>

    /// The total safe height available to the scroll view
    var safeHeight: CGFloat

    /// The total safe height available for content below the header view
    var contentHeight: CGFloat {
        safeHeight - headerContext.height
    }
}
