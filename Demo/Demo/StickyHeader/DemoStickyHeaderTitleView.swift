//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

/// The title view for the sticky header demo> The title text shrinks and remains persistent at the top of the title view while the logo image shrinks and fades away.
struct DemoStickyHeaderTitleView: View {

    // MARK: - API

    let context: HeaderContext<NoTab>

    // MARK: - Constants

    private let titleScale: CGFloat = 0.45

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            Text("Sticky Header").font(.title).bold()
                .padding(.vertical, 15)
                // Shrink the title text down to the original size * `1 - titleScale`. The
                // scale effect must be anchored `.top` to keep the title top aligned.
                .scaleEffect(1 - context.unitOffset * titleScale, anchor: .top)
                // Set the the minimum height for the title view based on the measured height of
                // the title text + padding. Apply a scale factor that matches the scale effect so
                // that the min height matches the final scaled height. Note that the scale effect
                // itself doesn't affect the measured height of the view it modifiers, so the ordering of these
                // modifiers doesn't matter.
                .minTitleHeight(.content(scale: 1 - titleScale))
                // Apply the fixed header style to have the title text maintain a fixed top-alinged position.
                .headerStyle(FixedHeaderStyle(), context: context)
            Image(.swiftkickLogoBlack)
                // Apply the shrink header style to the logo image so that it shrinks and fades out of view.
                .headerStyle(ShrinkHeaderStyle(), context: context)
                .padding(.bottom, 10)
            Rectangle()
                .fill(.black.opacity(0.05))
                .frame(height: 1)
        }
    }
}
