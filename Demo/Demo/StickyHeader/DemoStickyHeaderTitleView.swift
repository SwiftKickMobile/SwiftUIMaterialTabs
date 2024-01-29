//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import MaterialTabs

/// The title view for the sticky header demo> The title text shrinks and remains persistent at the top of the title view while the logo image shrinks and fades away.
struct DemoStickyHeaderTitleView: View {

    // MARK: - API

    let context: HeaderContext<NoTab>

    // MARK: - Constants

    private let titleScale: CGFloat = 0.55

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            Text("Sticky Header").font(.title).bold()
                .padding(.vertical, 15)
                // Apply the shrink style to have the text shrink to `titleScale` of its original size.
                // Anchoring to `.top` is required to have the title remain top-aligned.
                .headerStyle(
                    ShrinkHeaderStyle(
                        fade: false,
                        minimumScale: titleScale,
                        offsetFactor: 0,
                        anchor: .top
                    ),
                    context: context
                )
                // In addition, apply the fixed header style to have the title remain in a fixed position.
                // Order matters here. The fixed style must be applied after the shrink style.
                .headerStyle(FixedHeaderStyle(), context: context)
                // Inform the sticky header that it should establish a minimum overall height for the title view
                // by measuring the title text. We pass `scale: titleScale` for the measurement to match the
                // the final text size.
                .minTitleHeight(.content(scale: titleScale))
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
