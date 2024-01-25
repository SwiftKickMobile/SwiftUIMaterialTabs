//
//  Created by Timothy Moose on 1/25/24.
//

import SwiftUI

extension Binding {
    func asOptionalBinding(nullValue: Value) -> Binding<Value?> {
        Binding<Value?> (
            get: {
                wrappedValue
            },
            set: { newValue in
                wrappedValue = newValue ?? nullValue
            }
        )
    }
}
