//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTabsView: View {

    // MARK: - API

    @Binding var mainTabBarBackground: any ShapeStyle
    @Binding var mainTabBarTint: any ShapeStyle

    // MARK: - Constants

    // MARK: - Variables

    @State private var selectedTab: DemoTab = .one

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTitle: { context in
                DemoTabsHeaderTitle(context: context)
            },
            headerTabBar: { context in
                MaterialTabBar<DemoTab>(selectedTab: $selectedTab, context: context)
                    .foregroundStyle(
                        context.selectedTab.headerForeground,
                        context.selectedTab.headerForeground.opacity(0.7)
                    )
                    .background(context.selectedTab.tabBarBackground)
            },
            headerBackground: { context in
                DemoTabsHeaderBackground(context: context)
            },
            content: {
                ForEach(DemoTab.allCases) { tab in
                    DemoTabsContentView(
                        tab: tab,
                        name: tab.name
                    ) {
                        DemoContentInfoView(
                            foregroundStyle: tab.contentForeground,
                            backgroundStyle: tab.contentInfoBackground,
                            borderStyle: tab.contentForeground,
                            content: tab.infoContent
                        )
                    }
                    .materialTabItem(tab: tab, label: .primary(tab.name, icon: tab.icon))
//                    .materialTabItem(tab: tab, label: .secondary(tab.name.uppercased()))
                }
            }
        )
        .onChange(of: selectedTab, initial: true) {
            mainTabBarBackground = selectedTab.contentBackground
            mainTabBarTint = selectedTab.contentForeground
        }
    }
}

#Preview {
    DemoTabsView(mainTabBarBackground: .constant(.black), mainTabBarTint: .constant(.skm2Yellow))
}
