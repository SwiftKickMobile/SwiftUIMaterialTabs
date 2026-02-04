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
///
/// This view uses `equatable()` modifier to prevent re-renders when context values
/// haven't actually changed, even if the parent view body re-evaluates.
struct ContentWrapperView<Content: View, Tab: Hashable>: View, Equatable {

    // MARK: - API
    
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
