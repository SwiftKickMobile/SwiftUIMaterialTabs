//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public extension View {
    func headerStyle<S, Tab>(_ style: S, context: HeaderContext<Tab>) -> some View where Tab: Hashable, S: HeaderStyle, S.Tab == Tab {
        modifier(HeaderStyleModifier(style: style, context: context))
    }
}

struct HeaderStyleModifier<S, Tab>: ViewModifier where Tab: Hashable, S: HeaderStyle, S.Tab == Tab {

    // MARK: - API

    let style: S
    let context: HeaderContext<Tab>

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    func body(content: Content) -> some View {
        style.makeBody(context: context, content: AnyView(content))
    }
}
