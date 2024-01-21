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
                MaterialTabBar<DemoTab>(selectedTab: $selectedTab, context: context)
                    .foregroundStyle(context.selectedTab.headerForeground)
            },
            headerBackground: { context in
                DemoHeaderBackgroundView(context: context)
            },
            content: {
                DemoTabExternalScrollingView(
                    tab: .one,
                    name: DemoTab.one.name
                )
                .materialTabItem(tab: DemoTab.one, title: DemoTab.one.name.uppercased())
                DemoTabExternalScrollingView(
                    tab: .two,
                    name: DemoTab.two.name
                )
                .materialTabItem(tab: DemoTab.two, title: DemoTab.two.name.uppercased())
                DemoTabExternalScrollingView(
                    tab: .three,
                    name: DemoTab.three.name
                )
                .materialTabItem(tab: DemoTab.three, title: DemoTab.three.name.uppercased())
            }
        )
    }
}

#Preview {
    DemoView()
}
