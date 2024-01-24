//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTabsContentView: View {

    // MARK: - API

    init(tab: DemoTab, name: String, @ViewBuilder info: @escaping () -> DemoContentInfoView) {
        self.tab = tab
        self.name = name
        self.info = info
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: DemoTab
    private let name: String
    @ViewBuilder private let info: () -> DemoContentInfoView

    // MARK: - Body

    var body: some View {
        MaterialTabsScroll(
            tab: tab
        ) {
            LazyVStack(spacing: 0) {
                info()
                    .padding([.leading, .trailing, .top], 20)
                ForEach(0..<25) { index in
                    DemoContentRowView(index: index, name: name, foregroundStyle: tab.contentForeground)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .background(tab.contentBackground)
    }
}

