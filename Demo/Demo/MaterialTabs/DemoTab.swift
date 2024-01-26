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
        case .one: "Beginning"
        case .two: "Middle"
        case .three: "End"
        }
    }

    var icon: Image {
        switch self {
        case .one: Image(systemName: "hand.wave")
        case .two: Image(systemName: "hand.point.down")
        case .three: Image(systemName: "hand.point.right")
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
                    Text("__Material Tabs__ provides a tab bar that supports Material 3 primary and secondary tab styles as well as fully custom tabs.")
                    Text("In addition to the tab bar, you may provide an optional title view and background view. These three components are collectively referred to as the __sticky header__.")
                    Text("The __`headerStyle()`__ modifier can be applied to elements of the sticky header to create sophisticated dynamic effects when the content scrolls.")
                    Text("Try scrolling the screens within this app to see several examples. This tab uses the default __`OffsetHeaderStyle`__ applied to the title with the __`fade`__ option enabled.")
                }
            )
        case .two:
            AnyView(
                Group {
                    Text("This tab applies __`ShrinkHeaderStyle`__ to the title view, achieving a fade and shrink effect on the logo as the content scrolls.")
                    Text("The background is white, but purple color is applied to the tab bar itself, which fills the top safe area after the title collapses.")
                    Text("The content area uses __`MaterialTabsScroll`__, a lightweight __`ScrollView`__ wrapper required to enable for header effects.")
                }
            )
        case .three:
            AnyView(
                Group {
                    Text("Here, the background view is a scalable image with the __`ParallaxHeaderEffect`__ applied to achieve a nice parallax scroll effect.")
                    Text("Separately, the title is using __`OffsetHeaderEffect`__ with the __fade__ option enabled.")
                }
            )
        }
    }
}
