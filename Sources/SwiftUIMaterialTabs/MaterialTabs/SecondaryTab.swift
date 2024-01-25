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
            VStack(spacing: 0) {
                Text(title)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                Rectangle().fill(isSelected ? AnyShapeStyle(.foreground) : AnyShapeStyle(Color.clear))
                    .frame(height: 2)
            }
            .contentShape(Rectangle())
            .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }
}

//#Preview {
//    SecondaryTab()
//}
