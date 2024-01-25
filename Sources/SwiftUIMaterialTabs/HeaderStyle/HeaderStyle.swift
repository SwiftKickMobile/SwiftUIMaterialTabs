//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public protocol HeaderStyle {

    associatedtype Body: View
    associatedtype Tab: Hashable
    typealias Content = AnyView

    func makeBody(context: HeaderContext<Tab>, content: Content) -> Self.Body
}
