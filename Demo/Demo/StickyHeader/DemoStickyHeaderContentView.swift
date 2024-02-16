//
//  Created by Timothy Moose on 1/22/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoStickyHeaderContentView: View {

    // MARK: - API

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        StickyHeaderScroll() { _ in
            LazyVStack(spacing: 0) {
                DemoContentInfoView(
                    foregroundStyle: Color.skm2Yellow,
                    backgroundStyle: Color.skm2Yellow.opacity(0.15),
                    borderStyle: Color.skm2Yellow) {
                        AnyView(
                            Group {
                                Text("__Sticky Headers__ is a slightly simplified API like __Material Tabs__ when you don't need the tabs.")
                                Text("The title view combines two effects, resuling in a shrinking title text that sticks at the top while the logo shrinks and fades.")
                                Text("To achieve this, we apply both a __`ShrinkHeaderEffect`__ and __`FixedHeaderEffect`__ to the text and a __`ShrinkHeaderEffect`__ to the logo.")
                                Text("We also use __`minTitleHeight()`__ on the text to measure and establish the final collapsed height of the title view.")
                            }
                        )
                    }
                    .padding([.leading, .trailing, .top], 20)
                ForEach(0..<100) { index in
                    DemoContentRowView(index: index, name: "Sticky", foregroundStyle: Color.skm2Yellow)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .background(.black)
    }
}
