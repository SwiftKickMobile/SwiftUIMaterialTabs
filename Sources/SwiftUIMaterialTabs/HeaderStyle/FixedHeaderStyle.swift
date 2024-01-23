//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI

public struct FixedHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {

    // MARK: - API

    public init() {
    }

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .offset(CGSize(width: 0, height: context.offset > 0 ? context.offset : 0))
    }
}
