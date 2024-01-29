//
//  Created by Timothy Moose on 1/28/24.
//

import SwiftUI
import MaterialTabs

struct DebugScroll: View {

    // MARK: - API

    // MARK: - Constants

    private let titleHeight: CGFloat = 200
    private let rowHeight: CGFloat = 100

    // MARK: - Variables

    @State private var scrollItem: Int?
    @State private var scrollUnitPoint: UnitPoint = .top
    @State private var scrollItem2: ScrollItem?

    // MARK: - Body

    var body: some View {
        StickyHeader { _ in
            Text("Title").frame(height: titleHeight)
                .minTitleHeight(.absolute(50))
        } headerBackground: { _ in
            Color.yellow.opacity(0.25)
        } content: {
            StickyHeaderScroll() {
                VStack {
                    Color.clear.frame(height: 1)
                        .id(ScrollItem.item)
                    LazyVStack(spacing: 0) {
                        ForEach(0..<25) { index in
                            VStack(spacing: 0) {
                                Rectangle().fill(.black.opacity(0.2)).frame(height: 1)
                                Spacer()
                                Button("Tap Row \(index)") {
                                    scrollUnitPoint = .top
//                                    scrollItem = index
                                    scrollItem2 = .item
                                }
                                .buttonStyle(.bordered)
                                Spacer()
                            }
                            .frame(height: rowHeight)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollPosition(id: $scrollItem2, anchor: scrollUnitPoint)
            .scrollPosition(id: $scrollItem, anchor: scrollUnitPoint)
        }.animation(.default, value: scrollItem)
    }
}

#Preview {
    DebugScroll()
}
