//
//  Created by Timothy Moose on 1/23/24.
//

import SwiftUI

/// `StickyHeader` is a stripped down version of `MaterialTabs` without tabs when you just want a scroll view with
/// a fancy sticky header.
///
/// `StickyHeader` is the primary container view, consisting of a top header area and a bottom area for scrollable content.
///
/// The content view must be constructed using the lightweight `ScrollView` wrapper `StickyHeaderScroll`.
///
/// Header elements consist of a title view and an optional background view spanning the header and top safe area.
/// When content is scrolled, the library automatically offsets the header to track scrolling, but sticks at the top when the tab bar reaches the top safe area.
/// The header elements are collectively referred to as the "sticky header" throughout the library, regarless of whether you're using `StickyHeader`
/// or `MaterialTabs`.
///
/// The `headerStyle()` view modifier can be applied to one or more sticky header elements to achieve sophisticated scroll effects, such
/// as fade, shrink and parallax. The effects are driven by a variety of dynamic metrics, through the stream of `StickyHeaderContext` values
/// provided to each header element's view builder. You may implement your own header styles or use the context in other ways to achieve a variety of
/// unique effects.
public struct StickyHeader<HeaderTitle, HeaderBackground, Content>: View
    where HeaderTitle: View, HeaderBackground: View, Content: View {

    // MARK: - API

    /// Constructs a sticky header component with a title and content (no background).
    ///
    /// - Parameters:
    ///   - headerTitle: The header title view builder.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// The content is typically a `StickyHeaderScroll` view. `StickyHeaderScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects.
    public init(
        @ViewBuilder headerTitle: @escaping (StickyHeaderContext) -> HeaderTitle,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderBackground == EmptyView {
        self.init(
            headerTitle: headerTitle,
            headerBackground: { _ in EmptyView() },
            content: content
        )
    }

    /// Constructs a sticky header component with a title and background.
    ///
    /// - Parameters:
    ///   - headerTitle: The header title view builder.
    ///   - headerBackground: The header background view builder, typically a `Color`, `Gradient` or scalable `Image`.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// The content is typically a `StickyHeaderScroll` view. `StickyHeaderScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects.
    public init(
        @ViewBuilder headerTitle: @escaping (StickyHeaderContext) -> HeaderTitle,
        @ViewBuilder headerBackground: @escaping (StickyHeaderContext) -> HeaderBackground,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = { context in
            HeaderView(
                context: context,
                title: headerTitle,
                tabBar: { _ in EmptyView() },
                background: headerBackground
            )
        }
        self.content = content
        _headerModel = StateObject(wrappedValue: HeaderModel(selectedTab: .none))
    }

    // MARK: - Constants

    // MARK: - Variables

    @ViewBuilder private let header: (StickyHeaderContext) -> HeaderView<HeaderTitle, EmptyView, HeaderBackground, NoTab>
    @ViewBuilder private let content: () -> Content
    @StateObject private var headerModel: HeaderModel<NoTab>

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                content()
                    // Padding the top safe area by the minimum header height makes scrolling
                    // calculations work out better. For example, scrolling an item to `.top`
                    // results in a fully collapsed header with the item touching the header
                    // as one would expect.
                    .safeAreaPadding(.top, headerModel.state.headerContext.minTotalHeight)
                    .onChange(of: proxy.size.height, initial: true) {
                        headerModel.sizeChanged(proxy.size)
                    }
                header(headerModel.state.headerContext)
            }
            .onChange(of: proxy.safeAreaInsets, initial: true) {
                headerModel.safeAreaChanged(proxy.safeAreaInsets)
            }
        }
        .environmentObject(headerModel)
        .onPreferenceChange(TitleHeightPreferenceKey.self, perform: headerModel.titleHeightChanged(_:))
        .onPreferenceChange(MinTitleHeightPreferenceKey.self, perform: headerModel.minTitleHeightChanged(_:))
        .onAppear {
            headerModel.tabsRegistered()
        }
    }
}
