//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

struct MinTitleHeightPreferenceKey: PreferenceKey {

    enum Dimension: Equatable {
        case absolute(CGFloat)
        case relative(CGFloat)
    }

    static var defaultValue: Dimension = .absolute(0)

    static func reduce(value: inout Dimension, nextValue: () -> Dimension) {
        value = nextValue()
    }
}
