//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI

public extension View {
    func materialTabsitem<ItemID>(itemID: ItemID) -> some View where ItemID: Hashable {
        modifier(MaterialTabsItemModifier<ItemID>(itemID: itemID))
    }
}

struct MaterialTabsItemModifier<ItemID>: ViewModifier where ItemID: Hashable {

    // MARK: - API

    let itemID: ItemID

    // MARK: - Constants

    // MARK: - Variables

    // MARK: - Body

    func body(content: Content) -> some View {
        VStack {
            content
        }
        .tag(itemID)
    }
}
