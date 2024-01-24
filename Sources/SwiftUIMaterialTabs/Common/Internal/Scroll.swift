//
//  Created by Timothy Moose on 1/7/24.
//

import SwiftUI

public struct Scroll<Content, Tab, ItemID>: View where Content: View, Tab: Hashable, ItemID: Hashable {

    // MARK: - API

    public init(
        tab: Tab,
        @ViewBuilder content: @escaping () -> Content
    ) where ItemID == ScrollItem {
        self.init(
            tab: tab,
            firstItemID: .item,
            scrollItemID: .constant(nil),
            scrollUnitPoint: .constant(.top),
            content: content
        )
    }

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) where ItemID == ScrollItem, Tab == NoTab {
        self.init(
            tab: .none,
            firstItemID: .item,
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
    @EnvironmentObject private var headerModel: HeaderModel<Tab>

    // MARK: - Body

    public var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: headerModel.state.headerContext.totalHeight)
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
                scrollModel.appeared(headerModel: headerModel)
            }
        }
        .onChange(of: headerModel.state.headerContext.selectedTab, initial: true) {
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
