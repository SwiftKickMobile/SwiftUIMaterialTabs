//
//  Created by Timothy Moose on 1/28/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DebugScroll: View {

    // MARK: - API

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        StickyHeader { _ in
            Text("Title").padding(40)
        } headerBackground: { _ in
            Color.yellow
        } content: {
            StickyHeaderScroll() {
                ForEach(0..<25) { index in
                    VStack(spacing: 0) {
                        Rectangle().fill(.black.opacity(0.2)).frame(height: 1)
                        Spacer()
                        Button("Tap Row \(index)") {

                        }
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                    .frame(height: 100)
                }
            }
        }

    }
}

#Preview {
    DebugScroll()
}
