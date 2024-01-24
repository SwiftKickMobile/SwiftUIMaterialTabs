//
//  Created by Timothy Moose on 1/12/24.
//

import SwiftUI

struct DemoContentRowView: View {

    // MARK: - API

    init(index: Int, name: String, foregroundStyle: any ShapeStyle) {
        self.index = index
        self.name = name
        self.foregroundStyle = AnyShapeStyle(foregroundStyle)
    }

    // MARK: - Constants

    // MARK: - Variables

    let name: String
    let index: Int
    let foregroundStyle: AnyShapeStyle

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("Demo \(name) – Row \(index)")
                .font(.system(size: 20))
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(AnyShapeStyle(foregroundStyle))
            Spacer()
            Rectangle().fill(foregroundStyle.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 20)
        }
        .onTapGesture {
            print("TAP")
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
}
