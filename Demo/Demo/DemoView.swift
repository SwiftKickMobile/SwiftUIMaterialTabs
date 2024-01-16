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
            headerStyle: .shrink,
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
                    name: DemoTab.one.name,
                    color: .green.opacity(0.1)
                )
                .materialTabsitem(itemID: DemoTab.one)
                DemoTabExternalScrollingView(
                    tab: .two,
                    name: DemoTab.two.name,
                    color: .green.opacity(0.1)
                )
                .materialTabsitem(itemID: DemoTab.two)
                DemoTabExternalScrollingView(
                    tab: .three,
                    name: DemoTab.three.name,
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
