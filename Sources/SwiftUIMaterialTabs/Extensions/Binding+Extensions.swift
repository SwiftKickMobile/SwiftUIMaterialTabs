//
//  Created by Timothy Moose on 1/25/24.
//

import SwiftUI

public extension Binding {
    func asOptionalBinding() -> Binding<Value?> {
        let nullValue = wrappedValue
        return Binding<Value?> (
            get: {
                wrappedValue
            },
            set: { newValue in
                wrappedValue = newValue ?? nullValue
            }
        )
    }
}
