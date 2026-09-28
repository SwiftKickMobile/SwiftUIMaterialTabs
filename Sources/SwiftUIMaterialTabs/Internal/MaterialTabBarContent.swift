//
//  Created by Timothy Moose on 2/11/26.
//

import SwiftUI

/// Internal shared view that renders the scrollable tab bar content. Used by both `MaterialTabBar`
/// and `MaterialAccessoryTabBar` to avoid duplicating tab layout logic.
///
/// Optional leading and trailing accessory views are placed inside the scroll view so they scroll with the tabs.
struct MaterialTabBarContent<Tab, Leading: View, Trailing: View>: View where Tab: Hashable {

    // MARK: - API

    init(
        selectedTab: Binding<Tab>,
        sizing: MaterialTabBar<Tab>.Sizing,
        spacing: CGFloat,
        fillAvailableSpace: Bool,
        alignment: MaterialTabBar<Tab>.Alignment,
        leading: Leading,
        trailing: Trailing
    ) {
        _selectedTab = selectedTab
        _selectedTabScroll = State(initialValue: selectedTab.wrappedValue)
        self.sizing = sizing
        self.spacing = spacing
        self.fillAvailableSpace = fillAvailableSpace
        self.alignment = alignment
        self.leading = leading
        self.trailing = trailing
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @State private var selectedTabScroll: Tab?
    private let sizing: MaterialTabBar<Tab>.Sizing
    private let spacing: CGFloat
    private let fillAvailableSpace: Bool
    private let alignment: MaterialTabBar<Tab>.Alignment
    private let leading: Leading
    private let trailing: Trailing
    @Environment(TabBarModel<Tab>.self) private var tabBarModel
    @Environment(HeaderModel<Tab>.self) private var headerModel
    @State private var height: CGFloat = 0

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    leading
                    TabBarLayout(
                        fittingWidth: proxy.size.width,
                        sizing: sizing,
                        spacing: spacing,
                        fillAvailableSpace: fillAvailableSpace
                    ) {
                        ForEach(tabBarModel.tabs, id: \.self) { tab in
                            tabBarModel.labels[tab]?(
                                tab,
                                headerModel.headerContext,
                                {
                                    headerModel.selected(tab: tab)
                                }
                            )
                            .id(tab)
                        }
                    }
                    .scrollTargetLayout()
                    trailing
                }
                .frame(minWidth: proxy.size.width, alignment: alignment.swiftUIAlignment)
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
            .animation(.default, value: selectedTabScroll)
        }
        .frame(height: height)
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            self.height = height
        }
        .onChange(of: selectedTab) {
            selectedTabScroll = selectedTab
        }
    }
}

extension MaterialTabBar.Alignment {
    var swiftUIAlignment: SwiftUI.Alignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

extension MaterialTabBarContent where Leading == EmptyView, Trailing == EmptyView {
    /// Convenience initializer for tab bars without accessories.
    init(
        selectedTab: Binding<Tab>,
        sizing: MaterialTabBar<Tab>.Sizing,
        spacing: CGFloat,
        fillAvailableSpace: Bool,
        alignment: MaterialTabBar<Tab>.Alignment
    ) {
        self.init(
            selectedTab: selectedTab,
            sizing: sizing,
            spacing: spacing,
            fillAvailableSpace: fillAvailableSpace,
            alignment: alignment,
            leading: EmptyView(),
            trailing: EmptyView()
        )
    }
}
