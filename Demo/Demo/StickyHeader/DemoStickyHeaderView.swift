//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoStickyHeaderView: View {

    // MARK: - API

    @Binding var mainTabBarBackground: any ShapeStyle
    @Binding var mainTabBarTint: any ShapeStyle

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        StickyHeader(
            config: HeaderConfig(
                scrollUpSnapMode: .snapToExpanded
            ),
            headerTitle: { context in
                DemoStickyHeaderTitleView(context: context)
            },
            headerBackground: { _ in
                Color.skm2Yellow
            },
            content: {
                DemoStickyHeaderContentView()
            }
        )
        .background(.skm2Yellow)
        .onAppear {
            mainTabBarBackground = Color.black
            mainTabBarTint = Color.skm2Yellow
        }
    }
}

#Preview {
    DemoStickyHeaderView(mainTabBarBackground: .constant(.black), mainTabBarTint: .constant(.skm2Yellow))
}
