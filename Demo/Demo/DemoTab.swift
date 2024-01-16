//
//  Created by Timothy Moose on 1/6/24.
//

import SwiftUI

enum DemoTab: Hashable, CaseIterable {
    case one
    case two
    case three

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
        case .two: AnyShapeStyle(Color.skaiPurple)
        case .three: AnyShapeStyle(Color.skm1Blue)
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
        case .three: AnyShapeStyle(Color.skm1Blue)
        }
    }
}
