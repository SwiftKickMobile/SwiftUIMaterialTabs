//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoView: View {

    // MARK: - API

    // MARK: - Constants

    private enum Tab: Equatable {
        case tabs
        case header
    }

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        TabView {
            Group {
                StickyHeaderView()
                    .tag(Tab.header)
                    .tabItem {
                        Label("Stick Header", image: .stickyHeaderTab)
                    }
                TabsView()
                    .tag(Tab.tabs)
                    .tabItem {
                        Label("Material Tabs", image: .materialTabsTab)
                    }
            }
            .toolbarBackground(.black, for: .tabBar)
        }
        .tint(.skm2Yellow)
    }
}

#Preview {
    DemoView()
}
