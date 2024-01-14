//
//  Created by Timothy Moose on 1/12/24.
//

import SwiftUI

struct DemoRowView: View {

    // MARK: - API

    let name: String
    let index: Int

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.black.opacity(0.25)).frame(height: 1)
            Spacer()
            Text("Demo Content \(name) - row \(index)")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .onTapGesture {
            print("TAP")
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
}
