//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

/// A lightweight scroll view wrapper required for sticky header scroll effects. For most intents and purposes, you should use
/// `MaterialTabsScroll` as you would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`.
///
/// `MaterialTabs` adjusts the scroll position when switching tabs to ensure continuity after collapsing or expanding the header.
/// Joint manipulation of scroll position is supported via the `init(tab:scrollPosition:anchor:content:)` initializer.
///
/// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
/// `scrollTargetLayout()` to your content as needed.
public struct MaterialTabsScroll<Content, Tab>: View where Content: View, Tab: Hashable {

    // MARK: - API

    /// Constructs a scroll for the given tab with internally-managed scroll position.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Use this initializer when you don't need programmatic control over scroll position.
    /// The library manages scroll position internally for cross-tab header sync.
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already
    /// being applied internally. You are free to apply `scrollTargetLayout()` to your content
    /// as needed.
    public init(
        tab: Tab,
        @ViewBuilder content: @escaping (_ context: MaterialTabsScrollContext<Tab>) -> Content
    ) {
        self.tab = tab
        _externalAnchor = .constant(nil)
        self.hasExternalScrollPosition = false
        _externalScrollPosition = .constant(ScrollPosition())
        _scrollModel = State(wrappedValue: ScrollModel(tab: tab))
        self.content = content
    }

