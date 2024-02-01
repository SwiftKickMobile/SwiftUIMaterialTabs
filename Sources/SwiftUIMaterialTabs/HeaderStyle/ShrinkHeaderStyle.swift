//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

/// Header elements shrink as the header scrolls out of view. An optional fade parameter can be enabled for content to discretetly fade away
/// in addition to shrinking. This is typcially applied to the title view or its elements.
public struct ShrinkHeaderStyle<Tab>: HeaderStyle where Tab: Hashable {

    // MARK: - API
    
    /// Constructs a shrink header style.
    /// - Parameters:
    ///   - fade: If `true`, the receiving view fades out as the sticky header scrolls out of view.
    ///   - minimumScale: The minimum scale factor that will be approached as the header scrolls out of view.
    ///   - offsetFactor: Adjust the offset of the view based on scroll position, providing finer grained control over how the header moves while shrinking.
    ///   - anchor: The anchor point on the receiving view to anchor the scale effect.
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
