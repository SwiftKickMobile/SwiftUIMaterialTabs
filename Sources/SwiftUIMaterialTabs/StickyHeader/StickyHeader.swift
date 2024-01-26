//
//  Created by Timothy Moose on 1/23/24.
//

import SwiftUI

public struct StickyHeader<HeaderTitle, HeaderBackground, Content>: View
    where HeaderTitle: View, HeaderBackground: View, Content: View {

    // MARK: - API

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
                    .onChange(of: proxy.size.height, initial: true) {
                        headerModel.sizeChanged(proxy.size)
                    }
                header(headerModel.state.headerContext)
            }
            .onChange(of: proxy.safeAreaInsets.top, initial: true) {
                headerModel.topSafeAreaChanged(proxy.safeAreaInsets.top)
            }
        }
        .environmentObject(headerModel)
        .onPreferenceChange(TitleHeightPreferenceKey.self, perform: headerModel.titleHeightChanged(_:))
        .onPreferenceChange(MinTitleHeightPreferenceKey.self, perform: headerModel.minTitleHeightChanged(_:))
    }
}
