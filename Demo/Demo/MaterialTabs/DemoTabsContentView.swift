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
        if tab == .two {
            MaterialTabsScroll(
                tab: tab
            ) { _ in
                LazyVStack(spacing: 0) {
                    Text("Short content.")
                }
                .scrollTargetLayout()
            }
            .background(tab.contentBackground)
            .scrollBounceBehavior(.basedOnSize)
        } else {
            MaterialTabsScroll(
                tab: tab
            ) { _ in
                LazyVStack(spacing: 0) {
                    info()
                        .padding([.leading, .trailing, .top], 20)
                        .id(0)
                    ForEach(1..<26) { index in
                        DemoContentRowView(index: index, name: name, foregroundStyle: tab.contentForeground)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .background(tab.contentBackground)
        }
    }
}

