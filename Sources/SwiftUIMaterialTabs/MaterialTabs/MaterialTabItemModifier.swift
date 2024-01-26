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
                label: { isSelected, tapped, context in
                    AnyView(
                        Group {
                            switch label {
                            case .primary(let title, let icon):
                                PrimaryTab(isSelected: isSelected, tapped: tapped, title: title, icon: icon)
                            case .secondary(let title, let config, let deselectedConfig):
                                SecondaryTab(
                                    isSelected: isSelected,
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
        tab: Tab, @ViewBuilder
        label: @escaping (_ isSelected: Bool, _ tapped: @escaping () -> Void, _ context: HeaderContext<Tab>) -> Label
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
