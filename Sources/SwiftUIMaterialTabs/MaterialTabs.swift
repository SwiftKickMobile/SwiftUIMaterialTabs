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
        _selectedTab = selectedTab
        self.header = { context in
            OffsetHeader(
                context: context,
                top: headerTitle,
                tabBar: headerTabBar,
                background: { _ in EmptyView() }
            )
        }
        self.content = content
        _tabsModel = StateObject(wrappedValue: TabsModel(initialTab: selectedTab.wrappedValue))
    }

    public init(
        selectedTab: Binding<Tab>,
        @ViewBuilder headerTabBar: @escaping (HeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderTitle == EmptyView, HeaderBackground == EmptyView {
        _selectedTab = selectedTab
        self.header = { context in
            OffsetHeader(
                context: context,
                top: { _ in EmptyView() },
                tabBar: headerTabBar,
                background: { _ in EmptyView() }
            )
        }
        self.content = content
        _tabsModel = StateObject(wrappedValue: TabsModel(initialTab: selectedTab.wrappedValue))
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
            OffsetHeader(
                context: context,
                top: headerTitle,
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
    @ViewBuilder private let header: (HeaderContext<Tab>) -> OffsetHeader<HeaderTitle, HeaderTabBar, HeaderBackground, Tab>
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
                .tabViewStyle(.page(indexDisplayMode: .never))
                .toolbar(.hidden, for: .tabBar)
                .onChange(of: proxy.size.height, initial: true) {
                    tabsModel.heightChanged(proxy.size.height)
                }
                header(HeaderContext(selectedTab: $selectedTab, offset: tabsModel.data.headerOffset))
                    .offset(CGSize(width: 0, height: -tabsModel.data.headerOffset))
            }
        }
        .animation(.default, value: selectedTab)
        .environmentObject(tabsModel as TabsModel)
        .onPreferenceChange(HeaderHeightPreferenceKey.self, perform: tabsModel.headerHeightChanged(_:))
        .onPreferenceChange(HeaderMinHeightPreferenceKey.self, perform: tabsModel.headerMinHeightChanged(_:))
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
