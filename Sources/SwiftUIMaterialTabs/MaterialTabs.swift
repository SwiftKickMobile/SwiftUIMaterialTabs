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
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderBackground == EmptyView, HeaderTabBar == EmptyView, Tab == Int {
        self.init(
            selectedTab: .constant(0),
            headerTitle: headerTitle,
            headerTabBar: { _ in EmptyView() },
            headerBackground: { _ in EmptyView() },
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
        _tabsModel = StateObject(wrappedValue: TabsModel(initialTab: selectedTab.wrappedValue))
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @ViewBuilder private let header: (HeaderContext<Tab>) -> HeaderView<HeaderTitle, HeaderTabBar, HeaderBackground, Tab>
    @ViewBuilder private let content: () -> Content
    @StateObject private var tabsModel: TabsModel

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
                .toolbar(.hidden, for: .tabBar)
                .onChange(of: proxy.size.height, initial: true) {
                    tabsModel.heightChanged(proxy.size.height)
                }
                header(
                    HeaderContext(
                        selectedTab: $selectedTab,
                        offset: tabsModel.data.headerOffset,
                        maxOffset: tabsModel.data.titleHeight
                    )
                )
            }
        }
        .animation(.default, value: selectedTab)
        .environmentObject(tabsModel as TabsModel)
        .onPreferenceChange(TitleHeightPreferenceKey.self, perform: tabsModel.titleHeightChanged(_:))
        .onPreferenceChange(TabBarHeightPreferenceKey.self, perform: tabsModel.tabBarHeightChanged(_:))
        .onPreferenceChange(MinTitleHeightPreferenceKey.self, perform: tabsModel.minTitleHeightChanged(_:))
        .onChange(of: selectedTab) {
            tabsModel.selected(tab: selectedTab)
        }
    }
}
//
//#Preview {
//    MaterialTabs(selectedTab: .constant(1)) {
//        Text("Tab1").tag(1)
//        Text("Tab2").tag(2)
//    }
//}
