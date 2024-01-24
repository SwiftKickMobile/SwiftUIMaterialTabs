//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public struct MaterialTabBar<Tab>: View where Tab: Hashable {

    // MARK: - API

    public enum Label {
        case primary(title: String, icon: Image)
        case secondary(title: String)
    }

    public typealias CustomLabel = (_ isSelected: Bool, _ tapped: @escaping () -> Void, _ context: HeaderContext<Tab>) -> AnyView

    public init(selectedTab: Binding<Tab>, context: HeaderContext<Tab>) {
        _selectedTab = selectedTab
    }

    // MARK: - Constants

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>
    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @State private var size: CGSize = .zero

    // MARK: - Body

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                Spacer()
                ForEach(Array(tabBarModel.tabs.enumerated()), id: \.offset) { (offset, tab) in
                    tabBarModel.labels[tab]!(
                        selectedTab == tab,
                        {
                            headerModel.selected(tab: tab)
                        },
                        headerModel.state.headerContext
                    )
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
