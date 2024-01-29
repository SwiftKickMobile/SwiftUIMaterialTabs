//
//  Created by Timothy Moose on 1/20/24.
//

import Foundation

public extension BinaryFloatingPoint {
    func clamped01() -> Self {
        return self.clamped(min: 0, max: 1)
    }
}
