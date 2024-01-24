//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTabsHeaderTitle: View {

    // MARK: - API

    let context: HeaderContext<DemoTab>

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        Group {
            switch context.selectedTab {
            case .one:
                Image(.materialTabsLogo)
                    .headerStyle(OffsetHeaderStyle<DemoTab>(fade: true), context: context)
            case .two:
                Image(.swiftkickLogo)
                    .headerStyle(ShrinkHeaderStyle<DemoTab>(), context: context)
            case .three:
                VStack {
                    Text("by")
                        .italic()
                    Text("SwiftKick Mobile")
                        .font(.largeTitle.weight(.heavy))
                }
                .foregroundStyle(context.selectedTab.headerForeground)
                .headerStyle(OffsetHeaderStyle(fade: true), context: context)
            }
        }
        .frame(height: 150)
    }
}

#Preview {
    DemoTabsHeaderTitle(context: HeaderContext(selectedTab: .one))
}
