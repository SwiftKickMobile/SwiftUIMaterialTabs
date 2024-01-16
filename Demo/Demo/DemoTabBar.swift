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
            Button(DemoTab.one.name.uppercased()) { selectedTab = .one }
                .foregroundStyle(selectedTab.headerForeground).opacity(selectedTab == .one ? 1 : 0.4)
            Spacer()
            Button(DemoTab.two.name.uppercased()) { selectedTab = .two }
                .foregroundStyle(selectedTab.headerForeground).opacity(selectedTab == .two ? 1 : 0.4)
            Spacer()
            Button(DemoTab.three.name.uppercased()) { selectedTab = .three }
                .foregroundStyle(selectedTab.headerForeground).opacity(selectedTab == .three ? 1 : 0.4)
            Spacer()
        }
        .font(.system(size: 16, weight: .bold))
        .padding()
        .frame(height: 50)
    }
}

#Preview {
    DemoTabBar(context: HeaderContext(selectedTab: .constant(.one)))
}

