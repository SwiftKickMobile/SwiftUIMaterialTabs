//
//  Created by Timothy Moose on 1/20/24.
//

import SwiftUI

/// A protocol used by the `headerStyle()` view modifier for easy creation of unique sticky header effects,
/// such as fade, shink and parallax.
///
/// During scrolling, the header is offset to track the scroll position. The header sticks in its fully collapsed position when the offset
/// reaches `HeaderContext/maxOffset`, which is derived from the measured tab bar height and any minimum title height established by
/// the `minTitleHeight()` view modifier.
///
/// In the other direction, when the scroll is pulled past the top rest position, a.k.a "rubber banding", the title view's height is increased
/// to track the offset.
///
/// Although the collapsed state of the header is just an offset, applying the `headerStyle()` view modifier to header elements can give the
/// impression of shrinking, fading, parallax, etc. All of these effects are achived by manipulating the views based on the `HeaderContext`
/// values provided to the various header view builders. You may also manipulate header elements directly without using `headerStyle()` if you wish.
public protocol HeaderStyle {

    associatedtype Body: View
    associatedtype Tab: Hashable
    typealias Content = AnyView

    func makeBody(context: HeaderContext<Tab>, content: Content) -> Self.Body
}
