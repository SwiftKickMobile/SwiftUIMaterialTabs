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

    /// Options for horizontal alignment of tab selectors when `fillAvailableSpace` is `false` and tabs don't fill the tab bar width.
    /// Has no effect when `fillAvailableSpace` is `true` or when tabs overflow the available width.
    public enum Alignment {
        case leading
        case center
        case trailing
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
    ///   - spacing: The amount of horizontal spacing to use between tab labels. Primary and Secondary tabs should use the default spacing of 0 to
    ///     form a continuous line across the bottom of the tab bar.
    ///   - fillAvailableSpace: Applicable when tab labels don't inherently fill the width of the tab bar. When `true` (the default), the label widths are
    ///     expanded proportionally to fill the tab bar. When `false`, the labels are self-sized and positioned according to `alignment`.
    ///   - alignment: The horizontal alignment of self-sized tabs when `fillAvailableSpace` is `false`. Has no effect when `fillAvailableSpace` is
    ///     `true` or when tabs overflow the available width. Defaults to `.center`.
    ///   - context: The current context value.
    public init(
        selectedTab: Binding<Tab>,
        sizing: Sizing = .proportionalWidth,
        spacing: CGFloat = 0,
        fillAvailableSpace: Bool = true,
        alignment: Alignment = .center,
        context: MaterialTabsHeaderContext<Tab>
    ) {
        _selectedTab = selectedTab
        self.sizing = sizing
        self.spacing = spacing
        self.fillAvailableSpace = fillAvailableSpace
        self.alignment = alignment
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    private let sizing: Sizing
    private let spacing: CGFloat
    private let fillAvailableSpace: Bool
    private let alignment: Alignment

    // MARK: - Body

    public var body: some View {
        MaterialTabBarContent(
            selectedTab: $selectedTab,
            sizing: sizing,
            spacing: spacing,
            fillAvailableSpace: fillAvailableSpace,
            alignment: alignment
        )
    }
}

struct MaterialTabBarPreviewView: View {

    // MARK: - API

    init(tabCount: Int, sizing: MaterialTabBar<Int>.Sizing) {
        self.init(tabs: Array(0..<tabCount).map { MaterialTabBar<Int>.Label.secondary("Tab Number \($0)") }, sizing: sizing)
    }
    
    init(
        tabs: [MaterialTabBar<Int>.Label],
        sizing: MaterialTabBar<Int>.Sizing,
        fillAvailableSpace: Bool = true,
        alignment: MaterialTabBar<Int>.Alignment = .center
    ) {
        self.tabs = tabs
        self.sizing = sizing
        self.fillAvailableSpace = fillAvailableSpace
        self.alignment = alignment
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tabs: [MaterialTabBar<Int>.Label]
    private let sizing: MaterialTabBar<Int>.Sizing
    private let fillAvailableSpace: Bool
    private let alignment: MaterialTabBar<Int>.Alignment
    @State private var selectedTab: Int = 0

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTabBar: { context in
                MaterialTabBar(
                    selectedTab: $selectedTab,
                    sizing: sizing,
                    fillAvailableSpace: fillAvailableSpace,
                    alignment: alignment,
                    context: context
                )
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

#Preview("Self-sized, leading") {
    MaterialTabBarPreviewView(
        tabs: [
            .secondary("First"),
            .secondary("Second"),
        ],
        sizing: .proportionalWidth,
        fillAvailableSpace: false,
        alignment: .leading
    )
}

#Preview("Self-sized, trailing") {
    MaterialTabBarPreviewView(
        tabs: [
            .secondary("First"),
            .secondary("Second"),
        ],
        sizing: .proportionalWidth,
        fillAvailableSpace: false,
        alignment: .trailing
    )
}

#Preview("Self-sized, center") {
    MaterialTabBarPreviewView(
        tabs: [
            .secondary("First"),
            .secondary("Second"),
        ],
        sizing: .proportionalWidth,
        fillAvailableSpace: false,
        alignment: .center
    )
}
