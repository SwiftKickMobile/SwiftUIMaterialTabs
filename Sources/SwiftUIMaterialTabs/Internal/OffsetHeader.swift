//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

struct OffsetHeader<Top, TabBar, Background, Tab>: View where Top: View, TabBar: View, Background: View, Tab: Hashable {

    // MARK: - API

    init(
        context: HeaderContext<Tab>,
        @ViewBuilder top: @escaping (HeaderContext<Tab>) -> Top,
        @ViewBuilder tabBar: @escaping (HeaderContext<Tab>) -> TabBar,
        @ViewBuilder background: @escaping (HeaderContext<Tab>) -> Background
    ) {
        self.context = context
        self.top = top
        self.tabBar = tabBar
        self.background = background
    }

    // MARK: - Constants

    // MARK: - Variables

    private let context: HeaderContext<Tab>
    @ViewBuilder private let top: (HeaderContext<Tab>) -> Top
    @ViewBuilder private let tabBar: (HeaderContext<Tab>) -> TabBar
    @ViewBuilder private let background: (HeaderContext<Tab>) -> Background
    @EnvironmentObject private var tabsModel: TabsModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            top(context)
            tabBar(context)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: HeaderMinHeightPreferenceKey.self,
                                value: proxy.size.height
                            )
                    }
                }

        }
        .frame(maxWidth: .infinity)
        .background { background(context) }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: HeaderHeightPreferenceKey.self,
                        value: proxy.size.height
                    )
            }
        }
    }
}

//#Preview {
//    MaterialTabsHeaderView()
//}
