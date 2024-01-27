//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

// A protocol used by the `headerStyle()` view modifier for easy creation of unique sticky header effects,
// such as fade, shink and parallax.
public protocol HeaderStyle {

    associatedtype Body: View
    associatedtype Tab: Hashable
    typealias Content = AnyView

    func makeBody(context: HeaderContext<Tab>, content: Content) -> Self.Body
}
