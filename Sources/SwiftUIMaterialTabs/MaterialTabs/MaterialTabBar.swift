//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

/// A scrollable tab bar implementation that supports Google Material 3 primary and secondary tab bar styles. The tab bar can be configured to size tab selectors
/// equally or proportinally. Tab selectors are configured by applying the `materialTabItem()` view modifier to the top-level tab content views.
/// The `materialTabItem()` modifier is conceptually similar to a combination of the `tag()` and `tagitem()` view modifiers used with
/// a standard `TabView`. In addition to primary and secondary styles,  `materialTabItem()` supports fully custom tab selectors.
/// If space permits, tabs selectors will fill the entire width of the tab bar. Otherwise, the tab bar will scroll horizontally.
public struct MaterialTabBar<Tab>: View where Tab: Hashable {

    // MARK: - API

    /// Models for [Material 3 primary and secondary tab styles](https://m3.material.io/components/tabs/overview).
    public enum Label {

        /// [Material 3 primary tab style](https://m3.material.io/components/tabs/overview).
        /// Supply a title, icon or both. Provide selected and/or deselected configs to cusotmize further.
        case primary(
            String? = nil,
            icon: (any View)? = nil,
            config: PrimaryTab<Tab>.Config = .init(),
            deselectedConfig: PrimaryTab<Tab>.Config? = nil
        )

        /// [Material 3 secondary tab style](https://m3.material.io/components/tabs/overview).
        /// Provide selected and/or deselected configs to cusotmize further.
        case secondary(
            String,
            config: SecondaryTab<Tab>.Config = .init(),
            deselectedConfig: SecondaryTab<Tab>.Config? = nil
        )
    }

    /// Options for tab selector width sizing. If space permits, tabs selectors will fill the entire width of the tab bar. Otherwise, the tab bar will scroll horizontally.
    public enum Sizing {
        
        /// Size all tab selectors equally. If space permits, tabs selectors will fill the entire width of the tab bar. Otherwise, the tab bar will scroll horizontally.
        case equalWidth

        /// Size all tab selectors proportionally. If space permits, tabs selectors will fill the entire width of the container. Otherwise, the tab bar will scroll horizontally.
        case proportionalWidth
    }

    /// A closure for providing a custom tab selector labels. Custom labels should have greedy width and height
    /// using `.frame(maxWidth: .infinity, maxHeight: .infinity)`. The tab bar layout will automatically detmerine their intrinsic content sizes
    /// and set their frames based on the `Sizing` option and available space. All labels will be given the same height, determined by the maximum
    /// intrinsic height across all labels.
    public typealias CustomLabel = (
        _ tab: Tab,
        _ context: MaterialTabsHeaderContext<Tab>,
        _ tapped: @escaping () -> Void
    ) -> AnyView
    
    /// Constructs a tab bar component.
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - sizing: The tab selector sizing option.
    ///   - spacing: The amount of spacing to use between tabs. Primary and Secondary tabs should use the default spacing of 0 to form a continuous line across the bottom of the tab bar.
    ///   - fillAvailableSpace: When `true`, tabs assume the maximum space needed to fill the screen or scroll if they overflow the available space.
    ///   - context: The current context value.
    public init(
        selectedTab: Binding<Tab>,
        sizing: Sizing = .proportionalWidth,
        spacing: CGFloat = 0,
        fillAvailableSpace: Bool = true,
        context: MaterialTabsHeaderContext<Tab>
    ) {
        _selectedTab = selectedTab
        _selectedTabScroll = State(initialValue: selectedTab.wrappedValue)
        self.sizing = sizing
        self.context = context
        self.spacing = spacing
        self.fillAvailableSpace = fillAvailableSpace
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @State private var selectedTabScroll: Tab?
    private let sizing: Sizing
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>
    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @State private var height: CGFloat = 0
    private let context: MaterialTabsHeaderContext<Tab>
    private let spacing: CGFloat
    private let fillAvailableSpace: Bool

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                TabBarLayout(
                    fittingWidth: proxy.size.width,
                    sizing: sizing,
                    spacing: spacing,
                    fillAvailableSpace: fillAvailableSpace
                ) {
                    ForEach(tabBarModel.tabs, id: \.self) { tab in
                        tabBarModel.labels[tab]?(
                            tab,
                            headerModel.state.headerContext,
                            {
                                headerModel.selected(tab: tab)
                            }
                        )
                        .id(tab)
                    }
                }
                .scrollTargetLayout()
                .frame(minWidth: proxy.size.width)
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

#Preview("Secondary, equal 50") {
    MaterialTabBarPreviewView(tabCount: 50, sizing: .equalWidth)
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
