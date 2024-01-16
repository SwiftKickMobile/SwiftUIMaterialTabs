//
//  Created by Timothy Moose on 1/12/24.
//

import SwiftUI

struct DemoRowView: View {

    // MARK: - API

    let tab: DemoTab
    let name: String
    let index: Int

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(tab.contentForeground.opacity(0.25)).frame(height: 1)
            Spacer()
            Text("Demo tab \(name) content, row \(index)")
                .font(.system(size: 20))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(tab.contentForeground)
            Spacer()
        }
        .onTapGesture {
            print("TAP")
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
}
