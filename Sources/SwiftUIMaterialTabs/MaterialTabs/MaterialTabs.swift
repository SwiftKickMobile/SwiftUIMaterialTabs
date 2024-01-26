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
        _headerModel = StateObject(wrappedValue: HeaderModel(selectedTab: selectedTab.wrappedValue))
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @State private var selectedTabScroll: Tab?
    @ViewBuilder private let header: (HeaderContext<Tab>) -> HeaderView<HeaderTitle, HeaderTabBar, HeaderBackground, Tab>
    @ViewBuilder private let content: () -> Content
    @StateObject private var headerModel: HeaderModel<Tab>
    @StateObject private var tabBarModel = TabBarModel<Tab>()

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        content()
                            .scrollClipDisabled()
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .safeAreaPadding(proxy.safeAreaInsets)
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $selectedTabScroll, anchor: .center)
                .scrollTargetBehavior(.paging)
                .scrollClipDisabled()
                .scrollIndicators(.never)
                .scrollBounceBehavior(.basedOnSize)
                .ignoresSafeArea()
                .onChange(of: proxy.size, initial: true) {
                    headerModel.sizeChanged(proxy.size)
                }
                header(headerModel.state.headerContext)
            }
            .background {
                TabView {
                    content()
                }
                .frame(height: 0)
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .onChange(of: proxy.safeAreaInsets.top, initial: true) {
                headerModel.topSafeAreaChanged(proxy.safeAreaInsets.top)
            }
        }
        .animation(.default, value: selectedTab)
        .environmentObject(headerModel)
        .environmentObject(tabBarModel)
        .onPreferenceChange(TitleHeightPreferenceKey.self, perform: headerModel.titleHeightChanged(_:))
        .onPreferenceChange(TabBarHeightPreferenceKey.self, perform: headerModel.tabBarHeightChanged(_:))
        .onPreferenceChange(MinTitleHeightPreferenceKey.self, perform: headerModel.minTitleHeightChanged(_:))
        .onChange(of: selectedTab, initial: true) {
            headerModel.selected(tab: selectedTab)
        }
        .onChange(of: selectedTabScroll) {
            guard let selectedTab = selectedTabScroll else { return }
            headerModel.selected(tab: selectedTab)
        }
        .onChange(of: headerModel.state.headerContext.selectedTab, initial: true) {
            selectedTab = headerModel.state.headerContext.selectedTab
            selectedTabScroll = selectedTab
        }
    }
}
