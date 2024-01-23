//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct TabsView: View {

    // MARK: - API

    // MARK: - Constants

    // MARK: - Variables

    @State private var selectedTab: Tab = .one

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTitle: { context in
                TabsHeaderTitle(context: context)
            },
            headerTabBar: { context in
                MaterialTabBar<Tab>(selectedTab: $selectedTab, context: context)
                    .foregroundStyle(context.selectedTab.headerForeground)
                    .background(context.selectedTab.tabBarBackground)
            },
            headerBackground: { context in
                TabsHeaderBackground(context: context)
            },
            content: {
                TabsScrollingContentView(
                    tab: .one,
                    name: Tab.one.name
                )
                .materialTabItem(tab: Tab.one, label: .secondary(title: Tab.one.name.uppercased()))
                TabsScrollingContentView(
                    tab: .two,
                    name: Tab.two.name
                )
                .materialTabItem(tab: Tab.two, label: .secondary(title: Tab.two.name.uppercased()))
                TabsScrollingContentView(
                    tab: .three,
                    name: Tab.three.name
                )
                .materialTabItem(tab: Tab.three, label: .secondary(title: Tab.three.name.uppercased()))
            }
        )
    }
}
