//
//  ContentWrapperView.swift
//  SwiftUIMaterialTabs
//
//  Created by Mofe Ejegi on 2026-02-04.
//

import SwiftUI

/// A wrapper view that shields its content from parent view re-renders.
///
/// This view creates a structural boundary that prevents unnecessary re-evaluation
/// of its content when parent state changes. The content is only re-evaluated if
/// the context parameters change.
struct ContentWrapperView<Content: View, Tab: Hashable>: View, Equatable {

    // MARK: - API

    init(
        context: MaterialTabsScrollContext<Tab>,
        @ViewBuilder content: @escaping (MaterialTabsScrollContext<Tab>) -> Content
    ) {
        self.context = context
        self.content = content
    }

    init(
        tab: Tab,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.context = MaterialTabsScrollContext<Tab>(
            headerContext: .init(selectedTab: tab),
            safeHeight: 0
        )
        self.content = { _ in content() }
    }

    let context: MaterialTabsScrollContext<Tab>
    @ViewBuilder let content: (MaterialTabsScrollContext<Tab>) -> Content

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    var body: some View {
        content(context)
    }
    
    static func == (lhs: ContentWrapperView<Content, Tab>, rhs: ContentWrapperView<Content, Tab>) -> Bool {
        lhs.context == rhs.context
    }
}
