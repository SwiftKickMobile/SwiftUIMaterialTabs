//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct MaterialTabBar<Tab>: View where Tab: Hashable {

    // MARK: - API

    typealias Label = (_ isSelected: Bool, _ context: HeaderContext<Tab>, _ config: MaterialTabBarConfig) -> AnyView

    public init(selectedTab: Binding<Tab>, context: HeaderContext<Tab>, config: MaterialTabBarConfig = MaterialTabBarConfig()) {
        _selectedTab = selectedTab
        self.config = config
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    private let config: MaterialTabBarConfig
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>
    @EnvironmentObject private var tabsModel: TabsModel<Tab>
    @State private var size: CGSize = .zero

    // MARK: - Body

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                Spacer()
                ForEach(Array(tabBarModel.tabs.enumerated()), id: \.offset) { (offset, tab) in
                    tabBarModel.labels[tab]!(selectedTab == tab, tabsModel.state.headerContext, config)
                    Spacer()
                }
            }
            .frame(minWidth: size.width)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: TabBarHeightPreferenceKey.self, value: proxy.size.height)
                }
            }
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthPreferenceKey.self, value: proxy.size.width)
            }
        }
        .frame(height: size.height)
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            size.height = height
        }
        .onPreferenceChange(WidthPreferenceKey.self) { width in
            size.width = width
        }
    }
}
