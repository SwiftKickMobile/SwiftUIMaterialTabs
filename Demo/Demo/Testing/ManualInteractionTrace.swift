#if DEBUG
import Darwin
import ObjectiveC.runtime
import SwiftUI
import UIKit
@_spi(Testing) import SwiftUIMaterialTabs

/// Opt-in, app-local input observation for a manual reproduction. No gesture
/// recognizer, extra view, timer, touch cancellation, or synchronous disk I/O
/// during interaction. UIApplication still receives each event exactly once.
/// The method exchange exists only in this Debug demo process, never the library.
@MainActor
enum ManualInteractionTrace {
    static let isEnabled = ProcessInfo.processInfo.environment["SUIMT_MANUAL_CAPTURE"] == "1"

    private struct TouchSample: Codable {
        let deliveredAt: Double
        let eventTimestamp: Double
        let touchTimestamp: Double
        let id: Int
        let phase: String
        let x: Double
        let y: Double
        let windowWidth: Double
        let windowHeight: Double
        let touchType: Int
        let tapCount: Int
    }

    private static var installed = false
    private static var saveSignal: DispatchSourceSignal?
    private static var initialWindowObserver: NSObjectProtocol?
    private static var touches: [TouchSample] = []
    private static var touchIDs: [ObjectIdentifier: Int] = [:]
    private static var nextTouchID = 0
    private static var overflow = false
    private static var startedAt = 0.0
    private static var startedDate = ""
    private static let capturesRouting = ProcessInfo.processInfo.environment["SUIMT_TOUCH_ROUTING"] == "1"
    private struct RoutingSample: Codable {
        let uptime: Double
        let stage: String
        let eventType: Int
        let touchTimestamp: Double
        let phase: Int
        let touchID: String
        let windowID: String?
        let viewType: String?
        let x: Double
        let y: Double
    }
    private static var routingSamples: [RoutingSample] = []

    /// Opt-in diagnosis of touches omitted by the normal window-scoped recorder.
    /// Observes before/after dispatch without hit testing, layout, or UI queries.
    static func observeRouting(_ event: UIEvent, stage: String) {
        guard installed, capturesRouting, routingSamples.count < 40_000 else { return }
        for touch in event.allTouches ?? [] where touch.phase != .stationary {
            let point = touch.location(in: touch.window)
            routingSamples.append(RoutingSample(uptime: ProcessInfo.processInfo.systemUptime,
                stage: stage, eventType: event.type.rawValue, touchTimestamp: touch.timestamp,
                phase: touch.phase.rawValue, touchID: String(describing: ObjectIdentifier(touch)),
                windowID: touch.window.map { String(describing: ObjectIdentifier($0)) },
                viewType: touch.view.map { String(reflecting: type(of: $0)) },
                x: Double(point.x), y: Double(point.y)))
        }
    }

    private struct RowFrame: Codable {
        let uptime: Double
        let tab: String
        let row: Int
        let present: Bool
        let minX: Double
        let minY: Double
        let width: Double
        let height: Double
    }
    private static var rowFrames: [RowFrame] = []
    private static var rowFrameOverflow = false
    private struct ExternalRequest: Codable {
        let uptime: Double
        let tab: String
        let row: Int
    }
    private static var externalRequests: [ExternalRequest] = []

    static func recordExternalRequest(tab: String, row: Int) {
        guard isEnabled else { return }
        externalRequests.append(ExternalRequest(uptime: ProcessInfo.processInfo.systemUptime, tab: tab, row: row))
    }

    /// Passive geometry from the external-position fixture, not a scroll target.
    static func recordRowFrame(tab: String, row: Int, frame: CGRect?) {
        guard isEnabled else { return }
        guard rowFrames.count < 20_000 else { rowFrameOverflow = true; return }
        rowFrames.append(RowFrame(uptime: ProcessInfo.processInfo.systemUptime, tab: tab, row: row,
                                  present: frame != nil, minX: Double(frame?.minX ?? 0),
                                  minY: Double(frame?.minY ?? 0), width: Double(frame?.width ?? 0),
                                  height: Double(frame?.height ?? 0)))
    }

