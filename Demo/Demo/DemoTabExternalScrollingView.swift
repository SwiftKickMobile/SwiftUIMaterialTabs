//
//  Created by Timothy Moose on 1/12/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTabExternalScrollingView: View {

    // MARK: - API

    let tab: DemoTab
    let name: String
    let color: Color

    // MARK: - Constants

    // MARK: - Variables

    @State var scrollItem: Int?
    @State var scrollUnitPoint: UnitPoint = .top

    // MARK: - Body

    var body: some View {
        MaterialTabsScrollView(
            tab: tab,
            firstItemID: 0,
            scrollItemID: $scrollItem,
            scrollUnitPoint: $scrollUnitPoint
        ) {
            LazyVStack(spacing: 0) {
                ForEach(0..<100) { index in
                    DemoRowView(tab: tab, name: name, index: index)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .background(tab.contentBackground)
        .scrollPosition(id: $scrollItem, anchor: scrollUnitPoint)
    }
}

#Preview {
    DemoTabInternalScrollingView(tab: .one, name: "One", color: .red)
}
