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
    @State private var minTabWidth: CGFloat = 0

    // MARK: - Body

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(tabBarModel.tabs, id: \.self) { tab in
                    tabBarModel.labels[tab]?(
                        selectedTab == tab,
                        {
                            headerModel.selected(tab: tab)
                        },
                        headerModel.state.headerContext
                    )
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: WidthPreferenceKey.self, value: proxy.size.width)
                        }
                    }
                    .frame(minWidth: sizing == .equal ? minTabWidth : nil)
                    .onPreferenceChange(WidthPreferenceKey.self) { width in
                        // TODO YOU'RE HERE this isn't working. And we need to set a min width so that the tabs always fill the width
                        minTabWidth = width
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

    init(tabCount: Int, sizing: MaterialTabBar<String>.Sizing) {
        self.init(tabs: Array(0..<tabCount).map { "Tab #\($0)" }, sizing: sizing)
    }
    
    init(tabs: [String], sizing: MaterialTabBar<String>.Sizing) {
        self.tabs = tabs
        self.sizing = sizing
        _selectedTab = State(initialValue: tabs.first!)
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tabs: [String]
    private let sizing: MaterialTabBar<String>.Sizing
    @State private var selectedTab: String

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTabBar: { context in
                MaterialTabBar(selectedTab: $selectedTab, sizing: sizing, context: context)
            },
            content: {
                ForEach(tabs, id: \.self) { tab in
                    Text("Content for \(tab)")
                        .materialTabItem(tab: tab, label: .secondary(title: tab))
                }
            }
        )
    }
}

#Preview("Secondary, equal 1") {
    MaterialTabBarPreviewView(tabCount: 1, sizing: .equal)
}

#Preview("Secondary, equal 3") {
    MaterialTabBarPreviewView(tabCount: 3, sizing: .equal)
}

#Preview("Secondary, equal 8") {
    MaterialTabBarPreviewView(tabCount: 8, sizing: .equal)
}

#Preview("Secondary, proportional") {
    MaterialTabBarPreviewView(
        tabs: [
            "Tab ABCDE",
            "Tab X",
            "Tab STSTSTSTST",
            "Tab YYY",
        ],
        sizing: .proportional
    )
}
