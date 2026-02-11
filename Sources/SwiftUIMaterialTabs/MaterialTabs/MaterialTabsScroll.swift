//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

/// A lightweight scroll view wrapper that required for sticky header scroll effects. For most intents and purposes, you should use
/// `MaterialTabsScroll` as you would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`.
///
/// `MaterialTabs` adjusts the scroll position when switching tabs to ensure continuity when switching tabs after collapsing or expanding the header.
/// However, joint maniuplation of scroll position is supported, provided that you supply the scroll position binding.
///
/// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
/// `scrollTargetLayout()` to your content as needed.
public struct MaterialTabsScroll<Content, Tab, Item>: View where Content: View, Tab: Hashable, Item: Hashable {

    // MARK: - API

    /// Constructs a scroll for the given tab.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
    /// `scrollTargetLayout()` to your content as needed.
    public init(
        tab: Tab,
        @ViewBuilder content: @escaping (_ context: MaterialTabsScrollContext<Tab>) -> Content
    ) where Item == ScrollItem {
        self.tab = tab
        self.reservedItem = .item
        _scrollItem = .constant(nil)
        _scrollUnitPoint = .constant(.top)
        _scrollModel = State(
            wrappedValue: ScrollModel(
                tab: tab,
                scrollMode: .scrollAnchor,
                reservedItem: .item
            )
        )
        self.content = content
    }

    /// Constructs a scroll for the given tab with external bindings for joint manipulation of the scroll position.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - reservedItem: A reserved item identifier used internally.
    ///   - scrollItem: The binding to the scroll item identifier.
    ///   - scrollUnitPoint: The binding to the scroll unit point.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    ////// `MaterialTabs` adjusts the scroll position when switching tabs to ensure continuity when switching tabs after collapsing or expanding the header.
    /// However, joint maniuplation of scroll position is supported, provided that you supply the scroll item and unit point bindings. However, when
    /// using joint manipulation, you must supply a `reservedItem` identifier for `MaterialTabs` to use internally on its own hidden view. This approach was
    /// adopted because precise manipulation of scroll position requires knowing the height the view associated with the scroll item and using our own internal
    /// view for that seemed the easiest solution.
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
    /// `scrollTargetLayout()` to your content as needed.
    public init(
        tab: Tab,
        reservedItem: Item,
        scrollItem: Binding<Item?>,
        scrollUnitPoint: Binding<UnitPoint>,
        @ViewBuilder content: @escaping (_ context: MaterialTabsScrollContext<Tab>) -> Content
    ) {
        self.tab = tab
        self.reservedItem = reservedItem
        _scrollItem = scrollItem
        _scrollUnitPoint = scrollUnitPoint
        _scrollModel = State(
            wrappedValue: ScrollModel(
                tab: tab,
                scrollMode: .scrollAnchor,
                reservedItem: reservedItem
            )
        )
        self.content = content
    }

    // TODO: Fix for iOS 18. `canImport(ScrollPosition)` cannot succeed, so this is dead code.
//    #if canImport(ScrollPosition)
//    public init(
//        tab: Tab,
//        scrollPosition: Binding<ScrollPosition>,
//        @ViewBuilder content: @escaping (_ context: MaterialTabsScrollContext<Tab>) -> Content
//    ) {
//        self.tab = tab
//        _scrollPosition = scrollPosition
//        _scrollModel = State(
//            wrappedValue: ScrollModel(
//                tab: tab,
//                reservedItem: reservedItem
//            )
//        )
//        self.content = content
//    }
//    #endif

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let reservedItem: Item?
    @State private var coordinateSpaceName = UUID()
    // TODO: Fix for iOS 18. `canImport(ScrollPosition)` cannot succeed, so this is dead code.
//    #if canImport(ScrollPosition)
//    @Binding private var scrollPosition = ScrollPosition(idType: Item.self)
//    #endif
    @Binding private var scrollItem: Item?
    @Binding private var scrollUnitPoint: UnitPoint
    @State private var scrollModel: ScrollModel<Item, Tab>
    @ViewBuilder private var content: (_ context: MaterialTabsScrollContext<Tab>) -> Content
    @Environment(HeaderModel<Tab>.self) private var headerModel

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: headerModel.headerContext.maxOffset)
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
                    ContentBridgeView(
                        headerContext: headerModel.headerContext,
                        safeHeight: headerModel.safeHeight,
                        content: content
                    )
                    .background {
                        GeometryReader(content: { proxy in
                            Color.clear.preference(key: ScrollViewContentSizeKey.self, value: proxy.size)
                        })
                    }
                }
                Color.clear.frame(height: scrollModel.bottomMargin)
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .map { content in
            switch scrollModel.scrollMode {
            case .scrollAnchor:
                content
                    .scrollPosition(id: $scrollModel.scrollItem, anchor: scrollModel.scrollUnitPoint)
            // TODO: Fix for iOS 18. `canImport(ScrollPosition)` cannot succeed, so this is dead code.
            case .scrollPosition:
//                #if canImport(ScrollPosition)
//                content
//                    .scrollPosition(scrollPosition)
//                #else
                content
//                #endif
            }
        }
        .transaction(value: scrollModel.scrollItem) { transation in
            // Sometimes this happens in an animation context, but this prevents animation
            transation.animation = nil
        }
        .onPreferenceChange(ScrollViewContentSizeKey.self) { size in
            guard let size else { return }
            scrollModel.contentSizeChanged(size)
        }
        .onAppear {
            switch scrollModel.scrollMode {
            case .scrollAnchor:
                // It is important not to attempt to adjust the scroll position until after the view has appeared
                // and this task seems to accomplish that.
                Task {
                    scrollModel.appeared(headerModel: headerModel)
                }
            case .scrollPosition:
                scrollModel.appeared(headerModel: headerModel)
            }
        }
        .onChange(of: headerModel.headerContext.selectedTab, initial: true) {
            scrollModel.selectedTabChanged()
        }
        .onChange(of: scrollItem, initial: true) {
            scrollModel.scrollItemChanged(scrollItem)
        }
        .onChange(of: scrollUnitPoint, initial: true) {
            scrollModel.scrollUnitPointChanged(scrollUnitPoint)
        }
        .onChange(of: headerModel.headerContext.height) {
            scrollModel.headerHeightChanged()
        }
        .onChange(of: headerModel.headerContext.safeArea.top) {
            scrollModel.headerHeightChanged()
        }
        .onChange(of: headerModel.height) {
            scrollModel.headerStateChanged()
        }
        .onChange(of: headerModel.headerContext.minTotalHeight) {
            scrollModel.headerStateChanged()
        }
        .onDisappear() {
            scrollModel.disappeared()
        }
    }
}

/// Bridge view that invokes the content closure in its own body scope.
/// This isolates @Observable property tracking — reads of scroll-related
/// properties (like offset) inside the content closure are tracked here,
/// not in MaterialTabsScroll.body.
private struct ContentBridgeView<Content: View, Tab: Hashable>: View {
    let headerContext: HeaderContext<Tab>
    let safeHeight: CGFloat
    @ViewBuilder let content: (_ context: MaterialTabsScrollContext<Tab>) -> Content

    var body: some View {
        content(
            MaterialTabsScrollContext<Tab>(
                headerContext: headerContext,
                safeHeight: safeHeight
            )
        )
    }
}

private struct ScrollViewContentSizeKey: PreferenceKey {
    typealias Value = CGSize?
    static var defaultValue: CGSize? = nil
    public static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        guard let next = nextValue() else { return }
        value = next
    }
}
