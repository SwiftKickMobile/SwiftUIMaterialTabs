//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoView: View {

    // MARK: - API

    // MARK: - Constants

    // MARK: - Variables

    @State private var selectedTab: DemoTab = .one

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTitle: { context in
                DemoTitleView(context: context)
            },
            headerTabBar: { context in
                DemoTabBar(context: context)
            },
            headerBackground: { context in
                DemoHeaderBackgroundView(context: context)
            },
            content: {
                DemoTabExternalScrollingView(
                    tab: .one,
                    name: "One",
                    color: .green.opacity(0.1)
                )
                .materialTabsitem(itemID: DemoTab.one)
                DemoTabExternalScrollingView(
                    tab: .two,
                    name: "Two",
                    color: .green.opacity(0.1)
                )
                .materialTabsitem(itemID: DemoTab.two)
                DemoTabExternalScrollingView(
                    tab: .three,
                    name: "Three",
                    color: .green.opacity(0.1)
                )
                .materialTabsitem(itemID: DemoTab.three)
            }
        )
    }
}

#Preview {
    DemoView()
}
