//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct OffsetTitleStyle<Tab>: TitleStyle where Tab: Hashable {

    // MARK: - API

    public init(fade: Bool = true) {
        self.fade = fade
    }

    // MARK: - Constants

    // MARK: - Variables

    private let fade: Bool

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, title: Title) -> some View {
        title
            .opacity(fade ? 1 - context.unitOffset : 1)
    }
}
