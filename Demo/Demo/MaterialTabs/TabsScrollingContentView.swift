//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct TabsScrollingContentView: View {

    // MARK: - API

    let tab: Tab
    let name: String

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        MaterialTabsScrollView(
            tab: tab
        ) {
            LazyVStack(spacing: 0) {
                ForEach(0..<100) { index in
                    DemoScrollingRowView(index: index, name: name, foregroundStyle: tab.contentForeground)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .background(tab.contentBackground)
    }
}

