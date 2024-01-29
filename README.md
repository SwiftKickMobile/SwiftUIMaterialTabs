# SwiftUIMaterialTabs

![GitHub Release](https://img.shields.io/github/v/release/swiftkickmobile/SwiftUIMaterialTabs)
![iOS 17.0+](https://img.shields.io/badge/iOS-17.0%2B-yellow.svg)
![Xcode 15.0+](https://img.shields.io/badge/Xcode-15.0%2B-blue.svg)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-purple)
![GitHub License](https://img.shields.io/github/license/swiftkickmobile/SwiftUIMaterialTabs)

## Overview

SwiftUIMaterialTabs is pure SwiftUI component for Material 3-style tabs with sticky headers or just sticky headers without the tabs! Supports both primary and secondary tab styles, with numerious cusotmization options. Or supply your own tabs. Easily apply sticky header effects, such as fade, shrink, parralax, etc. or create your own.

![Sticky Headers](https://github.com/SwiftKickMobile/SwiftUIMaterialTabs/assets/2529176/5cb78c1d-071d-4e5c-9a2f-44f54d631939)
![Material Tabs](https://github.com/SwiftKickMobile/SwiftUIMaterialTabs/assets/2529176/da16a7fd-10ad-4c3f-8177-e2de398226e2)

## Installation

SwiftUIMaterialTabs is installed through Swift Package Manager. In Xcode, navigate to `File | Add Package Dependency...`, paste the URL of this repository in the search field, and click "Add Package".

In your source file, import `MaterialTabs` to access the library.

The main components you'll use will depend on the use case: Material Tabs or Sticky Headers. The APIs are almost identical, with the main difference being that Material Tabs components have an extra `Tab` generic parameter and `MaterialTabs` requires an additional view builder for the tab bar.

| Purpose        | Material Tabs           | Sticky Headers  |
| ------------- |:-------------:| :-----:|
| The top-level container component.      | `MaterialTabs` | `StickyHeader` |
| Scroll view wrapper required for sticky header effects.      | `MaterialTabsScroll` | `StickyHeaderScroll` |
| The context passed to view builders for calculating sticky header effects. | `MaterialTabsContext` | `StickyHeaderContext` |
| The tab bar. | `MaterialTabBar` | n/a |

These and additional coponents are covered in the Usage section.

## Usage

Skip to [Sticky Headers](#sticky-headers)

### Material Tabs

````swift
struct BasicTabView: View {

    // Tabs are identified by some `Hashable` type.
    enum Tab: Hashable {
        case first
        case second
    }

    // The selected tab state variable is owned by your view.
    @State var selectedTab: Tab = .first

    var body: some View {
        // The main conainer view.
        MaterialTabs(
            // A binding to the currently selected tab.
            selectedTab: $selectedTab,
            // A view builder for the header title that takes a `MaterialTabsContext`. This can be anything.
            headerTitle: { context in
                Text("Header Title")
                    .padding()
            },
            // A view builder for the tab bar that takes a `MaterialTabsContext`.
            headerTabBar: { context in
                // Use the `MaterialTabBar` or provide your own implementation.
                MaterialTabBar(selectedTab: $selectedTab, sizing: .equalWidth, context: context)
            },
            headerBackground: { context in
                // The background can be anything, but is typically a `Color`, `Gradient` or scalable `Image`.
                // The background spans the entire header and top safe area.
                Color.yellow
            },
            // The tab contents.
            content: {
                Text("Tab 1 Content")
                    // Identify tabs using the `.materialTabItem()` view modifier.
                    .materialTabItem(
                        tab: Tab.first,
                        // Using Material 3 primary tab style.
                        label: .primary("One", icon: Image(systemName: "car"))
                    )
                Text("Tab 2 Content")
                    .materialTabItem(
                        tab: Tab.second,
                        label: .primary("Two", icon: Image(systemName: "sailboat"))
                    )
            }
        )
    }
}
````

### Sticky Headers

Foobar



