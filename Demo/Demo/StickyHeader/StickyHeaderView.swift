//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct StickyHeaderView: View {

    // MARK: - API

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        MaterialTabs(
            headerTitle: { context in
                StickyHeaderTitle(context: context)
            },
            headerBackground: { _ in
                Color.skm2Yellow
            },
            content: {
                StickyHeaderScrollingView()
            }
        )
        .background(.skm2Yellow)
    }
}
