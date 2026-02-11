//
//  Created by Timothy Moose on 1/23/24.
//

import SwiftUI

/// A lightweight scroll view wrapper required for sticky header scroll effects. For most intents and purposes, you should use `StickyHeaderScroll` as you
/// would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`. The main task that `StickyHeaderScroll`
/// performs is to track the content offset.
public struct StickyHeaderScroll<Content>: View where Content: View {

    // MARK: - API

    /// Constructs a sticky header scroll.
    ///
    /// - Parameters:
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    public init(
        @ViewBuilder content: @escaping (_ context: StickyHeaderScrollContext) -> Content
    ) {
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
    @Environment(HeaderModel<NoTab>.self) private var headerModel

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
                        headerModel.scrolled(
                            tab: .none,
                            contentOffset: -offset,
                            deltaContentOffset: -(offset - contentOffset)
                        )
                        contentOffset = offset
                    }
                // Bridge view — content closure invoked in its own scope
                StickyHeaderContentBridgeView(
                    headerContext: headerModel.headerContext,
                    safeHeight: headerModel.safeHeight,
                    content: content
                )
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

/// Bridge view for StickyHeaderScroll content — isolates @Observable tracking.
private struct StickyHeaderContentBridgeView<Content: View>: View {
    let headerContext: HeaderContext<NoTab>
    let safeHeight: CGFloat
    @ViewBuilder let content: (_ context: StickyHeaderScrollContext) -> Content

    var body: some View {
        content(
            StickyHeaderScrollContext(
                headerContext: headerContext,
                safeHeight: safeHeight
            )
        )
    }
}
