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
                if #available(iOS 26.0, *), ProcessInfo.processInfo.environment["SUIMT_NATIVE_REFERENCE"] == "1" {
                    NativeScrollEdgeReferenceView()
                } else if ProcessInfo.processInfo.environment["SUIMT_FLICK_FIXTURE"] == "1" {
                    FlickRegressionView()
                } else if ProcessInfo.processInfo.environment["SUIMT_EXTERNAL_POSITION"] == "1" {
                    ExternalScrollRegressionView()
                } else {
                    MaterialTabsTestView()
                }
            }
            .background {
                #if DEBUG
                if MaterialTabsTrace.isEnabled, !ManualInteractionTrace.isEnabled {
                    ContextUpdateBoundaryObserver().allowsHitTesting(false)
                }
                #endif
            }
            .overlay(alignment: .bottomTrailing) {
                #if DEBUG
                if MaterialTabsTrace.isEnabled, !ManualInteractionTrace.isEnabled {
                    ContextTraceExportButton()
                }
                #endif
            }
        }
    }
}
