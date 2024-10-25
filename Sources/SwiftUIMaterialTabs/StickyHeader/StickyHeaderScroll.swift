//
//  Created by Timothy Moose on 1/23/24.
//

import SwiftUI

/// A lightweight scroll view wrapper required for sticky header scroll effects. For most intents and purposes, you should use `StickyHeaderScroll` as you
/// would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`. The main task that `StickyHeaderScroll`
/// performs is to track the content offset.
public struct StickyHeaderScroll<Content, Item>: View where Content: View, Item: Hashable {

    // MARK: - API

    /// Constructs a sticky header scroll.
    ///
    /// - Parameters:
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    public init(
        @ViewBuilder content: @escaping (_ context: StickyHeaderScrollContext) -> Content
    ) where Item == ScrollItem {
        self.content = content
    }

    public struct Context {
        /// The header context
        var headerContext: StickyHeaderContext

        /// The total safe height available to the scroll view
        var safeHeight: CGFloat

        /// The total safe height available for content below the header view
        var contentHeight: CGFloat {
            safeHeight - headerContext.height
        }
    }

    // MARK: - Constants

    // MARK: - Variables

    @State private var coordinateSpaceName = UUID()
    @State private var contentOffset: CGFloat = 0
    @ViewBuilder private var content: (_ context: StickyHeaderScrollContext) -> Content
    @EnvironmentObject private var headerModel: HeaderModel<NoTab>

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
                        headerModel.scrolled(
                            tab: .none,
                            contentOffset: -offset,
                            deltaContentOffset: -(offset - contentOffset)
                        )
                        contentOffset = offset
                    }
                content(
                    StickyHeaderScrollContext(
                        headerContext: headerModel.state.headerContext,
                        safeHeight: headerModel.state.safeHeight
                    )
                )
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}