    /// Constructs a scroll for the given tab with an external scroll position binding
    /// for joint manipulation.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - scrollPosition: A binding to the `ScrollPosition`, enabling programmatic scrolling
    ///     via `scrollTo(id:anchor:)`, `scrollTo(edge:)`, etc.
    ///   - anchor: A binding to the anchor point used by the `.scrollPosition()` modifier.
    ///     When scrolling to a specific item with `scrollTo(id:anchor:)`, the modifier's
    ///     anchor must match the `scrollTo` anchor for visible items to reposition correctly.
    ///     Update both values together (see example below). Defaults to `nil`.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// The library manages cross-tab header sync automatically. Joint manipulation allows
    /// additional programmatic scrolling on top of that.
    ///
    /// When scrolling to a specific anchor, update both the anchor binding and the
    /// `scrollTo` call together:
    /// ```swift
    /// withAnimation {
    ///     scrollAnchor = .top
    ///     scrollPosition.scrollTo(id: itemID, anchor: .top)
    /// }
    /// ```
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already
    /// being applied internally. You are free to apply `scrollTargetLayout()` to your content
    /// as needed.
    public init(
        tab: Tab,
        scrollPosition: Binding<ScrollPosition>,
        anchor: Binding<UnitPoint?> = .constant(nil),
        @ViewBuilder content: @escaping (_ context: MaterialTabsScrollContext<Tab>) -> Content
    ) {
        self.tab = tab
        _externalAnchor = anchor
        self.hasExternalScrollPosition = true
        _externalScrollPosition = scrollPosition
        _scrollModel = State(wrappedValue: ScrollModel(tab: tab))
        self.content = content
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    @Binding private var externalAnchor: UnitPoint?
    @State private var internalAnchor: UnitPoint?
    private let hasExternalScrollPosition: Bool
    @State private var coordinateSpaceName = UUID()
    @State private var internalScrollPosition = ScrollPosition()
    @Binding private var externalScrollPosition: ScrollPosition
    @State private var scrollModel: ScrollModel<Tab>
    @ViewBuilder private var content: (_ context: MaterialTabsScrollContext<Tab>) -> Content
    @Environment(HeaderModel<Tab>.self) private var headerModel

    @Environment(\.materialTabsNativeScrollEdgeEffect) private var nativeScrollEdgeEffect
    @Environment(\.materialTabsPageActive) private var pageIsActive
    #if DEBUG
    @Environment(\.materialTabsTraceRegistration) private var traceRegistration
    #endif

    private var nativeScrollEdgeOffset: CGFloat {
        let context = headerModel.headerContext
        let visibleTitleHeight = (context.rubberBandingTitleHeight ?? context.titleHeight) - max(context.offset, 0)
        return max(0, visibleTitleHeight - context.minTitleHeight)
    }


    /// The active scroll position binding — either the consumer's external binding or our internal @State.
    private var activeScrollPosition: Binding<ScrollPosition> {
        hasExternalScrollPosition ? $externalScrollPosition : $internalScrollPosition
    }

    /// The active anchor binding — either the consumer's external binding or our internal @State.
    private var activeAnchor: Binding<UnitPoint?> {
        hasExternalScrollPosition ? $externalAnchor : $internalAnchor
    }

    // MARK: - Body

    private func activate(_ active: Bool) {
        if active {
            #if DEBUG
            scrollModel.traceRegistration = traceRegistration
            #endif
            scrollModel.appeared(headerModel: headerModel, scrollPositionBinding: activeScrollPosition, anchorBinding: activeAnchor)
        } else {
            scrollModel.disappeared()
        }
    }

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
                    // Reserved item: a hidden 1pt view used as the scroll target for
                    // programmatic offset adjustments via scrollTo(id:anchor:).
                    //
                    // Why not scrollTo(y:)?
                    // scrollTo(y:) causes position oscillation in lazy stacks when the
                    // content contains dynamically-sized views (views without a fixed
                    // frame height). When the scroll view jumps to a y offset, the lazy
                    // stack may unload/reload dynamically-sized views and re-estimate
                    // their heights, producing a content offset that differs from the
                    // requested y by exactly the size estimation error. The preference
                    // key then reports this shifted offset, the scroll view corrects,
                    // and the cycle repeats — sometimes settling correctly (even number
                    // of bounces), sometimes not (odd bounces).
                    //
                    // scrollTo(id:anchor:) targeting a fixed-size view avoids this
                    // because the scroll view can always resolve the 1pt item's position
                    // without lazy estimation. The UnitPoint anchor is calculated to
                    // achieve the desired content offset (see ScrollModel).
                    Color.clear.frame(height: 1)
                        .id(scrollModel.reservedItemID)
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
        .map { scroll in
            if #available(iOS 26.0, *), nativeScrollEdgeEffect {
                let effectHeight = headerModel.headerContext.minTotalHeight + nativeScrollEdgeOffset
                let effectWidth = headerModel.headerContext.width
                scroll
                    .safeAreaBar(edge: .top, spacing: 0) {
                        // Registration only; the real header stays outside the pager.
                        // Transparent Text registers with the native bar where a clear
                        // Color did not. Register the whole visible header, not just
                        // a centered line of text or padding around it. Measured visual
                        // scaling changes the effect bounds without changing insets.
                        Text(verbatim: "Scroll edge")
                            .font(.system(size: 1))
                            .fixedSize()
                            .visualEffect { content, geometry in
                                content.scaleEffect(
                                    x: geometry.size.width > 0 ? effectWidth / geometry.size.width : 1,
                                    y: geometry.size.height > 0 ? effectHeight / geometry.size.height : 1,
                                    anchor: .topLeading
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            // Transform the registered text bounds, not empty frame
                            // space. Layout still reserves the fixed collapsed height.
                            .frame(height: headerModel.headerContext.minTotalHeight, alignment: .top)
                            .foregroundStyle(.clear)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    .scrollEdgeEffectHidden(
                        scrollModel.contentOffset <= headerModel.headerContext.offset,
                        for: .top
                    )
            } else {
                scroll
            }
        }
        .scrollPosition(activeScrollPosition, anchor: activeAnchor.wrappedValue)
        .onPreferenceChange(ScrollViewContentSizeKey.self) { size in
            guard let size else { return }
            scrollModel.contentSizeChanged(size)
        }
        .onAppear { activate(pageIsActive ?? true) }
        .onChange(of: pageIsActive) {
            guard let active = pageIsActive else { return }
            activate(active)
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
        .onDisappear { activate(false) }
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
