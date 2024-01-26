//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

public extension View {
    func materialTabItem<Tab>(tab: Tab) -> some View where Tab: Hashable {
        modifier(MaterialTabItemModifier<Tab>(tab: tab, label: { _, _, _ in AnyView(EmptyView()) }))
    }

    func materialTabItem<Tab>(tab: Tab, label: MaterialTabBar<Tab>.Label) -> some View where Tab: Hashable {
        modifier(
            MaterialTabItemModifier<Tab>(
                tab: tab,
                label: { tab, context, tapped in
                    AnyView(
                        Group {
                            switch label {
                            case .primary(let title, let icon, let config, let deselectedConfig):
                                PrimaryTab(
                                    tab: tab,
                                    context: context,
                                    tapped: tapped,
                                    title: title,
                                    icon: icon.map { AnyView($0) },
                                    config: config,
                                    deselectedConfig: deselectedConfig
                                )
                            case .secondary(let title, let config, let deselectedConfig):
                                SecondaryTab(
                                    tab: tab,
                                    context: context,
                                    tapped: tapped,
                                    title: title,
                                    config: config,
                                    deselectedConfig: deselectedConfig
                                )
                            }
                        }
                    )
                }
            )
        )
    }

    func materialTabItem<Tab, Label>(
        tab: Tab,
        @ViewBuilder label: @escaping (_ tab: Tab, _ context: HeaderContext<Tab>, _ tapped: @escaping () -> Void) -> Label
    ) -> some View where Tab: Hashable, Label: View {
        modifier(MaterialTabItemModifier<Tab>(tab: tab, label: { AnyView(label($0, $1, $2)) }))
    }
}

public struct MaterialTabItemModifier<Tab>: ViewModifier where Tab: Hashable {

    // MARK: - API


    init(
        tab: Tab,
        @ViewBuilder label: @escaping MaterialTabBar<Tab>.CustomLabel) {
        self.tab = tab
        self.label = label
    }

    let tab: Tab
    @ViewBuilder let label: MaterialTabBar<Tab>.CustomLabel

    // MARK: - Constants

    // MARK: - Variables

    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>

    // MARK: - Body

    public func body(content: Content) -> some View {
        content
            .background {
                // There must be a better way to do this, but each tab needs to be able to supply a label for the tab bar,
                // even if the tab isn't appeared yet. This hacky code is accessing the `tabBarModel` to register
                // the tab's label because we can't rely on `onAppear()` being called.
                { () -> EmptyView in
                    Task {
                        tabBarModel.register(tab: tab, label: label)
                    }
                    return EmptyView()
                }()
            }
            .id(tab)
    }
}
