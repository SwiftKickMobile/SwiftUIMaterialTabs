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
    @State private var scrollPosition = ScrollPosition(idType: Int.self)
    @State private var scrollAnchor: UnitPoint? = .top

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTitle: { _ in
                Text("Title").frame(height: titleHeight)
            },
            headerTabBar: { context in
                HStack(spacing: 0) {
                    ForEach(0..<2) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text("Tab \(tab)")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                        }
                    }
                }
                .frame(height: tabBarHeight)
            },
            headerBackground: { _ in
                Color.yellow.opacity(0.25)
            }
        ) {
            MaterialTabsScroll(
                tab: 0,
                scrollPosition: $scrollPosition,
                anchor: $scrollAnchor
            ) { _ in
                LazyVStack(spacing: 0) {
                    ForEach(0..<25) { index in
                        VStack(spacing: 0) {
                            Rectangle().fill(.black.opacity(0.2)).frame(height: 1)
                            Spacer()
                            HStack {
                                Text("Row \(index)")
                                Spacer()
                                Button("Top") {
                                    withAnimation {
                                        scrollAnchor = .top
                                        scrollPosition.scrollTo(id: index, anchor: .top)
                                    }
                                }
                                Button("Bottom") {
                                    withAnimation {
                                        scrollAnchor = .bottom
                                        scrollPosition.scrollTo(id: index, anchor: .bottom)
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            .padding(.horizontal)
                            Spacer()
                        }
                        .frame(height: rowHeight)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .materialTabItem(tab: 0, label: .secondary("Tab 0"))
            MaterialTabsScroll(tab: 1) { _ in
                LazyVStack(spacing: 0) {
                    ForEach(0..<25) { index in
                        VStack(spacing: 0) {
                            Rectangle().fill(.black.opacity(0.2)).frame(height: 1)
                            Spacer()
                            Text("Tab 1 — Row \(index)")
                            Spacer()
                        }
                        .frame(height: rowHeight)
                    }
                }
            }
            .materialTabItem(tab: 1, label: .secondary("Tab 1"))
        }
    }
}

#Preview {
    TestMaterialTabsScroll()
}
