//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTitleView: View {

    // MARK: - API

    let context: HeaderContext<DemoTab>

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        Text("Material Tabs Demo")
            .multilineTextAlignment(.center)
            .font(.largeTitle)
            .bold()
            .foregroundColor(.yellow)
            .padding(50)
    }
}

#Preview {
    DemoTitleView(context: HeaderContext(selectedTab: .constant(.one)))
}
