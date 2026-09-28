//
//  Created by Timothy Moose on 2/11/26.
//

import SwiftUI

/// A variant of `MaterialTabBar` that supports optional leading and trailing accessory views alongside the tab selectors.
/// The accessories scroll horizontally together with the tabs.
///
/// For a tab bar without accessories, use `MaterialTabBar` instead.
///
/// ```swift
/// MaterialAccessoryTabBar(
///     selectedTab: $selectedTab,
///     sizing: .proportionalWidth,
///     context: context,
///     leading: {
///         Button { } label: { Image(systemName: "plus") }
///             .padding(.horizontal)
///     },
///     trailing: {
///         Button("Edit") { }
///             .padding(.horizontal)
///     }
/// )
/// ```
public struct MaterialAccessoryTabBar<Tab, Leading: View, Trailing: View>: View where Tab: Hashable {

    // MARK: - API

    /// See ``MaterialTabBar/Label``.
    public typealias Label = MaterialTabBar<Tab>.Label

    /// See ``MaterialTabBar/Sizing``.
    public typealias Sizing = MaterialTabBar<Tab>.Sizing

    /// See ``MaterialTabBar/Alignment``.
    public typealias Alignment = MaterialTabBar<Tab>.Alignment

    /// See ``MaterialTabBar/CustomLabel``.
    public typealias CustomLabel = MaterialTabBar<Tab>.CustomLabel

    /// Constructs an accessorized tab bar component.
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
    ///   - leading: A view builder for the leading accessory view. The accessory scrolls with the tabs.
    ///   - trailing: A view builder for the trailing accessory view. The accessory scrolls with the tabs.
    public init(
        selectedTab: Binding<Tab>,
        sizing: Sizing = .proportionalWidth,
        spacing: CGFloat = 0,
        fillAvailableSpace: Bool = true,
        alignment: Alignment = .center,
        context: MaterialTabsHeaderContext<Tab>,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        _selectedTab = selectedTab
        self.sizing = sizing
        self.spacing = spacing
        self.fillAvailableSpace = fillAvailableSpace
        self.alignment = alignment
        self.leading = leading()
        self.trailing = trailing()
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    private let sizing: Sizing
    private let spacing: CGFloat
    private let fillAvailableSpace: Bool
    private let alignment: Alignment
    private let leading: Leading
    private let trailing: Trailing

    // MARK: - Body

    public var body: some View {
        MaterialTabBarContent(
            selectedTab: $selectedTab,
            sizing: sizing,
            spacing: spacing,
            fillAvailableSpace: fillAvailableSpace,
            alignment: alignment,
            leading: leading,
            trailing: trailing
        )
    }
}

// MARK: - Convenience initializers

extension MaterialAccessoryTabBar where Trailing == EmptyView {

    /// Constructs an accessorized tab bar with only a leading accessory.
    public init(
        selectedTab: Binding<Tab>,
        sizing: Sizing = .proportionalWidth,
        spacing: CGFloat = 0,
        fillAvailableSpace: Bool = true,
        alignment: Alignment = .center,
        context: MaterialTabsHeaderContext<Tab>,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            selectedTab: selectedTab,
            sizing: sizing,
            spacing: spacing,
            fillAvailableSpace: fillAvailableSpace,
            alignment: alignment,
            context: context,
            leading: leading,
            trailing: { EmptyView() }
        )
    }
}

extension MaterialAccessoryTabBar where Leading == EmptyView {

    /// Constructs an accessorized tab bar with only a trailing accessory.
    public init(
        selectedTab: Binding<Tab>,
        sizing: Sizing = .proportionalWidth,
        spacing: CGFloat = 0,
        fillAvailableSpace: Bool = true,
        alignment: Alignment = .center,
        context: MaterialTabsHeaderContext<Tab>,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(
            selectedTab: selectedTab,
            sizing: sizing,
            spacing: spacing,
            fillAvailableSpace: fillAvailableSpace,
            alignment: alignment,
            context: context,
            leading: { EmptyView() },
            trailing: trailing
        )
    }
}

// MARK: - Previews

private struct AccessoryTabBarPreviewView<Leading: View, Trailing: View>: View {

    init(
        tabs: [MaterialTabBar<Int>.Label],
        sizing: MaterialTabBar<Int>.Sizing = .proportionalWidth,
        fillAvailableSpace: Bool = true,
        alignment: MaterialTabBar<Int>.Alignment = .center,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.tabs = tabs
        self.sizing = sizing
        self.fillAvailableSpace = fillAvailableSpace
        self.alignment = alignment
        self.leading = leading()
        self.trailing = trailing()
    }

    private let tabs: [MaterialTabBar<Int>.Label]
    private let sizing: MaterialTabBar<Int>.Sizing
    private let fillAvailableSpace: Bool
    private let alignment: MaterialTabBar<Int>.Alignment
    private let leading: Leading
    private let trailing: Trailing
    @State private var selectedTab: Int = 0

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTabBar: { context in
                MaterialAccessoryTabBar(
                    selectedTab: $selectedTab,
                    sizing: sizing,
                    fillAvailableSpace: fillAvailableSpace,
                    alignment: alignment,
                    context: context,
                    leading: { leading },
                    trailing: { trailing }
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

#Preview("Leading accessory") {
    AccessoryTabBarPreviewView(
        tabs: [
            .secondary("First"),
            .secondary("Second"),
            .secondary("Third"),
        ],
        leading: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .padding(.horizontal, 12)
        },
        trailing: { EmptyView() }
    )
}

#Preview("Trailing accessory") {
    AccessoryTabBarPreviewView(
        tabs: [
            .secondary("First"),
            .secondary("Second"),
            .secondary("Third"),
        ],
        leading: { EmptyView() },
        trailing: {
            Image(systemName: "plus.circle.fill")
                .padding(.horizontal, 12)
        }
    )
}

#Preview("Both accessories") {
    AccessoryTabBarPreviewView(
        tabs: [
            .secondary("First"),
            .secondary("Second"),
            .secondary("Third"),
        ],
        leading: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .padding(.horizontal, 12)
        },
        trailing: {
            Image(systemName: "plus.circle.fill")
                .padding(.horizontal, 12)
        }
    )
}

#Preview("Accessories, self-sized leading") {
    AccessoryTabBarPreviewView(
        tabs: [
            .secondary("First"),
            .secondary("Second"),
        ],
        fillAvailableSpace: false,
        alignment: .leading,
        leading: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .padding(.horizontal, 12)
        },
        trailing: {
            Image(systemName: "plus.circle.fill")
                .padding(.horizontal, 12)
        }
    )
}
