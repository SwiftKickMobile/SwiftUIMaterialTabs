//
//  Created by Timothy Moose on 1/23/24.
//

import SwiftUI

/// A lightweight scroll view wrapper required for sticky header scroll effects. For most intents and purposes, you should use `StickyHeaderScroll` as you
/// would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`.
///
/// Never apply the `scrollPosition()` view modifier to this view because it is already applied internally. You should, however, apply
/// `scrollTargetLayout()`, where appropriate.
public struct StickyHeaderScroll<Content, Item>: View where Content: View, Item: Hashable {

    // MARK: - API

    /// Constructs a sticky header scroll.
    ///
    /// - Parameters:
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already applied internally. You should, however, apply
    /// `scrollTargetLayout()`, where appropriate.
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) where Item == ScrollItem {
        self.init(
            firstItem: .item,
            scrollItem: .constant(nil),
            scrollUnitPoint: .constant(.top),
            content: content
        )
    }

    /// Constructs a sticky header scroll with external bindings for scroll position.
    ///
    /// - Parameters:
    ///   - firstItem: The item identifier of the first item in the scroll view.
    ///   - scrollItem: The binding to the scroll item identifier.
    ///   - scrollUnitPoint: The binding to the scroll unit point.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already applied internally. You should, however, apply
    /// `scrollTargetLayout()`, where appropriate.
    public init(
        firstItem: Item,
        scrollItem: Binding<Item?>,
        scrollUnitPoint: Binding<UnitPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) where Item == ScrollItem {
        self.firstItem = firstItem
        _scrollItem = scrollItem
        _scrollUnitPoint = scrollUnitPoint
        self.content = content
    }

    // MARK: - Constants

    // MARK: - Variables

    private let firstItem: Item
    @Binding private var scrollItem: Item?
    @Binding private var scrollUnitPoint: UnitPoint
    @ViewBuilder private var content: () -> Content

    // MARK: - Body

    public var body: some View {
        Scroll(
            tab: NoTab.none,
            firstItem: firstItem,
            scrollItem: $scrollItem,
            scrollUnitPoint: $scrollUnitPoint,
            content: content
        )
    }
}
