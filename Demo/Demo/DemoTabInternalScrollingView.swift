//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTabInternalScrollingView: View {

    // MARK: - API

    let tab: DemoTab
    let name: String
    let color: Color

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        MaterialTabsScrollView(
            tab: tab
        ) {
            LazyVStack(spacing: 0) {
                ForEach(0..<100) { index in
                    DemoRowView(name: name, index: index)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .background(color)
    }
}

#Preview {
    DemoTabInternalScrollingView(tab: .one, name: "One", color: .red)
}

