//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public protocol TitleStyle {

    associatedtype Body: View
    associatedtype Tab: Hashable
    typealias Title = AnyView

    func makeBody(context: HeaderContext<Tab>, title: Title) -> Self.Body
}
