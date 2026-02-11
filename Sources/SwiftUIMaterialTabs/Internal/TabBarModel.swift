//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

@MainActor
@Observable
class TabBarModel<Tab> where Tab: Hashable {

    // MARK: - API

    private(set) var tabs: [Tab] = []
    var labels: [Tab: MaterialTabBar<Tab>.CustomLabel] = [:]

    func register(tab: Tab, @ViewBuilder label: @escaping MaterialTabBar<Tab>.CustomLabel) {
        // With @Observable, every mutation triggers re-evaluation of observing views.
        // Guard against re-registration to prevent infinite loops when called during
        // body evaluation (TabRegisteringView.init).
        guard !tabs.contains(tab) else { return }
        tabs.append(tab)
        labels[tab] = label
    }

    // MARK: - Constants

    // MARK: - Variables
}
