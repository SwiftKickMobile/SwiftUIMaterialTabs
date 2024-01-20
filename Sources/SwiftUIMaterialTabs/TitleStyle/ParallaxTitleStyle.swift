//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct ParallaxTitleStyle<Tab>: TitleStyle where Tab: Hashable {

    // MARK: - API

    public init(amount: CGFloat = 0.35, fade: Bool = true) {
        self.amount = amount
        self.fade = fade
    }

    // MARK: - Constants

    // MARK: - Variables

    private let amount: CGFloat
    private let fade: Bool

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, title: Title) -> some View {
        title
            .offset(CGSize(width: 0, height: context.offset * amount))
            .opacity(fade ? 1 - context.unitOffset : 1)
    }
}
