//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI
import SwiftUIMaterialTabs

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                NativeScrollEdgeDemoView()
            } else {
                DemoView()
            }
        }
    }
}
