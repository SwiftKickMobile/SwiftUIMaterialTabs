//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

public struct MaterialTabsScrollView<Content: View, Tab, ItemID>: View where Tab: Hashable, ItemID: Hashable {

    // MARK: - API

    public init(
        tab: Tab,
        @ViewBuilder content: @escaping () -> Content
    ) where ItemID == InternalTabItemID {
        self.init(
            tab: tab,
            firstItemID: .first,
            scrollItemID: .constant(nil),
            scrollUnitPoint: .constant(.top),
            content: content
        )
    }

    public init(
        tab: Tab,
        firstItemID: ItemID,
        scrollItemID: Binding<ItemID?>,
        scrollUnitPoint: Binding<UnitPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.tab = tab
        self.firstItemID = firstItemID
        _scrollItemID = scrollItemID
        _scrollUnitPoint = scrollUnitPoint
        _scrollModel = StateObject(
            wrappedValue: ScrollModel(
                tab: tab,
                firstItemID: firstItemID
            )
        )
        self.content = content
    }

    // MARK: - Constants

    // MARK: - Variables

    private let tab: Tab
    private let firstItemID: ItemID
    @State private var coordinateSpaceName = UUID()
    @Binding private var scrollItemID: ItemID?
    @Binding private var scrollUnitPoint: UnitPoint
    @StateObject private var scrollModel: ScrollModel<ItemID, Tab>
    @ViewBuilder private var content: () -> Content
    @EnvironmentObject private var tabsModel: TabsModel<Tab>

    // MARK: - Body

    public var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: tabsModel.state.headerContext.totalHeight)
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
                        .id(firstItemID)
                    content()
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
            .scrollPosition(id: $scrollModel.scrollItemID, anchor: scrollModel.scrollUnitPoint)
        }
        .onAppear {
            // It is important not to attempt to adjust the scroll position until after the view has appeared
            // and this task seems to accomplish that.
            Task {
                scrollModel.appeared(tabsModel: tabsModel)
            }
        }
        .onChange(of: tabsModel.state.headerContext.selectedTab, initial: true) {
            scrollModel.selectedTabChanged()
        }
        .onChange(of: scrollItemID, initial: true) {
            scrollModel.scrollItemIDChanged(scrollItemID)
        }
        .onChange(of: scrollUnitPoint, initial: true) {
            scrollModel.scrollUnitPointChanged(scrollUnitPoint)
        }
        .onDisappear() {
            scrollModel.disappeared()
        }
    }
}

//#Preview {
//    MaterialTabsScrollView(
//        tab: .zero,
//        topItem: 0,
//        scrollItem: .constant(nil),
//        scrollUnitPoint: .constant(.top)
//    ) {
//        Text("Row").id(0)
//    }
//}
