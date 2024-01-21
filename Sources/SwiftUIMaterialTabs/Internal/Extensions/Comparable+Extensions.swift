//
//  Created by Timothy Moose on 1/20/24.
//

import Foundation

extension Comparable {
    func clamped(min minValue: Self, max maxValue: Self) -> Self {
        return min(max(self, minValue), maxValue)
    }
}
