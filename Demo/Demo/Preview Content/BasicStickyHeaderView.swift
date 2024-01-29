//
//  Created by Timothy Moose on 1/29/24.
//

import SwiftUI
import MaterialTabs

struct BasicStickyHeaderView: View {

    var body: some View {
        // The main conainer view.
        StickyHeader(
            // A view builder for the header title that takes a `StickyHeaderContext`. This can be anything.
            headerTitle: { context in
                Text("Header Title")
                    .padding()
            },
            headerBackground: { context in
                // The background can be anything, but is typically a `Color`, `Gradient` or scalable `Image`.
                // The background spans the entire header and top safe area.
                Color.yellow
            },
            // The tab contents.
            content: {
                StickyHeaderScroll() {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<10) { index in
                            Text("Row \(index)")
                                .padding()
                        }
                    }
                    .scrollTargetLayout()
                }
            }
        )
    }
}

#Preview {
    BasicStickyHeaderView()
}
