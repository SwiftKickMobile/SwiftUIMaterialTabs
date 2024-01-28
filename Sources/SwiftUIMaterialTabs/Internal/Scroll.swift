//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

struct Scroll<Content, Tab, Item>: View where Content: View, Tab: Hashable, Item: Hashable {

    // MARK: - API

    init(
        tab: Tab,
        firstItem: Item,
        scrollItem: Binding<Item?>,
        scrollUnitPoint: Binding<UnitPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.tab = tab
        self.firstItem = firstItem
        _scrollItem = scrollItem
        _scrollUnitPoint = scrollUnitPoint
        _scrollModel = StateObject(
            wrappedValue: ScrollModel(
                tab: tab,
                firstItem: firstItem
            )
        )
        self.content = content
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let firstItem: Item
    @State private var coordinateSpaceName = UUID()
    @Binding private var scrollItem: Item?
    @Binding private var scrollUnitPoint: UnitPoint
    @StateObject private var scrollModel: ScrollModel<Item, Tab>
    @ViewBuilder private var content: () -> Content
    @EnvironmentObject private var headerModel: HeaderModel<Tab>

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: headerModel.state.headerContext.totalHeight)
                    .id(firstItem)
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named(coordinateSpaceName)).origin.y
                            )
                        }
                    }
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        scrollModel.contentOffsetChanged(offset)
                    }
                content()
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .scrollPosition(id: $scrollModel.scrollItem, anchor: scrollModel.scrollUnitPoint)
        .onAppear {
            // It is important not to attempt to adjust the scroll position until after the view has appeared
            // and this task seems to accomplish that.
            Task {
                scrollModel.appeared(headerModel: headerModel)
            }
        }
        .onChange(of: headerModel.state.headerContext.selectedTab, initial: true) {
            scrollModel.selectedTabChanged()
        }
        .onChange(of: scrollItem, initial: true) {
            scrollModel.scrollItemChanged(scrollItem)
        }
        .onChange(of: scrollUnitPoint, initial: true) {
            scrollModel.scrollUnitPointChanged(scrollUnitPoint)
        }
        .onDisappear() {
            scrollModel.disappeared()
        }
    }
}
