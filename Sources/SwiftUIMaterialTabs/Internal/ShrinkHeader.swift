//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

struct ShrinkHeader<Title, TabBar, Background, Tab>: View where Title: View, TabBar: View, Background: View, Tab: Hashable {

    // MARK: - API

    init(
        context: HeaderContext<Tab>,
        @ViewBuilder title: @escaping (HeaderContext<Tab>) -> Title,
        @ViewBuilder tabBar: @escaping (HeaderContext<Tab>) -> TabBar,
        @ViewBuilder background: @escaping (HeaderContext<Tab>) -> Background
    ) {
        self.context = context
        self.title = title
        self.tabBar = tabBar
        self.background = background
    }

    // MARK: - Constants

    // MARK: - Variables

    private let context: HeaderContext<Tab>
    @ViewBuilder private let title: (HeaderContext<Tab>) -> Title
    @ViewBuilder private let tabBar: (HeaderContext<Tab>) -> TabBar
    @ViewBuilder private let background: (HeaderContext<Tab>) -> Background
    @EnvironmentObject private var tabsModel: TabsModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            title(context)
                .layoutPriority(100)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: TitleHeightPreferenceKey.self,
                                value: proxy.size.height
                            )
                    }
                }
            tabBar(context)
                .layoutPriority(100)
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
        .frame(maxWidth: .infinity)
        .frame(height: tabsModel.data.headerOffset < 0 ? tabsModel.data.headerHeight - tabsModel.data.headerOffset : nil)
        .background { background(context).ignoresSafeArea(edges: .top) }
        .offset(CGSize(width: 0, height: -max(tabsModel.data.headerOffset, 0)))
    }
}

//#Preview {
//    MaterialTabsHeaderView()
//}
