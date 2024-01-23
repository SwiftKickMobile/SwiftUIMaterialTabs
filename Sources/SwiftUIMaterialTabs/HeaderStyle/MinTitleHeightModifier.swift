//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public extension View {
    func minTitleHeight(dimension: MinTitleHeightModifier.Dimension) -> some View {
        modifier(MinTitleHeightModifier(dimension: dimension))
    }
}

public struct MinTitleHeightModifier: ViewModifier {

    // MARK: - API

    public enum Dimension {
        case content(scale: CGFloat = 1)
        case absolute(CGFloat)
        case relative(CGFloat)
    }

    public let dimension: Dimension

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    public func body(content: Content) -> some View {
        Group {
            switch dimension {
            case .absolute(let value):
                content
                    .preference(key: MinTitleHeightPreferenceKey.self, value: .absolute(value))
            case .relative(let value):
                content
                    .preference(key: MinTitleHeightPreferenceKey.self, value: .unit(value))
            case .content(let scale):
                content
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: MinTitleHeightPreferenceKey.self, value: .absolute(proxy.size.height * scale))
                        }
                    }
            }
        }
    }
}
