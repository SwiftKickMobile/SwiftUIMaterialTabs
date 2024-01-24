//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct OffsetHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {

    // MARK: - API

    public init(fade: Bool = true) {
        self.fade = fade
    }

    // MARK: - Constants

    // MARK: - Variables

    private let fade: Bool

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .opacity(fade ? (1 - context.unitOffset).clamped01() : 1)
    }
}
