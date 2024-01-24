//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct ParallaxHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {

    // MARK: - API

    public init(amount: CGFloat = 0.35, fade: Bool = true, rubberBandingScaleExponent: CGFloat = 1) {
        self.amount = amount
        self.fade = fade
        self.rubberBandingScaleExponent = rubberBandingScaleExponent
    }

    // MARK: - Constants

    // MARK: - Variables

    private let amount: CGFloat
    private let fade: Bool
    private let rubberBandingScaleExponent: CGFloat

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .offset(CGSize(width: 0, height: context.offset < 0 ? 0 : context.offset * amount))
            .opacity(fade ? (1 - context.unitOffset).clamped01() : 1)
    }
}
