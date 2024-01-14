//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI
import SwiftUIMaterialTabs

struct DemoTabBar: View {

    // MARK: - API

    init(context: HeaderContext<DemoTab>) {
        _selectedTab = context.selectedTabBinding
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding var selectedTab: DemoTab

    // MARK: - Body

    var body: some View {
        HStack() {
            Spacer()
            Button("Zero") { selectedTab = .one }
                .foregroundColor(selectedTab == .one ? .yellow : .yellow.opacity(0.4))
            Spacer()
            Button("One") { selectedTab = .two }
                .foregroundColor(selectedTab == .two ? .yellow : .yellow.opacity(0.4))
            Spacer()
            Button("Two") { selectedTab = .three }
                .foregroundColor(selectedTab == .three ? .yellow : .yellow.opacity(0.4))
            Spacer()
        }
        .font(.title)
        .padding()
        .frame(height: 50)
    }
}

#Preview {
    DemoTabBar(context: HeaderContext(selectedTab: .constant(.one)))
}

