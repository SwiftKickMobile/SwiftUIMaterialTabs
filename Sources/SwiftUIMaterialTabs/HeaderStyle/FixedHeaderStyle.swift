//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI

/// Header elements are fixed in place, independent of content scrolling. This is typically used to create persistent title elements in combination with
/// the `minTitleHeight()` view modifier.
public struct FixedHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {

    // MARK: - API
    
    /// Constructs a fixed header style.
    /// - Parameter fade: If `true`, the receiving view fades out as the sticky header scrolls out of view.
    public init(fade: Bool = false) {
        self.fade = fade
    }

    // MARK: - Constants

    // MARK: - Variables

    private let fade: Bool

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .offset(CGSize(width: 0, height: context.offset > 0 ? context.offset : 0))
            .opacity(fade ? (1 - context.unitOffset).clamped01() : 1)
    }
}
