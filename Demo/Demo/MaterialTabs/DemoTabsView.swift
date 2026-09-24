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
        if #available(iOS 26.0, *) {
            tabs
                .materialTabsScrollEdgeEffect(selectedTab == .one)
                .scrollEdgeEffectHidden(selectedTab != .one, for: .top)
        } else {
            tabs
        }
    }

    private var tabs: some View {
        MaterialTabs(
            selectedTab: $selectedTab,
            headerTitle: { context in
                if context.selectedTab != .one {
                    DemoTabsHeaderTitle(context: context)
                }
            },
            headerTabBar: { context in
                MaterialTabBar<DemoTab>(
                    selectedTab: $selectedTab,
                    sizing: .equalWidth,
                    spacing: 0,
                    fillAvailableSpace: true,
                    context: context
                )
                .foregroundStyle(
                    context.selectedTab.headerForeground,
                    context.selectedTab.headerForeground.opacity(0.7)
                )
                .background(context.selectedTab.tabBarBackground)
            },
            headerBackground: { context in
                if context.selectedTab == .one {
                    Color.clear
                } else {
                    DemoTabsHeaderBackground(context: context)
                }
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
                }
            }
        )
        .toolbarBackground(selectedTab == .one ? .automatic : .hidden, for: .navigationBar)
        .onChange(of: selectedTab, initial: true) {
            mainTabBarBackground = selectedTab.contentBackground
            mainTabBarTint = selectedTab.contentForeground
        }
    }
}

#Preview {
    DemoTabsView(mainTabBarBackground: .constant(.black), mainTabBarTint: .constant(.skm2Yellow))
}