    static func startIfEnabled() {
        guard isEnabled, !installed else { return }
        guard let original = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.sendEvent(_:))),
              let observer = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.suimt_manualTrace_sendEvent(_:))) else {
            NSLog("SUIMT_MANUAL_CAPTURE_ERROR could not install event observer")
            return
        }
        startedAt = ProcessInfo.processInfo.systemUptime
        startedDate = ISO8601DateFormatter().string(from: Date())
        method_exchangeImplementations(original, observer)
        installed = true
        if ProcessInfo.processInfo.environment["SUIMT_BROAD_REPLAY"] == "1" {
            // Expanded cold swipes can be the FIRST input. Observe the initial
            // window updates, rather than waiting for touch-down to attach the
            // sampler and then missing the source's pre-swipe context.
            initialWindowObserver = NotificationCenter.default.addObserver(
                forName: UIWindow.didBecomeKeyNotification, object: nil, queue: .main
            ) { notification in
                MainActor.assumeIsolated {
                    if let window = notification.object as? UIWindow {
                        NativeScrollSnapshot.observe(window)
                    }
                }
            }
        }
        // Save only when explicitly requested after the user's interaction.
        // SIGUSR1 is sent externally; it does not synthesize a tap or refresh UI.
        signal(SIGUSR1, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: SIGUSR1, queue: .main)
        source.setEventHandler { save() }
        source.resume()
        saveSignal = source
        // The UI-test runner can also request a save AFTER replay, without an
        // accessibility lookup or extra touch. Darwin notifications carry no
        // payload; the trace remains in this app's Documents directory.
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, { _, _, _, _, _ in
            DispatchQueue.main.async { ManualInteractionTrace.save() }
        }, "com.swiftkickmobile.Demo.saveManualTrace" as CFString, nil, .deliverImmediately)
        NSLog("SUIMT_MANUAL_CAPTURE_READY pid=%d", ProcessInfo.processInfo.processIdentifier)
    }

    static func observe(_ event: UIEvent) {
        guard installed, event.type == .touches else { return }
        for touch in event.allTouches ?? [] {
            guard touch.phase != .stationary, let window = touch.window else { continue }
            NativeScrollSnapshot.observe(window)
            let key = ObjectIdentifier(touch)
            let id: Int
            if let existing = touchIDs[key] {
                id = existing
            } else {
                id = nextTouchID
                nextTouchID += 1
                touchIDs[key] = id
            }
            let location = touch.location(in: window)
            let phase: String
            switch touch.phase {
            case .began: phase = "began"
            case .moved: phase = "moved"
            case .ended: phase = "ended"
            case .cancelled: phase = "cancelled"
            default: phase = "phase-\(touch.phase.rawValue)"
            }
            if touches.count < 20_000 {
                touches.append(TouchSample(
                    deliveredAt: ProcessInfo.processInfo.systemUptime,
                    eventTimestamp: event.timestamp, touchTimestamp: touch.timestamp,
                    id: id, phase: phase, x: Double(location.x), y: Double(location.y),
                    windowWidth: Double(window.bounds.width), windowHeight: Double(window.bounds.height),
                    touchType: touch.type.rawValue, tapCount: touch.tapCount))
            } else {
                overflow = true
            }
            if touch.phase == .ended || touch.phase == .cancelled {
                touchIDs.removeValue(forKey: key)
            }
        }
    }

    private static func save() {
        do {
            NativeScrollSnapshot.captureForExport()
            let touchData = try JSONEncoder().encode(touches)
            let contextData = Data(MaterialTabsTrace.exportJSON().utf8)
            var report: [String: Any] = [
                "formatVersion": 1, "startedAt": startedAt, "startedDate": startedDate,
                "savedAt": ProcessInfo.processInfo.systemUptime,
                "processID": ProcessInfo.processInfo.processIdentifier,
                "inputOverflow": overflow, "activeTouchCount": touchIDs.count,
                "coordinateSpace": "UIWindow bounds in points",
                "contextSampling": NativeScrollSnapshot.contextSampling,
                "osMajor": ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
                "captureLabel": ProcessInfo.processInfo.environment["SUIMT_CAPTURE_LABEL"] ?? "",
                "touches": try JSONSerialization.jsonObject(with: touchData),
                "context": try JSONSerialization.jsonObject(with: contextData)
            ]
            if ProcessInfo.processInfo.environment["SUIMT_EXTERNAL_POSITION"] == "1"
                || ProcessInfo.processInfo.environment["SUIMT_NATIVE_REFERENCE"] == "1" {
                report["rowFrames"] = try JSONSerialization.jsonObject(with: JSONEncoder().encode(rowFrames))
                report["rowFrameOverflow"] = rowFrameOverflow
                report["externalRequests"] = try JSONSerialization.jsonObject(with: JSONEncoder().encode(externalRequests))
            }
            if NativeScrollSnapshot.isEnabled, NativeScrollSnapshot.capturesNativeScrolls {
                report["nativeScrollSnapshots"] = try JSONSerialization.jsonObject(
                    with: JSONEncoder().encode(NativeScrollSnapshot.samples))
                report["nativeScrollOverflow"] = NativeScrollSnapshot.overflow
            }
            if capturesRouting {
                report["touchRouting"] = try JSONSerialization.jsonObject(with: JSONEncoder().encode(routingSamples))
            }
            if let plan = ProcessInfo.processInfo.environment["SUIMT_REPLAY_PLAN"] {
                report["replayPlan"] = try JSONSerialization.jsonObject(with: Data(plan.utf8))
            }
            if let profile = ProcessInfo.processInfo.environment["SUIMT_FIXTURE_VIEWPORT"] {
                report["fixtureViewport"] = try JSONSerialization.jsonObject(with: Data(profile.utf8))
            }
            let url = URL.documentsDirectory.appending(path: "manual-interaction-trace.json")
            let data = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys])
            let handoffOnly = ProcessInfo.processInfo.environment["SUIMT_HANDOFF_ONLY"] == "1"
            if !handoffOnly { try data.write(to: url, options: .atomic) }
            // Simulator-only test-runner handoff. The runner supplies its own
            // temporary file, so no accessibility query is needed between steps.
            #if targetEnvironment(simulator)
            if let path = ProcessInfo.processInfo.environment["SUIMT_PASSIVE_TRACE_PATH"] {
                try data.write(to: URL(fileURLWithPath: path), options: .atomic)
            }
            #endif
            let label = String((ProcessInfo.processInfo.environment["SUIMT_CAPTURE_LABEL"] ?? "")
                .filter { "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_".contains($0) }.prefix(100))
            if !handoffOnly && !label.isEmpty {
                try data.write(to: URL.documentsDirectory.appending(path: "manual-\(label).json"), options: .atomic)
            }
            NSLog("SUIMT_MANUAL_CAPTURE_SAVED touches=%d path=%@", touches.count, url.path)
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                CFNotificationName("com.swiftkickmobile.Demo.manualTraceSaved" as CFString), nil, nil, true)
        } catch {
            NSLog("SUIMT_MANUAL_CAPTURE_ERROR %@", String(describing: error))
        }
    }
}

extension UIApplication {
    @objc fileprivate dynamic func suimt_manualTrace_sendEvent(_ event: UIEvent) {
        ManualInteractionTrace.observeRouting(event, stage: "before")
        ManualInteractionTrace.observe(event)
        // After the exchange, this selector invokes the original sendEvent.
        suimt_manualTrace_sendEvent(event)
        ManualInteractionTrace.observeRouting(event, stage: "after")
    }
}
#endif
