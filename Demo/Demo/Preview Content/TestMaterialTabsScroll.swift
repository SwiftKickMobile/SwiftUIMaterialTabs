//
//  Created by Timothy Moose on 1/29/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct TestMaterialTabsScroll: View {

    // MARK: - API

    // MARK: - Constants

    private let titleHeight: CGFloat = 150
    private let tabBarHeight: CGFloat = 50
    private let rowHeight: CGFloat = 100

    // MARK: - Variables

    @State private var selectedTab = 0
    @State private var scrollItem: Int?
    @State private var scrollUnitPoint: UnitPoint = .top

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTitle: { _ in
                Text("Title").frame(height: titleHeight)
            },
            headerTabBar: { context in
                Text("Tab Bar").frame(height: tabBarHeight)
            },
            headerBackground: { _ in
                Color.yellow.opacity(0.25)
            }
        ) {
            MaterialTabsScroll(
                tab: 0,
                reservedItem: -1,
                scrollItem: $scrollItem,
                scrollUnitPoint: $scrollUnitPoint
            ) { _ in
                LazyVStack(spacing: 0) {
                    ForEach(0..<25) { index in
                        VStack(spacing: 0) {
                            Rectangle().fill(.black.opacity(0.2)).frame(height: 1)
                            Spacer()
                            Button("Tap Row \(index)") {
                                scrollUnitPoint = .top
                                scrollItem = index
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
        .animation(.default, value: scrollItem)
    }
}

#Preview {
    TestMaterialTabsScroll()
}
