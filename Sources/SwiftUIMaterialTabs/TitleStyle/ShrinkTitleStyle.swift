//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct ShrinkTitleStyle<Tab>: TitleStyle where Tab: Hashable {

    // MARK: - API

    public init() {}

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    public func makeBody(context: HeaderContext<Tab>, title: Title) -> some View {
        title
            .scaleEffect(pow(1 - context.unitOffset, 0.35), anchor: .center)
            .offset(CGSize(width: 0, height: context.offset * 0.5))
            .opacity(1 - context.unitOffset)
    }
}
