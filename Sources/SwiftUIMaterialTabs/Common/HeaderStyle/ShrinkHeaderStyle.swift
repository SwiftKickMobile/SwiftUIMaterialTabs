//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct ShrinkHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {

    // MARK: - API

    public init(scaleExponent: CGFloat = 0.35, offsetFactor: CGFloat = 0.35) {
        self.scaleExponent = scaleExponent
        self.offsetFactor = offsetFactor
    }

    // MARK: - Constants

    // MARK: - Variables

    private let scaleExponent: CGFloat
    private let offsetFactor: CGFloat

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .scaleEffect(pow(1 - context.unitOffset, scaleExponent), anchor: .center)
            .offset(CGSize(width: 0, height: context.offset > 0 ? context.offset * offsetFactor : 0))
            .opacity((1 - context.unitOffset).clamped01())
    }
}
