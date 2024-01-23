//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct StickyHeaderScrollingView: View {

    // MARK: - API

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        MaterialTabsScrollView() {
            LazyVStack(spacing: 0) {
                ForEach(0..<100) { index in
                    DemoScrollingRowView(index: index, name: "Sticky", foregroundStyle: Color.skm2Yellow)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .background(.black)
    }
}
