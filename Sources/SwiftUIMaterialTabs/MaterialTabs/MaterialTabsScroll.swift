//
//  Created by Timothy Moose on 1/23/24.
//

import SwiftUI

/// A lightweight scroll view wrapper that required for `MaterialTabs` scroll effects. For most intents and purposes, you should use
/// `MaterialTabsScroll` as you would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`.
///
/// When using `MaterialTabs`, the scroll position may be manipulated by the library to ensure continuity of the sticky header across tabs.
/// However, an scroll item and unit point bindings may be provided if external manipulation of the scroll position is required.
///
/// Never use the `scrollPosition()` view modifier on this view, it is already applied internally. This view does not use `scrollTargetLayout()`, so you
/// are free to apply that modifier as needed.
public struct MaterialTabsScroll<Content, Tab, Item>: View where Content: View, Tab: Hashable, Item: Hashable {

    // MARK: - API

    /// Constructs a scroll for the given tab.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Never use the `scrollPosition()` view modifier on this view, it is already applied internally. This view does not use `scrollTargetLayout()`,
    /// so you are free to apply that modifier as needed.
    public init(
        tab: Tab,
        @ViewBuilder content: @escaping () -> Content
    ) where Item == ScrollItem {
        self.init(
            tab: tab,
            firstItem: .item,
            scrollItem: .constant(nil),
            scrollUnitPoint: .constant(.top),
            content: content
        )
    }

    /// Constructs a scroll for the given tab with external bindings for join manipulation of the scroll position.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - firstItem: The item identifier of the first item in the scroll view. This is required for joint maniuplation of the scroll position.
    ///   - scrollItem: The binding to the scroll item identifier.
    ///   - scrollUnitPoint: The binding to the scroll unit point.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Never use the `scrollPosition()` view modifier on this view, it is already applied internally. This view does not use `scrollTargetLayout()`,
    /// so you are free to apply that modifier as needed.
    init(
        tab: Tab,
        firstItem: Item,
        scrollItem: Binding<Item?>,
        scrollUnitPoint: Binding<UnitPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.tab = tab
        self.firstItem = firstItem
        _scrollItem = scrollItem
        _scrollUnitPoint = scrollUnitPoint
        self.content = content
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let firstItem: Item
    @Binding private var scrollItem: Item?
    @Binding private var scrollUnitPoint: UnitPoint
    @ViewBuilder private var content: () -> Content

    // MARK: - Body

    public var body: some View {
        Scroll(
            tab: tab,
            firstItem: firstItem,
            scrollItem: $scrollItem,
            scrollUnitPoint: $scrollUnitPoint,
            content: content
        )
    }
}
