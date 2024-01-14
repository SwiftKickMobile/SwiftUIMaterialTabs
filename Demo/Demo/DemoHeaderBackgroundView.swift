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
        Color.black
    }
}

#Preview {
    DemoTitleView(context: HeaderContext(selectedTab: .constant(.one)))
}
