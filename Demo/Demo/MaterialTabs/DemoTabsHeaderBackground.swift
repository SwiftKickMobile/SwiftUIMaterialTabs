//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTabsHeaderBackground: View {

    // MARK: - API

    let context: HeaderContext<DemoTab>

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        Group {
            switch context.selectedTab {
            case .one:
                Rectangle().fill(context.selectedTab.headerBackground)
            case .two:
                Rectangle().fill(context.selectedTab.headerBackground)
            case .three:
                Color.black.opacity(0.5)
                    .background(alignment: .bottom) {
                        Image(.coffee)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .headerStyle(ParallaxHeaderStyle(), context: context)
            }
        }
        .background(.black)
    }
}

#Preview {
    DemoTabsHeaderTitle(context: HeaderContext(selectedTab: .one))
}
