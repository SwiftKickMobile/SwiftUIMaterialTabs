//
//  Created by Timothy Moose on 1/28/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DebugScroll: View {

    // MARK: - API

    // MARK: - Constants

    private let titleHeight: CGFloat = 200
    private let rowHeight: CGFloat = 100

    // MARK: - Variables

    @State private var scrollItem: Int?
    @State private var scrollUnitPoint: UnitPoint = .top

    // MARK: - Body

    var body: some View {
        StickyHeader { _ in
            Text("Title").frame(height: titleHeight)
        } headerBackground: { _ in
            Color.yellow.opacity(0.25)
        } content: {
            StickyHeaderScroll(firstItem: 0, scrollItem: $scrollItem, scrollUnitPoint: $scrollUnitPoint) {
                LazyVStack(spacing: 0) {
                    ForEach(0..<25) { index in
                        VStack(spacing: 0) {
                            Rectangle().fill(.black.opacity(0.2)).frame(height: 1)
                            Spacer()
                            Button("Tap Row \(index)") {
                                scrollItem = index
                                //scrollUnitPoint = .init(x: 0, y: (100 + CGFloat(index)*100 / 852))
                                scrollUnitPoint = .init(x: 0, y: unitPointY(index: index))
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
    }

    func unitPointY(index: Int) -> CGFloat {
        let offset: CGFloat = 100
        let y = -offset / 659//658 //(852 - 59 - 34)
        print("XXXX y=\(y)")
        return y
//        return 0.152 * 2
    }
}

#Preview {
    DebugScroll()
}
