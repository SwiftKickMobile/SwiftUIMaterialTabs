//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

struct HeaderView<Title, TabBar, Background, Tab>: View where Title: View, TabBar: View, Background: View, Tab: Hashable {

    // MARK: - API

    init(
        context: HeaderContext<Tab>,
        style: HeaderStyle,
        @ViewBuilder title: @escaping (HeaderContext<Tab>) -> Title,
        @ViewBuilder tabBar: @escaping (HeaderContext<Tab>) -> TabBar,
        @ViewBuilder background: @escaping (HeaderContext<Tab>) -> Background
    ) {
        self.context = context
        self.style = style
        self.title = title
        self.tabBar = tabBar
        self.background = background
    }

    // MARK: - Constants

    // MARK: - Variables

    private let context: HeaderContext<Tab>
    private let style: HeaderStyle
    @ViewBuilder private let title: (HeaderContext<Tab>) -> Title
    @ViewBuilder private let tabBar: (HeaderContext<Tab>) -> TabBar
    @ViewBuilder private let background: (HeaderContext<Tab>) -> Background
    @EnvironmentObject private var tabsModel: TabsModel

    // MARK: - Body

    var body: some View {
        switch style {
        case .offset: makeOffsetHeader()
        case .shrink: makeShrinkHeader()
        }
    }

    @ViewBuilder private func makeOffsetHeader() -> some View {
        VStack(spacing: 0) {
            makeTitleView()
            makeTabBarView()
        }
        .frame(maxWidth: .infinity)
        .frame(height: tabsModel.data.headerOffset < 0 ? tabsModel.data.titleHeight * tabsModel.data.offsetPercentage : nil)
        .background { background(context).ignoresSafeArea(edges: .top) }
        .offset(CGSize(width: 0, height: -max(tabsModel.data.headerOffset, 0)))
    }

    @ViewBuilder private func makeShrinkHeader() -> some View {
        VStack(spacing: 0) {
            makeTitleView()
            makeTabBarView()
        }
        .frame(maxWidth: .infinity)
        .frame(height: tabsModel.data.headerOffset < 0 ? tabsModel.data.titleHeight * tabsModel.data.offsetPercentage : nil)
        .background { background(context).ignoresSafeArea(edges: .top) }
    }

    @ViewBuilder private func makeTitleView() -> some View {
        title(context)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: TitleHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                }
            }
    }

    @ViewBuilder private func makeTabBarView() -> some View {
        tabBar(context)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: TabBarHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                }
            }
    }
}

//#Preview {
//    MaterialTabsHeaderView()
//}
