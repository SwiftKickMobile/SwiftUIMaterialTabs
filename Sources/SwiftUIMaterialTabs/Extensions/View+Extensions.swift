//
//  Created by Timothy Moose on 9/28/24.
//

import SwiftUI

extension View {
    /// Provides a way to introduce a code block as a view modifier.
    @ViewBuilder func map<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> some View {
        transform(self)
    }
}
