//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct MaterialTabBar<Tab>: View where Tab: Hashable {

    // MARK: - API

    public enum Label {
        case primary(title: String, icon: Image)
        case secondary(title: String)
    }

    public enum Sizing {
        case equal
        case proportional
    }

    public typealias CustomLabel = (_ isSelected: Bool, _ tapped: @escaping () -> Void, _ context: HeaderContext<Tab>) -> AnyView

    public init(selectedTab: Binding<Tab>, sizing: Sizing = .proportional, context: HeaderContext<Tab>) {
        _selectedTab = selectedTab
        self.sizing = sizing
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    private let sizing: Sizing
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>
    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @State private var size: CGSize = .zero

    // MARK: - Body

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(Array(tabBarModel.tabs.enumerated()), id: \.offset) { (offset, tab) in
                    tabBarModel.labels[tab]?(
                        selectedTab == tab,
                        {
                            headerModel.selected(tab: tab)
                        },
                        headerModel.state.headerContext
                    )
                }
            }
            .frame(minWidth: size.width)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: TabBarHeightPreferenceKey.self, value: proxy.size.height)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthPreferenceKey.self, value: proxy.size.width)
            }
        }
        .frame(height: size.height)
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            size.height = height
        }
        .onPreferenceChange(WidthPreferenceKey.self) { width in
            size.width = width
        }
    }
}

struct MaterialTabBarPreviewView: View {

    // MARK: - API

    let tabCount: Int
    @State var selectedTab = 0

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTabBar: { context in
                MaterialTabBar(selectedTab: $selectedTab, context: context)
            },
            content: {
                ForEach(0..<4) { tab in
                    Text("Tab Content \(tab)")
                        .materialTabItem(tab: tab, label: .secondary(title: "Tab \(tab)"))
                }
            }
        )
    }
}

//#Preview {
//    MaterialTabBarPreviewView(tabCount: 1)
//}
//
//#Preview {
//    MaterialTabBarPreviewView(tabCount: 2)
//}
//
//#Preview {
//    MaterialTabBarPreviewView(tabCount: 3)
//}

#Preview {
    MaterialTabBarPreviewView(tabCount: 4)
}
