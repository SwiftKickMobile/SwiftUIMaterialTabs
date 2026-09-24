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

    @State private var tabBarBackground: any ShapeStyle = Color.red
    @State private var tabBarTint: any ShapeStyle = Color.black
    @State private var isTestStarSelected = false

    // MARK: - Body

    var body: some View {
        TabView {
            Group {
                NavigationStack {
                    DemoTabsView(mainTabBarBackground: $tabBarBackground, mainTabBarTint: $tabBarTint)
                        .navigationTitle("Material Tabs")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    isTestStarSelected.toggle()
                                } label: {
                                    Image(systemName: isTestStarSelected ? "star.fill" : "star")
                                }
                                .accessibilityLabel("Toggle test star")
                            }
                        }
                }
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
