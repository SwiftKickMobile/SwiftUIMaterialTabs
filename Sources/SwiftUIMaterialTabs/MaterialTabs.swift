//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

public struct MaterialTabs<HeaderTitle, HeaderTabBar, HeaderBackground, Content, Tab>: View
    where HeaderTitle: View, HeaderTabBar: View, HeaderBackground: View, Content: View, Tab: Hashable {

    // MARK: - API

    public init(
        selectedTab: Binding<Tab>,
        @ViewBuilder headerTitle: @escaping (HeaderContext<Tab>) -> HeaderTitle,
        @ViewBuilder headerTabBar: @escaping (HeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderBackground == EmptyView {
        self.init(
            selectedTab: selectedTab,
            headerTitle: headerTitle,
            headerTabBar: headerTabBar,
            headerBackground: { _ in EmptyView() },
            content: content
        )
    }

    public init(
        selectedTab: Binding<Tab>,
        @ViewBuilder headerTabBar: @escaping (HeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderTitle == EmptyView, HeaderBackground == EmptyView {
        self.init(
            selectedTab: selectedTab,
            headerTitle:  { _ in EmptyView() },
            headerTabBar: headerTabBar,
            headerBackground: { _ in EmptyView() },
            content: content
        )
    }

    public init(
        @ViewBuilder headerTitle: @escaping (HeaderContext<Tab>) -> HeaderTitle,
        @ViewBuilder headerBackground: @escaping (HeaderContext<Tab>) -> HeaderBackground,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderTabBar == MaterialTabBar<Tab>, Tab == Int {
        self.init(
            selectedTab: .constant(0),
            headerTitle: headerTitle,
            headerTabBar: { context in MaterialTabBar(selectedTab: .constant(0), context: context) },
            headerBackground: headerBackground,
            content: content
        )
    }

    public init(
        selectedTab: Binding<Tab>,
        @ViewBuilder headerTitle: @escaping (HeaderContext<Tab>) -> HeaderTitle,
        @ViewBuilder headerTabBar: @escaping (HeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder headerBackground: @escaping (HeaderContext<Tab>) -> HeaderBackground,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _selectedTab = selectedTab
        self.header = { context in
            HeaderView(
                context: context,
                title: headerTitle,
                tabBar: headerTabBar,
                background: headerBackground
            )
        }
        self.content = content
        _tabsModel = StateObject(wrappedValue: TabsModel(selectedTab: selectedTab.wrappedValue))
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @ViewBuilder private let header: (HeaderContext<Tab>) -> HeaderView<HeaderTitle, HeaderTabBar, HeaderBackground, Tab>
    @ViewBuilder private let content: () -> Content
    @StateObject private var tabsModel: TabsModel<Tab>
    @StateObject private var tabBarModel = TabBarModel<Tab>()

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                TabView(selection: $selectedTab) {
                    content()
                }
                .ignoresSafeArea(edges: .bottom)
                .ignoresSafeArea(edges: .top)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: proxy.size.height, initial: true) {
                    tabsModel.heightChanged(proxy.size.height)
                }
                header(tabsModel.state.headerContext)
            }
            .onChange(of: proxy.safeAreaInsets.top, initial: true) {
                tabsModel.topSafeAreaChanged(proxy.safeAreaInsets.top)
            }
        }
        .animation(.default, value: selectedTab)
        .environmentObject(tabsModel)
        .environmentObject(tabBarModel)
        .onPreferenceChange(TitleHeightPreferenceKey.self, perform: tabsModel.titleHeightChanged(_:))
        .onPreferenceChange(TabBarHeightPreferenceKey.self, perform: tabsModel.tabBarHeightChanged(_:))
        .onPreferenceChange(MinTitleHeightPreferenceKey.self) { value in
            Task {
                tabsModel.minTitleHeightChanged(value)
                print("XXXX MinTitleHeightPreferenceKey=\(value)")
            }
        }
//        .onPreferenceChange(MinTitleHeightPreferenceKey.self, perform: tabsModel.minTitleHeightChanged(_:))
        .onChange(of: selectedTab, initial: true) {
            tabsModel.selected(tab: selectedTab)
        }
        .onChange(of: tabsModel.state.headerContext.selectedTab, initial: true) {
            selectedTab = tabsModel.state.headerContext.selectedTab
        }
    }
}
