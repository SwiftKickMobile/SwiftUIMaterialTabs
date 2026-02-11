# SwiftUIMaterialTabs

![GitHub Release](https://img.shields.io/github/v/release/swiftkickmobile/SwiftUIMaterialTabs)
![iOS 17.0+](https://img.shields.io/badge/iOS-17.0%2B-yellow.svg)
![Xcode 15.0+](https://img.shields.io/badge/Xcode-15.0%2B-blue.svg)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-purple)
![GitHub License](https://img.shields.io/github/license/swiftkickmobile/SwiftUIMaterialTabs)

## Overview

SwiftUIMaterialTabs is a pure SwiftUI [Material 3-style tabs](https://m3.material.io/components/tabs/overview) and Sticky Header library rolled into one! It supports both Primary and Secondary tab styles as well as custom tabs. Easily apply sticky header effects like fade, shrink, and parallax or create your own unique effects. If you don't need tabs, Sticky Headers work fine without them because every app needs a cool sticky header!

![Material Tabs](https://github.com/SwiftKickMobile/SwiftUIMaterialTabs/assets/2529176/3eb02096-d8f1-4808-bcca-3064c3a8da08)
![Sticky Headers](https://github.com/SwiftKickMobile/SwiftUIMaterialTabs/assets/2529176/3e0e4df6-c7f1-4a17-a8e9-f8e9fcd7b6e2)

## Installation

SwiftUIMaterialTabs is installed through Swift Package Manager. In Xcode, navigate to `File | Add Package Dependency...`, paste the URL of this repository in the search field, and click "Add Package".

In your source file, import `MaterialTabs` to access the library.

The main components you'll use will depend on the use case: Material Tabs or Sticky Headers. The APIs are almost identical, with the main difference being that Material Tabs components have an extra `Tab` generic parameter and `MaterialTabs` requires an additional view builder for the tab bar.

| Purpose        | Material Tabs           | Sticky Headers  |
| ------------- |:-------------:| :-----:|
| The top-level container component.      | `MaterialTabs` | `StickyHeader` |
| Scroll view wrapper required for sticky header effects.      | `MaterialTabsScroll` | `StickyHeaderScroll` |
| The context passed to header view builders for calculating sticky header effects. | `MaterialTabsContext` | `StickyHeaderContext` |
| The context passed to scroll view builders with useful metrics, such as the safe content height under the header. | `MaterialTabsScrollContext` | `StickyHeaderScrollContext` |
| The tab bar. | `MaterialTabBar` | n/a |

These and additional coponents are covered in the Material Tabs and Sticky Headers sections (jump to [Sticky Headers](#sticky-headers)).

## Material Tabs

The basic usage is as follows:

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
                Text("First Tab Content")
                    // Identify tabs using the `.materialTabItem()` view modifier.
                    .materialTabItem(
                        tab: Tab.first,
                        // Using Material 3 primary tab style.
                        label: .primary("First", icon: Image(systemName: "car"))
                    )
                Text("Second Tab Content")
                    .materialTabItem(
                        tab: Tab.second,
                        label: .primary("Second", icon: Image(systemName: "sailboat"))
                    )
            }
        )
    }
}
````

### `MaterialTabBar`

`MaterialTabBar` is a horizontally scrolling tab bar that supports Material 3 primary and secondary tab styles or custom tab selectors. You specify the tab selector labels by applying the `materialTabItem(tab:label:)` view modifier to your top-level tab contents.

`MaterialTabBar` has two options for hoziontal sizing: `.equalWidth` and `.proportionalWidth`.

````swift
MaterialTabBar(selectedTab: $selectedTab, sizing: .equalWidth, context: context)
MaterialTabBar(selectedTab: $selectedTab, sizing: .proportionalWidth, context: context)
````

With `.equalWidth`, all tabs will be the width of the largest tab selector. With `.proportional`, tabs will be sized horizontally to fit. In either case, selector labels will expand to fill the available width of the tab bar. If there isn't enough space, the tab bar scrolls.

### `MaterialTabItemModifier`

The `MaterialTabItemModifier` view modifier is used to identify and configure tabs for the tab bar. It is conceptually similar to a combination of the `tag()` and `tagitem()` view modifiers used with a standard `TabView`

There are two built-in selector labels: `PrimaryTab` and `SecondaryTab`. You don't typically create these directly, but specify them when applying `.materialTabItem()` to your tab contents:

````swift
Text("First Tab Content")
    .materialTabItem(
        tab: Tab.first,
        label: .primary("First", icon: Image(systemName: "car"))
    )
````

Both styles are highly customizable through the optional `config` and `deselectedConfig` parameters:

````swift
Text("Second Tab Content")
    .materialTabItem(
        tab: Tab.first,
        label: .secondary("First", config: customLabelConfig, deselectedConfig: custonDeselectedLabelConfig)
    )
````

You may also supply your own custom selector label:

````swift
Text("Second Tab Content")
    .materialTabItem(
        tab: Tab.first,
        label: { tab, context, tapped in
            Text(tab.description)
                .foregroundColor(tab == context.selectedTab ? .blue : .black)
                .onTapGesture(perform: tapped)
        }
    )
````

### `MaterialTabsScroll`

Scrollable tab content must be contained within a `MaterialTabsScroll`, a lightweight wrapper around `ScrollView` required to enable sticky header effects. Typically, you supply the content in a `VStack` or `LazyVStack`.

````swift
content: {
    MaterialTabsScroll(tab: Tab.first) { _ in
        LazyVStack {
            ForEach(0..<10) { index in
                Text("Row \(index)")
                    .padding()
            }
        }
    }
    .materialTabItem(tab: Tab.first, label: .secondary("First"))
}
````

When this component is used, Material Tabs automatically maintains consistency of scroll position across tabs as the header is collapsed and expanded.

Joint manipulation of the scroll position is supported if you need it. You supply `scrollItem` and `scrollUnitPoint` bindings and `MaterialTabsScroll` applies the `scrollPosition()` modifier internally. You are free to set the `scrollTargetLayout()` view modifier in your content where appropriate.

````swift
@State var scrollItem: Int?
@State var scrollUnitPoint: UnitPoint = .top

...

content: {
    MaterialTabsScroll(tab: Tab.first, reservedItem: -1, scrollItem: $scrollItem, scrollUnitPoint: $scrollUnitPoint) { _ in
        LazyVStack(spacing: 0) {
            ForEach(0..<10) { index in
                Text("Row \(index)")
                    .padding()
            }
        }
        .scrollTargetLayout()
    }
    .materialTabItem(tab: Tab.first, label: .secondary("First"))
}
````

One nuance of the `scrollPosition()` view modifier is that, if you need to precisely manipulate the scroll position, you must know the height of the view being scrolled. Therefore, in order for Material Tabs to achieve precise control, you are required to supply a `reservedItem` identifier that Material Tabs will use to embed its own hidden view in the scroll. We couldn't think of another way to do this while staying "pure SwiftUI".

It is worth noting here, because it is not completely obvious, that the formula for calculating the a unit point for `scrollPosition()` seems to be:

````
unitPoint = (desiredContentOffset) / (scrollViewHeight - verticalSafeArea - verticalContentPadding - viewHeight)
````

It should be noted that `MaterialTabsScroll` inserts a spacer into the scroll to push your content below the header.

## Sticky Headers

The sticky header effects covered in this section are equally applicable to `MaterialTabs` and `StickyHeaders`.

The basic usage is the same as `MaterialTabs` without the tab bar:

````swift
struct BasicStickyHeaderView: View {

    var body: some View {
        // The main conainer view.
        StickyHeader(
            // A view builder for the header title that takes a `StickyHeaderContext`. This can be anything.
            headerTitle: { context in
                Text("Header Title")
                    .padding()
            },
            headerBackground: { context in
                // The background can be anything, but is typically a `Color`, `Gradient` or scalable `Image`.
                // The background spans the entire header and top safe area.
                Color.yellow
            },
            // The tab contents.
            content: {
                StickyHeaderScroll() {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<10) { index in
                            Text("Row \(index)")
                                .padding()
                        }
                    }
                    .scrollTargetLayout()
                }
            }
        )
    }
}
````

### `StickyHeaderScroll`

`StickyHeaderScroll` is completely analogous to [`MaterialTabsScroll`](#materialtabsscroll).

### `HeaderStyleModifier`

The `HeaderStyleModifier` view modifier works with the `HeaderStyle` protocol to implement sticky header scroll effects, such as fade, shrink and parallax. You may apply different `headerStyle(context:)` to modifiers to different header elements or apply multiple styles to a single element to achieve unique effects.

To have the title fade out as it scrolls off screen:

````swift
Text("Header Title")
    .padding()
    .headerStyle(OffsetHeaderStyle(fade: true), context: context)
````

To have the title shrink and fade out:

````swift
Text("Header Title")
    .padding()
    .headerStyle(ShrinkHeaderStyle(), context: context)
````

To apply parallax to a background image:

````swift
Image(.coolBackground)
    .resizable()
    .aspectRatio(contentMode: .fill)
    .headerStyle(ParallaxHeaderStyle(), context: context)
````

Under the hood, these styles are using parameters provided in the `StickyHeaderHeaderContext`/`MaterialTabsHeaderContext` to adjust `.scaleEffect()`, `.offset()`, and `.opacity()`. You may implement your own styles by adopting `HeaderStyle` or manipulate your header views directly.

### `MinTitleHeightModifier`

The `MinTitleHeightModifier` view modifier can be used to inform the library what the minimum collapsed height of the title view should be. By default, the title view scrolls entirely out of the safe area. However, if you apply `.minTitleHeight()`, whatever amount you specify will stick to the top of the safe area.

To make a bottom title element stick at the top:

````swift
VStack() {
    Text("Top Title Element").
        .padding()
    Text("Bottom Title Element")
        .padding()
        .minTitleHeight(.content())
}
````

The use of the `.content()` option causes the library to measure the height of the receiving view and use that height as the minimum.

The `FixedHeaderStyle` header style can be used to make a top title element stick:

````swift
VStack() {
    Text("Top Title Element").
        .padding()
        .headerStyle(
            ShrinkHeaderStyle(
                fade: false,
                minimumScale: 0.5,
                offsetFactor: 0,
                anchor: .top
            ),
            context: context
        )
        .headerStyle(FixedHeaderStyle(), context: context)
        .minTitleHeight(.content(scale: 0.5))
    Text("Bottom Title Element")
        .padding()
}
````

In this case, we've created a shrinking top title element, reducing the scale to 0.5. This scale factor is also provided to `.minTitleHeight()` so that it uses the height of the scaled down element.

## About SwiftKick Mobile
We build high quality apps for clients! [Get in touch](http://www.swiftkickmobile.com) if you need help with a project.

## License

SwiftMessages is distributed under the MIT license. [See LICENSE](./LICENSE.md) for details.
