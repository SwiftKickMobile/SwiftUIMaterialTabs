//
//  TestHostApp.swift
//  TestHost
//
//  Created by Timothy Moose on 9/27/26.
//

import SwiftUI
@_spi(Testing) import SwiftUIMaterialTabs

@main
struct TestHostApp: App {
    init() {
        #if DEBUG
        ManualInteractionTrace.startIfEnabled()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if ProcessInfo.processInfo.environment["SUIMT_JITTER_REGRESSION"] == "1" {
                    JitterRegressionView()
                } else if ProcessInfo.processInfo.environment["SUIMT_PADDING_REGRESSION"] == "1" {
                    PaddedScrollRegressionView()
                } else if #available(iOS 26.0, *), ProcessInfo.processInfo.environment["SUIMT_NATIVE_REFERENCE"] == "1" {
                    NativeScrollEdgeReferenceView()
                } else if ProcessInfo.processInfo.environment["SUIMT_FLICK_FIXTURE"] == "1" {
                    FlickRegressionView()
                } else if ProcessInfo.processInfo.environment["SUIMT_EXTERNAL_POSITION"] == "1" {
                    ExternalScrollRegressionView()
                } else {
                    MaterialTabsTestView()
                }
            }
        }
    }
}
