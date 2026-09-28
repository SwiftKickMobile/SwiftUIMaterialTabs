//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

/// `MaterialTabs` is the primary Material Tabs container view, consisting of a top header for the tab bar and other elements and a bottom area for tab content.
/// The system approximates [Google Material 3 tabs](https://m3.material.io/components/tabs/overview), with out-of-the box
/// support for both primary and secondary tab styles.
///
/// The content of a tab typically is typically a scroll view containing custom content, which must be constructed using the lightweight `ScrollView`
/// wrapper `MaterialTabsScroll`. Swiping left and right on tab contents pages between tabs. Each content view must be identified and configured
/// using the `materialTabItem()` view modifier (conceptually similar to a combination of the `tag()` and `tagitem()` view
/// modifiers used with a standard `TabView`).
///
/// Header elements consist of an optional title view, the tab bar below it, and an optional background view spanning the header and top safe area.
/// When tab content is scrolled, the library automatically offsets the header to track scrolling, but sticks at the top when the tab bar reaches the top safe area.
/// The header elements are collectively referred to as the "sticky header" throughout the library.
///
/// The `headerStyle()` view modifier can be applied to one or more sticky header elements to achieve sophisticated scroll effects, such
/// as fade, shrink and parallax. The effects are driven by a variety of dynamic metrics, through the stream of `MaterialTabsHeaderContext` values
/// provided to each header element's view builder. You may implement your own header styles or use the context in other ways to achieve a variety of
/// unique effects.
///
/// To use sticky headers without tabs, use the `StickyHeader` view instead of `MaterialTabs`.
public struct MaterialTabs<HeaderTitle, HeaderTabBar, HeaderBackground, Content, Tab>: View
    where HeaderTitle: View, HeaderTabBar: View, HeaderBackground: View, Content: View, Tab: Hashable {

    // MARK: - API
    
    /// Constructs a material tabs component with a header title, tab bar and tab contents (no background).
    ///
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - headerTitle: The header title view builder.
    ///   - headerTabBar: The header tab bar. `MaterialTabBar` is typically used, but any custom view may be provideded.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// Top-level content elements are typically `MaterialTabsScroll` views. `MaterialTabsScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects. Top level content elements must apply the `materialTabItem()` view modifier
    /// in order to identify and configure each tab (conceptually similar to a combination of the `tag()` and `tagitem()` view
    /// modifiers used with a standard `TabView`).
    public init(
        selectedTab: Binding<Tab>,
        config: MaterialTabsConfig = MaterialTabsConfig(),
        @ViewBuilder headerTitle: @escaping (MaterialTabsHeaderContext<Tab>) -> HeaderTitle,
        @ViewBuilder headerTabBar: @escaping (MaterialTabsHeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderBackground == EmptyView {
        self.init(
            selectedTab: selectedTab,
            config: config,
            headerTitle: headerTitle,
            headerTabBar: headerTabBar,
            headerBackground: { _ in EmptyView() },
            content: content
        )
    }

    /// Constructs a material tabs component with a tab bar and tab contents (no title or background).
    ///
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - headerTitle: The header title view builder.
    ///   - headerTabBar: The header tab bar. `MaterialTabBar` is typically used, but any custom view may be provideded.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// Top-level content elements are typically `MaterialTabsScroll` views. `MaterialTabsScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects. Top level content elements must apply the `materialTabItem()` view modifier
    /// in order to identify and configure each tab (conceptually similar to a combination of the `tag()` and `tagitem()` view
    /// modifiers used with a standard `TabView`).
    public init(
        selectedTab: Binding<Tab>,
        config: MaterialTabsConfig = MaterialTabsConfig(),
        @ViewBuilder headerTabBar: @escaping (MaterialTabsHeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderTitle == EmptyView, HeaderBackground == EmptyView {
        self.init(
            selectedTab: selectedTab,
            config: config,
            headerTitle:  { _ in EmptyView() },
            headerTabBar: headerTabBar,
            headerBackground: { _ in EmptyView() },
            content: content
        )
    }

    /// Constructs a material tabs component with all elements: header title, tab bar, header background and tab contents.
    ///
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - headerTitle: The header title view builder.
    ///   - headerTabBar: The header tab bar. `MaterialTabBar` is typically used, but any custom view may be provideded.
    ///   - headerBackground: The header background view builder, typically a `Color`, `Gradient` or scalable `Image`.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// Top-level content elements are typically `MaterialTabsScroll` views. `MaterialTabsScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects. Top level content elements must apply the `materialTabItem()` view modifier
    /// in order to identify and configure each tab (conceptually similar to a combination of the `tag()` and `tagitem()` view
    /// modifiers used with a standard `TabView`).
    public init(
        selectedTab: Binding<Tab>,
        config: MaterialTabsConfig = MaterialTabsConfig(),
        @ViewBuilder headerTitle: @escaping (MaterialTabsHeaderContext<Tab>) -> HeaderTitle,
        @ViewBuilder headerTabBar: @escaping (MaterialTabsHeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder headerBackground: @escaping (MaterialTabsHeaderContext<Tab>) -> HeaderBackground,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _selectedTab = selectedTab
        self.config = config
        self.headerTitle = headerTitle
        self.headerTabBar = headerTabBar
        self.headerBackground = headerBackground
        self.content = content
        _headerModel = State(wrappedValue: HeaderModel(selectedTab: selectedTab.wrappedValue))
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @State private var selectedTabScroll: Tab?
    @State private var config: MaterialTabsConfig
    @ViewBuilder private let headerTitle: (MaterialTabsHeaderContext<Tab>) -> HeaderTitle
    @ViewBuilder private let headerTabBar: (MaterialTabsHeaderContext<Tab>) -> HeaderTabBar
    @ViewBuilder private let headerBackground: (MaterialTabsHeaderContext<Tab>) -> HeaderBackground
    @ViewBuilder private let content: () -> Content
    @State private var headerModel: HeaderModel<Tab>
    @State private var tabBarModel = TabBarModel<Tab>()

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
                            .safeAreaPadding(.top, headerModel.headerContext.minTotalHeight)
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
                HeaderBridgeView(
                    headerContext: headerModel.headerContext,
                    headerTitle: headerTitle,
                    headerTabBar: headerTabBar,
                    headerBackground: headerBackground
                )
                .background {
                    if !headerModel.tabsRegistered {
                        TabView {
                            content()
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 0)
                    }
                }
            }
            .onChange(of: proxy.safeAreaInsets, initial: true) {
                headerModel.safeAreaChanged(proxy.safeAreaInsets)
            }
        }
        .animation(.default, value: selectedTab)
        .environment(headerModel)
        .environment(headerModel.headerContext)
        .environment(tabBarModel)
        .onPreferenceChange(TitleHeightPreferenceKey.self, perform: headerModel.titleHeightChanged(_:))
        .onPreferenceChange(TabBarHeightPreferenceKey.self, perform: headerModel.tabBarHeightChanged(_:))
        .onPreferenceChange(MinTitleHeightPreferenceKey.self, perform: headerModel.minTitleHeightChanged(_:))
        .onChange(of: selectedTab, initial: true) {
            headerModel.selected(tab: selectedTab)
        }
        .onChange(of: config, initial: true) {
            headerModel.configChanged(config)
        }
        .onChange(of: selectedTabScroll) {
            guard let selectedTab = selectedTabScroll else { return }
            headerModel.selected(tab: selectedTab)
        }
        .onChange(of: headerModel.headerContext.selectedTab, initial: true) {
            selectedTab = headerModel.headerContext.selectedTab
            selectedTabScroll = selectedTab
        }
    }
}

/// Bridge view that invokes header closures in its own body scope.
/// This ensures that reads of scroll-related context properties (like `offset`)
/// are tracked here, not in `MaterialTabs.body`.
private struct HeaderBridgeView<HeaderTitle: View, HeaderTabBar: View, HeaderBackground: View, Tab: Hashable>: View {
    let headerContext: HeaderContext<Tab>
    @ViewBuilder let headerTitle: (HeaderContext<Tab>) -> HeaderTitle
    @ViewBuilder let headerTabBar: (HeaderContext<Tab>) -> HeaderTabBar
    @ViewBuilder let headerBackground: (HeaderContext<Tab>) -> HeaderBackground

    var body: some View {
        HeaderView(
            context: headerContext,
            title: headerTitle,
            tabBar: headerTabBar,
            background: headerBackground
        )
    }
}
