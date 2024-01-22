//
//  Created by Timothy Moose on 1/21/24.
//

import SwiftUI

public struct SecondaryTab: View {

    // MARK: - API

    public let isSelected: Bool
    public let tapped: () -> Void
    public let title: String
    public let font = Font.subheadline

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    public var body: some View {
        Button(action: tapped) {
            VStack {
                Text(title)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                Rectangle().fill(isSelected ? AnyShapeStyle(.foreground) : AnyShapeStyle(Color.clear))
                    .frame(height: 2)
            }
        }
    }
}

//#Preview {
//    SecondaryTab()
//}
