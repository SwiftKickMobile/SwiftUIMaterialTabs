//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI
import MaterialTabs

struct DemoView: View {

    // MARK: - API

    // MARK: - Constants

    private enum Tab: Equatable {
        case tabs
        case header
    }

    // MARK: - Variables

    @State private var tabBarBackground: any ShapeStyle = Color.red
    @State private var tabBarTint: any ShapeStyle = Color.black

    // MARK: - Body

    var body: some View {
        TabView {
            Group {
                DemoTabsView(mainTabBarBackground: $tabBarBackground, mainTabBarTint: $tabBarTint)
                    .tag(Tab.tabs)
                    .tabItem {
                        Label("Material Tabs", image: .materialTabsTab)
                    }
                DemoStickyHeaderView(mainTabBarBackground: $tabBarBackground, mainTabBarTint: $tabBarTint)
                    .tag(Tab.header)
                    .tabItem {
                        Label("Sticky Header", image: .stickyHeaderTab)
                    }
            }
            .toolbarBackground(AnyShapeStyle(tabBarBackground), for: .tabBar)
        }
        .tint(AnyShapeStyle(tabBarTint))
    }
}

#Preview {
    DemoView()
}
