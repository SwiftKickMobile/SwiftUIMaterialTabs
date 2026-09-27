//
//  Created by Timothy Moose on 1/14/24.
//

import SwiftUI
@_spi(Testing) import SwiftUIMaterialTabs

@main
struct DemoApp: App {
    init() {
        #if DEBUG
        ManualInteractionTrace.startIfEnabled()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let variant = ProcessInfo.processInfo.environment["SUIMT_BINDING_REPRO"] {
                    PagerBindingRepro(variant: variant)
                } else if #available(iOS 26.0, *), ProcessInfo.processInfo.environment["SUIMT_NATIVE_REFERENCE"] == "1" {
                    TabSyncRegressionView()
                } else if #available(iOS 26.0, *), ProcessInfo.processInfo.environment["SUIMT_NATIVE_FLICK_CONTROL"] == "1" {
                    NativeFlickRoutingControl()
                } else if #available(iOS 18.0, *), ProcessInfo.processInfo.environment["SUIMT_FLICK_FIXTURE"] == "1" {
                    FlickRegressionView()
                } else if ProcessInfo.processInfo.environment["SUIMT_EXTERNAL_POSITION"] == "1",
                          ProcessInfo.processInfo.environment["SUIMT_BROAD_REPLAY"] == "1" {
                    ExternalScrollRegressionView()
                } else if #available(iOS 26.0, *) {
                    if ProcessInfo.processInfo.environment["SUIMT_UI_REGRESSION"] == "1" {
                        TabSyncRegressionView()
                    } else if ProcessInfo.processInfo.environment["SUIMT_STANDALONE_REPRO"] == "1" {
                        LazyPagerStateRepro()
                    } else {
                        NativeScrollEdgeDemoView()
                    }
                } else {
                    NativeScrollEdgeDemoView()
                }
            }
            .background {
                #if DEBUG
                if MaterialTabsTrace.isEnabled, !ManualInteractionTrace.isEnabled, #available(iOS 18.0, *) {
                    ContextUpdateBoundaryObserver()
                        .allowsHitTesting(false)
                }
                #endif
            }
            .overlay(alignment: .bottomTrailing) {
                #if DEBUG
                if MaterialTabsTrace.isEnabled, !ManualInteractionTrace.isEnabled {
                    if ProcessInfo.processInfo.environment["SUIMT_MANUAL_TRACE"] == "1" {
                        ContextTraceReadout()
                    } else {
                        ContextTraceExportButton()
                    }
                }
                #endif
            }
        }
    }
}
