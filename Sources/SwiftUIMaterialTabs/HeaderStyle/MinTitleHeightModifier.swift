//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

public extension View {
    /// A view modifier that specifies a minimum effective height for the title view for making sticky title elements when paired with
    /// `FixedHeaderStyle`. As content scrolls, the header is offset to track scrolling until the tab bar reaches the top safe area. However, when
    /// this view modifier is applied, the header sticks when the bottom `minTitleHeight` of the title reaches the top safe area.
    func minTitleHeight(_ metric: MinTitleHeightModifier.Metric) -> some View {
        modifier(MinTitleHeightModifier(metric: metric))
    }
}

public struct MinTitleHeightModifier: ViewModifier {

    // MARK: - API

    /// The minimum title height metric.
    public enum Metric {
        
        /// Determine the height by measuring the receiving view's height. If the receiving view will be scaled down, such as when `ScaleHeaderStyle`
        /// is applied, provide a matching scale factor here.
        case content(scale: CGFloat = 1)

        /// Sets the height to an absolute value.
        case absolute(CGFloat)

        /// Sets the height to a percentage of the total title height. Provie a value in the range of 0 and 1.
        case relative(CGFloat)
    }

    public let metric: Metric

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    public func body(content: Content) -> some View {
        Group {
            switch metric {
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
