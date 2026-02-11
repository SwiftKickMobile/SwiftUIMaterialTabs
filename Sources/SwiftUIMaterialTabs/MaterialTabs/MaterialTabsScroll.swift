//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

/// A lightweight scroll view wrapper that required for sticky header scroll effects. For most intents and purposes, you should use
/// `MaterialTabsScroll` as you would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`.
///
/// `MaterialTabs` adjusts the scroll position when switching tabs to ensure continuity when switching tabs after collapsing or expanding the header.
/// However, joint manipulation of scroll position is supported, provided that you supply the scroll position binding.
///
/// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
/// `scrollTargetLayout()` to your content as needed.
public struct MaterialTabsScroll<Content, Tab>: View where Content: View, Tab: Hashable {

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
    ) {
        self.tab = tab
        self.hasExternalScrollPosition = false
        _externalScrollPosition = .constant(ScrollPosition())
        _scrollModel = State(wrappedValue: ScrollModel(tab: tab))
        self.content = content
    }

    /// Constructs a scroll for the given tab with an external scroll position binding for joint manipulation.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - scrollPosition: The binding to the scroll position, enabling joint manipulation from the consumer.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// `MaterialTabs` adjusts the scroll position when switching tabs to ensure continuity when switching tabs after collapsing or expanding the header.
    /// Joint manipulation of scroll position is supported via the `scrollPosition` binding, allowing the consumer to programmatically
    /// scroll to items, offsets, or edges using the `ScrollPosition` API.
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
    /// `scrollTargetLayout()` to your content as needed.
    public init(
        tab: Tab,
        scrollPosition: Binding<ScrollPosition>,
        @ViewBuilder content: @escaping (_ context: MaterialTabsScrollContext<Tab>) -> Content
    ) {
        self.tab = tab
        self.hasExternalScrollPosition = true
        _externalScrollPosition = scrollPosition
        _scrollModel = State(wrappedValue: ScrollModel(tab: tab))
        self.content = content
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let hasExternalScrollPosition: Bool
    @State private var coordinateSpaceName = UUID()
    @Binding private var externalScrollPosition: ScrollPosition
    @State private var scrollModel: ScrollModel<Tab>
    @ViewBuilder private var content: (_ context: MaterialTabsScrollContext<Tab>) -> Content
    @Environment(HeaderModel<Tab>.self) private var headerModel

    // MARK: - Body

    public var body: some View {
        @Bindable var scrollModel = scrollModel
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
                Color.clear.frame(height: scrollModel.bottomMargin)
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .scrollPosition($scrollModel.scrollPosition)
        .transaction(value: scrollModel.scrollPosition) { transaction in
            // Programmatic scroll position changes (e.g. syncing across tabs) sometimes happen
            // in an animation context. Suppress animation to prevent unwanted scroll animations.
            transaction.animation = nil
        }
        .onPreferenceChange(ScrollViewContentSizeKey.self) { size in
            guard let size else { return }
            scrollModel.contentSizeChanged(size)
        }
        .onAppear {
            scrollModel.appeared(headerModel: headerModel)
        }
        .onChange(of: headerModel.headerContext.selectedTab, initial: true) {
            scrollModel.selectedTabChanged()
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
        .onChange(of: scrollModel.scrollPosition) {
            // Sync model → external binding
            if hasExternalScrollPosition {
                externalScrollPosition = scrollModel.scrollPosition
            }
        }
        .onChange(of: externalScrollPosition) {
            // Sync external binding → model
            if hasExternalScrollPosition && externalScrollPosition != scrollModel.scrollPosition {
                scrollModel.scrollPosition = externalScrollPosition
            }
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
    static let defaultValue: CGSize? = nil
    public static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        guard let next = nextValue() else { return }
        value = next
    }
}
