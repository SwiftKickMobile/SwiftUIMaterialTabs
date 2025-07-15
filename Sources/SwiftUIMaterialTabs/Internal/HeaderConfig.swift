//
//  Created by Timothy Moose on 7/13/25.
//

import SwiftUI

/// Configuration for sticky header behavior, used by both MaterialTabs and StickyHeader components.
public struct HeaderConfig: Equatable {
    
    /// Specifies the scroll-up behavior for sticky headers.
    public enum ScrollUpSnapMode: Equatable {
        /// The header tracks scroll position continuously (default behavior).
        /// When scrolling up, the header position moves in sync with the scroll view until it reaches the maximum expanded position.
        case trackScrollPosition
        
        /// The header snaps to fully expanded position after detecting scroll-up intent.
        /// When scrolling up continuously for a threshold amount, the header animates to the fully expanded position.
        case snapToExpanded
    }
    
    /// Specifies how the header should behave when the user scrolls up.
    public var scrollUpSnapMode: ScrollUpSnapMode
    
    /// Creates a new header configuration.
    /// - Parameter scrollUpSnapMode: The scroll-up behavior mode. Defaults to `.trackScrollPosition` to maintain backward compatibility.
    public init(scrollUpSnapMode: ScrollUpSnapMode = .trackScrollPosition) {
        self.scrollUpSnapMode = scrollUpSnapMode
    }
}

