//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

enum DemoTab: String, Hashable, CaseIterable, Identifiable {

    case one
    case two
    case three

    var id: String {
        rawValue
    }

    var name: String {
        switch self {
        case .one: "One"
        case .two: "Two"
        case .three: "Three"
        }
    }

    var headerForeground: AnyShapeStyle {
        switch self {
        case .one: AnyShapeStyle(Color.skm2Yellow)
        case .two: AnyShapeStyle(Color.white)
        case .three: AnyShapeStyle(Color.white)
        }
    }

    var headerBackground: AnyShapeStyle {
        switch self {
        case .one: AnyShapeStyle(Color.black)
        case .two: AnyShapeStyle(Color.white)
        case .three: AnyShapeStyle(Color.black.opacity(0.5))
        }
    }

    var tabBarBackground: AnyShapeStyle {
        switch self {
        case .one: AnyShapeStyle(Color.clear)
        case .two: AnyShapeStyle(Color.skaiPurple)
        case .three: AnyShapeStyle(Color.clear)
        }
    }

    var contentForeground: AnyShapeStyle {
        switch self {
        case .one: AnyShapeStyle(Color.skm2Yellow)
        case .two: AnyShapeStyle(Color.white)
        case .three: AnyShapeStyle(Color.white)
        }
    }

    var contentBackground: AnyShapeStyle {
        switch self {
        case .one: AnyShapeStyle(Color.black)
        case .two: AnyShapeStyle(Color.skaiBlue)
        case .three: AnyShapeStyle(Color.darkRed)
        }
    }

    var contentInfoBackground: AnyShapeStyle {
        switch self {
        case .one: AnyShapeStyle(Color.skm2Yellow.opacity(0.15))
        case .two: AnyShapeStyle(Color.black.opacity(0.15))
        case .three: AnyShapeStyle(Color.white.opacity(0.15))
        }
    }

    func infoContent() -> AnyView {
        switch self {
        case .one:
            AnyView(
                Group {
                    Text("__Material Tabs__ supports __primary__, __secondary__ and __custom tabs__. You can even supply your own tab bar.")
                    Text("The header area is composed of an optional __title view__, __tab bar__ and __background view__.")
                    Text("The __`HeaderStyle`__ protocol provides a rich API for creating sophisticated, dynamic sticky header effects when the content scrolls.")
                    Text("This tab applies the basic __`OffsetHeaderStyle`__ to the title with the fade option enabled.")
                    Text("You can easily apply different header styles to individual views, define your own styles any make other dynamic adjustments.")
                }
            )
        case .two:
            AnyView(
                Group {
                    Text("This tab uses applies the __`ShrinkHeaderStyle`__ to the title to have the logo shrink and fade away.")
                    Text("A white background is used. But the tab bar has a purple color applied, which fills the top safe area after the titles scrolls away.")
                    Text("The content area uses __`MaterialTabsScroll`__, a lightweight __`ScrollView`__ wrapper to help with sticky header effects.")
                }
            )
        case .three:
            AnyView(
                Group {
                    Text("This tab uses uses a scalable image view for the background. The __`ParallaxHeaderEffect`__ is applied to the background to achieve a nice parallax effect.")
                    Text("The title uses the `OffsetHeaderEffect` with fade option enabled.")
                }
            )
        }
    }
}
