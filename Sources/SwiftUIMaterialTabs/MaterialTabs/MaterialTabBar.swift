//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct MaterialTabBar<Tab>: View where Tab: Hashable {

    // MARK: - API

    public enum Label {
        case primary(
            String? = nil,
            icon: (any View)? = nil,
            config: PrimaryTab<Tab>.Config = .init(),
            deselectedConfig: PrimaryTab<Tab>.Config? = nil
        )
        case secondary(
            String,
            config: SecondaryTab<Tab>.Config = .init(),
            deselectedConfig: SecondaryTab<Tab>.Config? = nil
        )
    }

    public enum Sizing {
        case equalWidth
        case proportionalWidth
    }

    public typealias CustomLabel = (
        _ tab: Tab,
        _ context: HeaderContext<Tab>,
        _ tapped: @escaping () -> Void
    ) -> AnyView

    public init(selectedTab: Binding<Tab>, sizing: Sizing = .proportionalWidth, context: HeaderContext<Tab>) {
        _selectedTab = selectedTab
        _selectedTabScroll = State(initialValue: selectedTab.wrappedValue)
        self.sizing = sizing
        self.context = context
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @State private var selectedTabScroll: Tab?
    private let sizing: Sizing
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>
    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @State private var height: CGFloat = 0
    private let context: HeaderContext<Tab>

    // MARK: - Body

    public var body: some View {
        ScrollView(.horizontal) {
            TabBarLayout(fittingWidth: context.width, sizing: sizing) {
                ForEach(tabBarModel.tabs, id: \.self) { tab in
                    tabBarModel.labels[tab]?(
                        tab,
                        headerModel.state.headerContext,
                        {
                            headerModel.selected(tab: tab)
                        }
                    )
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: WidthPreferenceKey.self, value: proxy.size.width)
                        }
                    }
                    .id(tab)
                }
            }
            .scrollTargetLayout()
            .frame(minWidth: context.width)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: TabBarHeightPreferenceKey.self, value: proxy.size.height)
                }
            }
        }
        .scrollPosition(id: $selectedTabScroll, anchor: .center)
        .scrollIndicators(.never)
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: context.width, height: height)
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            self.height = height
        }
        .onChange(of: selectedTab) {
            selectedTabScroll = selectedTab
        }
    }
}

struct MaterialTabBarPreviewView: View {

    // MARK: - API

    init(tabCount: Int, sizing: MaterialTabBar<Int>.Sizing) {
        self.init(tabs: Array(0..<tabCount).map { MaterialTabBar<Int>.Label.secondary("Tab Number \($0)") }, sizing: sizing)
    }
    
    init(tabs: [MaterialTabBar<Int>.Label], sizing: MaterialTabBar<Int>.Sizing) {
        self.tabs = tabs
        self.sizing = sizing
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tabs: [MaterialTabBar<Int>.Label]
    private let sizing: MaterialTabBar<Int>.Sizing
    @State private var selectedTab: Int = 0

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTabBar: { context in
                MaterialTabBar(selectedTab: $selectedTab, sizing: sizing, context: context)
            },
            content: {
                ForEach(Array(tabs.enumerated()), id: \.offset) { (offset, tab) in
                    Text("Content for tab \(offset)")
                        .materialTabItem(tab: offset, label: tab)
                }
            }
        )
    }
}

#Preview("Secondary, equal 1") {
    MaterialTabBarPreviewView(tabCount: 1, sizing: .equalWidth)
}

#Preview("Secondary, equal 3") {
    MaterialTabBarPreviewView(tabCount: 3, sizing: .equalWidth)
}

#Preview("Secondary, equal 8") {
    MaterialTabBarPreviewView(tabCount: 8, sizing: .equalWidth)
}

#Preview("Secondary, proportional") {
    MaterialTabBarPreviewView(
        tabs: [
            .secondary("Tab ABCDE"),
            .secondary("Tab X"),
            .secondary("Tab STSTSTSTST"),
            .secondary("Tab YYY"),
        ],
        sizing: .proportionalWidth
    )
}

#Preview("Primary, proportional") {
    MaterialTabBarPreviewView(
        tabs: [
            .primary("ABCDE", icon: Image(systemName: "medal")),
            .primary("XX", icon: Image(systemName: "lamp.table")),
            .primary("SSSSSSSSS", icon: Image(systemName: "cloud.sun")),
        ],
        sizing: .proportionalWidth
    )
}

#Preview("Primary, equal") {
    MaterialTabBarPreviewView(
        tabs: [
            .primary("ABCDE", icon: Image(systemName: "medal")),
            .primary("XX", icon: Image(systemName: "lamp.table")),
            .primary("SSSSSSSSS", icon: Image(systemName: "cloud.sun")),
        ],
        sizing: .equalWidth
    )
}
