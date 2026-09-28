//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

/// The model that tracks registered tabs and their label closures. This class is available in the environment
/// within `MaterialTabs` to support building custom tab bars. Read it with `@Environment(TabBarModel<Tab>.self)`.
///
/// For most use cases, `MaterialTabBar` is sufficient. Use this model directly when you need full control over
/// tab bar layout, such as adding leading or trailing accessory views alongside tab labels.
///
/// ```swift
/// struct CustomTabBar<Tab: Hashable>: View {
///     @Environment(TabBarModel<Tab>.self) private var tabBarModel
///     @Environment(HeaderModel<Tab>.self) private var headerModel
///
///     var body: some View {
///         HStack {
///             ForEach(tabBarModel.tabs, id: \.self) { tab in
///                 tabBarModel.labels[tab]?(tab, headerModel.headerContext, {
///                     headerModel.selected(tab: tab)
///                 })
///             }
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class TabBarModel<Tab> where Tab: Hashable {

    // MARK: - API

    /// The ordered list of registered tabs, in the order they were registered via `.materialTabItem()`.
    public private(set) var tabs: [Tab] = []

    /// The label closures registered for each tab via `.materialTabItem()`.
    public var labels: [Tab: MaterialTabBar<Tab>.CustomLabel] = [:]

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
