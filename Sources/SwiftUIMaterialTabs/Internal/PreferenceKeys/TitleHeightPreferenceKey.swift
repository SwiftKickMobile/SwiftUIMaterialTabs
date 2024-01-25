//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

struct TitleHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        value = max(value, next)
    }
}
