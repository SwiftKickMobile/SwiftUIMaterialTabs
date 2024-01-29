//
//  Created by Timothy Moose on 1/29/24.
//

import SwiftUI
import MaterialTabs

struct BasicTabView: View {

    // Tabs are identified by some `Hashable` type.
    enum Tab: Hashable {
        case first
        case second
    }

    // The selected tab state variable is owned by your view.
    @State var selectedTab: Tab = .first

    var body: some View {
        // The main conainer view.
        MaterialTabs(
            // A binding to the currently selected tab.
            selectedTab: $selectedTab,
            // A view builder for the header title that takes a `MaterialTabsContext`. This can be anything.
            headerTitle: { context in
                Text("Header Title")
                    .padding()
            },
            // A view builder for the tab bar that takes a `MaterialTabsContext`.
            headerTabBar: { context in
                // Use the `MaterialTabBar` or provide your own implementation.
                MaterialTabBar(selectedTab: $selectedTab, sizing: .equalWidth, context: context)
            },
            headerBackground: { context in
                // The background can be anything, but is typically a `Color`, `Gradient` or scalable `Image`.
                // The background spans the entire header and top safe area.
                Color.yellow
            },
            // The tab contents.
            content: {
                Text("Tab 1 Content")
                    // Identify tabs using the `.materialTabItem()` view modifier.
                    .materialTabItem(
                        tab: Tab.first,
                        // Using Material 3 primary tab style.
                        label: .primary("One", icon: Image(systemName: "car"))
                    )
                Text("Tab 2 Content")
                    .materialTabItem(
                        tab: Tab.second,
                        label: .primary("Two", icon: Image(systemName: "sailboat"))
                    )
            }
        )
    }
}

#Preview {
    BasicTabView()
}
