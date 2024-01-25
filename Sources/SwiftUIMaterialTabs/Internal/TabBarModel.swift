//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

class TabBarModel<Tab>: ObservableObject where Tab: Hashable {

    // MARK: - API

    @Published private(set) var tabs: [Tab] = []
    var labels: [Tab: MaterialTabBar<Tab>.CustomLabel] = [:]

    func register(tab: Tab, @ViewBuilder label: @escaping MaterialTabBar<Tab>.CustomLabel) {
        if !tabs.contains(tab) {
            tabs.append(tab)
        }
        labels[tab] = label
    }

    // MARK: - Constants

    // MARK: - Variables
}
