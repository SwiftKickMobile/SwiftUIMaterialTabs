//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public extension View {
    // A view modifier that may be applied to sticky header elements to easily create sticky header effects,
    // such as fade, shink and parallax. The modifier may be applied to multiple elements separately or even multiple
    // times on the same element to combine effects.
    func headerStyle<S, Tab>(
        _ style: S,
        context: HeaderContext<Tab>
    ) -> some View where Tab: Hashable, S: HeaderStyle, S.Tab == Tab {
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
