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
        StickyHeaderScroll() {
            LazyVStack(spacing: 0) {
                DemoContentInfoView(
                    foregroundStyle: Color.skm2Yellow,
                    backgroundStyle: Color.skm2Yellow.opacity(0.15),
                    borderStyle: Color.skm2Yellow) {
                        AnyView(
                            Group {
                                Text("__Sticky Headers__ are essentially __Material Tabs__ without the tabs.")
                                Text("Header components are provided with scroll metrics that can be used to create custom effects.")
                                Text("The sticky, shrinking title is accomplished by combining the __`FixedHeaderEffect`__ with the __`scaleEffect()`__ modifier.")
                                Text("The __`minTitleHeight(_:)`__ modifier automatically measures the shrinking title to establish title view's persistence on screen.")
                                Text("The logo shrinks and fades away using __`ShrinkHeaderEffect`__.")
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
