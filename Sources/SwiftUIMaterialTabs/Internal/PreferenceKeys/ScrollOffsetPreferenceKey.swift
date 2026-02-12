//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

public struct ScrollOffsetPreferenceKey: PreferenceKey {
    public static let defaultValue: CGFloat = 0

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
