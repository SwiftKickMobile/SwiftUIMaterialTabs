//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

public extension View {
    func materialTabItem<Tab>(tab: Tab) -> some View where Tab: Hashable {
        modifier(MaterialTabItemModifier<Tab>(tab: tab, label: { _, _, _ in AnyView(EmptyView()) }))
    }

    func materialTabItem<Tab>(tab: Tab, title: String) -> some View where Tab: Hashable {
        modifier(
            MaterialTabItemModifier<Tab>(
                tab: tab,
                label: { _, _, config in
                    AnyView(
                        Text(title)
                    )
                }
            )
        )
    }

    func materialTabItem<Tab, Label>(
        tab: Tab, @ViewBuilder
        label: @escaping (_ isSelected: Bool, _ context: HeaderContext<Tab>, _ config: MaterialTabBarConfig) -> Label
    ) -> some View where Tab: Hashable, Label: View {
        modifier(MaterialTabItemModifier<Tab>(tab: tab, label: { AnyView(label($0, $1, $2)) }))
    }
}

struct MaterialTabItemModifier<Tab>: ViewModifier where Tab: Hashable {

    // MARK: - API

    init(
        tab: Tab,
        @ViewBuilder label: @escaping MaterialTabBar<Tab>.Label) {
        self.tab = tab
        self.label = label
    }

    let tab: Tab
    @ViewBuilder let label: MaterialTabBar<Tab>.Label

    // MARK: - Constants

    // MARK: - Variables

    @EnvironmentObject private var tabsModel: TabsModel<Tab>
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>

    // MARK: - Body

    func body(content: Content) -> some View {
        // This VStack is critical to prevent a bug in iOS 17 where scrolling breaks under the following conditions:
        // 1. The scroll view is in a `TabView` in paged mode.
        // 2. The scroll view has the `scrollPosition()` modifier applied.
        VStack {
            // There must be a better way to do this, but each tab needs to be able to supply a label for the tab bar,
            // even if the tab isn't appeared yet. This hacky code is accessing the `tabBarModel` to register
            // the tab's label because we can't rely on `onAppear()` being called.
            { () -> EmptyView in
                Task {
                    tabBarModel.register(tab: tab, label: label)
                }
                return EmptyView()
            }()
            content
        }
        .tag(tab)
    }
}
