//
//  Created by Timothy Moose on 1/7/24.
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
            reservedItem: .item,
            scrollItem: .constant(nil),
            scrollUnitPoint: .constant(.top),
            content: content
        )
    }

    /// Constructs a scroll for the given tab with external bindings for join manipulation of the scroll position.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - reservedItem: A reserved item identifier used internally by Material Tabs.
    ///   - scrollItem: The binding to the scroll item identifier.
    ///   - scrollUnitPoint: The binding to the scroll unit point.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Never apply the `scrollPosition()` view modifier on this view because it is already applied internally. You should, however, apply
    /// `scrollTargetLayout()` as you would with a regular `ScrollView`.
    ///
    /// Material Tabs maniuplates the scroll position in order to ensure continuity between tabs as the sticky header collapses or expands. Unfortunately,
    /// the only way to do precise scroll positioning in SwiftUI is to have an item identifier and know the height of its associated view. Rather than having
    /// you supply the height, Material Tabs applies the reserved item identifier to a hidden view with known height.
    init(
        tab: Tab,
        reservedItem: Item,
        scrollItem: Binding<Item?>,
        scrollUnitPoint: Binding<UnitPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.tab = tab
        self.reservedItem = reservedItem
        _scrollItem = scrollItem
        _scrollUnitPoint = scrollUnitPoint
        _scrollModel = StateObject(
            wrappedValue: ScrollModel(
                tab: tab,
                reservedItem: reservedItem
            )
        )
        self.content = content
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let reservedItem: Item?
    @State private var coordinateSpaceName = UUID()
    @Binding private var scrollItem: Item?
    @Binding private var scrollUnitPoint: UnitPoint
    @StateObject private var scrollModel: ScrollModel<Item, Tab>
    @ViewBuilder private var content: () -> Content
    @EnvironmentObject private var headerModel: HeaderModel<Tab>

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: headerModel.state.headerContext.maxOffset)
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named(coordinateSpaceName)).origin.y
                            )
                        }
                    }
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        scrollModel.contentOffsetChanged(offset)
                    }
                ZStack(alignment: .top) {
                    Color.clear
                        .frame(height: 1)
                        .id(reservedItem)
                    content()
                }
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .scrollPosition(id: $scrollModel.scrollItem, anchor: scrollModel.scrollUnitPoint)
        .onAppear {
            // It is important not to attempt to adjust the scroll position until after the view has appeared
            // and this task seems to accomplish that.
            Task {
                scrollModel.appeared(headerModel: headerModel)
            }
        }
        .onChange(of: headerModel.state.headerContext.selectedTab, initial: true) {
            scrollModel.selectedTabChanged()
        }
        .onChange(of: scrollItem, initial: true) {
            scrollModel.scrollItemChanged(scrollItem)
        }
        .onChange(of: scrollUnitPoint, initial: true) {
            scrollModel.scrollUnitPointChanged(scrollUnitPoint)
        }
        .onChange(of: headerModel.state.headerContext.totalHeight) {
            scrollModel.headerHeightChanged()
        }
        .onChange(of: headerModel.state.headerContext.safeArea.top) {
            scrollModel.headerHeightChanged()
        }
        .onDisappear() {
            scrollModel.disappeared()
        }
    }
}