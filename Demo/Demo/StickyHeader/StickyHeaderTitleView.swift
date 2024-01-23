//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct StickyHeaderTitle: View {

    // MARK: - API

    let context: HeaderContext<Int>

    // MARK: - Constants

    private let titleScale: CGFloat = 0.45

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        VStack(spacing: 30) {
            Text("Sticky Header").font(.title).bold()
                .padding(.vertical, 15)
                .scaleEffect(1 - context.unitOffset * titleScale, anchor: .top)
                .minTitleHeight(dimension: .content(scale: titleScale))
                .headerStyle(FixedHeaderStyle(), context: context)
            Image(.swiftkickLogoBlack)
                .headerStyle(ShrinkHeaderStyle(offsetFactor: 0.35), context: context)
            Rectangle()
                .fill(.black.opacity(0.05))
                .frame(height: 1)
        }
    }
}
