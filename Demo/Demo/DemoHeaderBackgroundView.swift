//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoHeaderBackgroundView: View {

    // MARK: - API

    let context: HeaderContext<DemoTab>

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        Rectangle().fill(context.selectedTab.headerBackground)
    }
}

#Preview {
    DemoTitleView(context: HeaderContext(selectedTab: .one))
}
