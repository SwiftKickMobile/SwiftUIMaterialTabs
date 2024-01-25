//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct ShrinkHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {

    // MARK: - API

    public init(
        fade: Bool = true,
        minimumScale: CGFloat = 0.5,
        offsetFactor: CGFloat = 0.35,
        anchor: UnitPoint = .center
    ) {
        self.fade = fade
        self.minimumScale = minimumScale
        self.offsetFactor = offsetFactor
        self.anchor = anchor
    }

    // MARK: - Constants

    // MARK: - Variables

    private let fade: Bool
    private let minimumScale: CGFloat
    private let offsetFactor: CGFloat
    private let anchor: UnitPoint

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, content: Content) -> some View {
        content
            .scaleEffect(scale(unitOffset: context.unitOffset), anchor: anchor)
            .offset(CGSize(width: 0, height: context.offset > 0 ? context.offset * offsetFactor : 0))
            .opacity(fade ? (1 - context.unitOffset).clamped01() : 1)
    }

    // MARK: - Calculations

    private func scale(unitOffset: CGFloat) -> CGFloat {
        let easedOffset = unitOffset
        let scale = 1 - easedOffset + easedOffset * minimumScale
        return scale
    }
}
