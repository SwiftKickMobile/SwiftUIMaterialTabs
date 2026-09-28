#if DEBUG
import Foundation
import SwiftUI

struct MaterialTabsTraceRegistrationKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    @_spi(Testing) public var materialTabsTraceRegistration: Bool {
        get { self[MaterialTabsTraceRegistrationKey.self] }
        set { self[MaterialTabsTraceRegistrationKey.self] = newValue }
    }
}

/// Test-only observation. No publisher, view state, timers, or synchronization writes.
@_spi(Testing)
@MainActor public enum MaterialTabsTrace {
    public static let isEnabled = ProcessInfo.processInfo.environment["SUIMT_CONTEXT_TRACE"] == "1"

    private struct Event: Codable {
        let sequence: Int
        let uptime: TimeInterval
        let kind: String
        var headerID: String? = nil
        var pageID: String? = nil
        var tab: String? = nil
        var selectedTab: String? = nil
        var headerOffset: Double? = nil
        var contentOffset: Double? = nil
        var maximumOffset: Double? = nil
        var mode: String? = nil
        var appeared: Bool? = nil
        var reason: String? = nil
        var contentChanged: Bool? = nil
        var registration: Bool? = nil
        var maximumContentOffset: Double? = nil
        var consumer: String? = nil
        var updateID: Int? = nil
        var sourceSequence: Int? = nil
        var modelTime: Double? = nil
        var completionDeadline: Double? = nil
        var estimatedPresentationTime: Double? = nil
        var safeAreaTop: Double? = nil
        var tabBarHeight: Double? = nil
        var headerWidth: Double? = nil
    }
    private struct Report: Codable {
        let schemaVersion = 3
        let enabled: Bool
        let overflow: Bool
        let events: [Event]
    }
    private static var events: [Event] = []
    private static var overflow = false
    private static var latestViewContexts: [String: Event] = [:]
    private static var nextUpdateID = 0
    private static var lastModelOffsets: [String: Double] = [:]

    private static func append(_ event: Event) {
        guard events.count < 100_000 else { overflow = true; return }
        events.append(event)
    }

    static func context<Tab>(id: String, new: HeaderContext<Tab>,
                             mode: MaterialTabsConfig.CrossTabSyncMode) {
        guard isEnabled else { return }
        defer { lastModelOffsets[id] = Double(new.contentOffset) }
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "context", headerID: id, selectedTab: String(reflecting: new.selectedTab),
                     headerOffset: Double(new.offset), contentOffset: Double(new.contentOffset),
                     maximumOffset: Double(new.maxOffset), mode: modeName(mode),
                     contentChanged: lastModelOffsets[id] != Double(new.contentOffset),
                     safeAreaTop: Double(new.safeArea.top), tabBarHeight: Double(new.tabBarHeight),
                     headerWidth: Double(new.width)))
    }

    static func viewContext<Tab>(id: String, new: TraceContextSnapshot<Tab>,
                                 mode: MaterialTabsConfig.CrossTabSyncMode, consumer: String) {
        guard isEnabled else { return }
        // Record the value delivered by SwiftUI, NOT a fresh read of model.state.
        // A later mutation can already have happened when the callback executes.
        let event = Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "viewContext", headerID: id, selectedTab: String(reflecting: new.selectedTab),
                     headerOffset: Double(new.offset), contentOffset: Double(new.contentOffset),
                     maximumOffset: Double(new.maxOffset), mode: modeName(mode),
                     reason: "SwiftUI.body",
                     contentChanged: latestViewContexts["\(id)/\(consumer)"]?.contentOffset != Double(new.contentOffset),
                     consumer: consumer)
        append(event)
        latestViewContexts["\(id)/\(consumer)"] = event
    }

    static func viewDetached(id: String, consumer: String) {
        guard isEnabled else { return }
        latestViewContexts.removeValue(forKey: "\(id)/\(consumer)")
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "viewDetached", headerID: id, consumer: consumer))
    }

    /// Called ONLY by the demo's passive UIUpdateLink.afterUpdateComplete hook.
    /// Samples the last view-consumed value, never fresh model state. No UIKit
    /// dependency, requested updates, timers, or synchronization writes here.
    public static func updateCompleted(modelTime: Double, completionDeadline: Double,
                                       estimatedPresentationTime: Double) {
        sampleContexts(boundaryKind: "updateBoundary", contextKind: "updateContext",
                       reason: "UIUpdateLink.afterUpdateComplete", modelTime: modelTime,
                       completionDeadline: completionDeadline, presentationTime: estimatedPresentationTime)
    }

    /// Legacy-runtime fallback: display ticks, NOT after-update/render boundaries.
    public static func displaySampled(timestamp: Double, targetTimestamp: Double) {
        sampleContexts(boundaryKind: "displayTick", contextKind: "displayContext",
                       reason: "CADisplayLink.callback", modelTime: timestamp,
                       completionDeadline: nil, presentationTime: targetTimestamp)
    }

    private static func sampleContexts(boundaryKind: String, contextKind: String, reason: String,
                                       modelTime: Double, completionDeadline: Double?, presentationTime: Double) {
        guard isEnabled else { return }
        let updateID = nextUpdateID
        nextUpdateID += 1
        let time = ProcessInfo.processInfo.systemUptime
        append(Event(sequence: events.count, uptime: time, kind: boundaryKind,
                     reason: reason, updateID: updateID,
                     modelTime: modelTime, completionDeadline: completionDeadline,
                     estimatedPresentationTime: presentationTime))
        for key in latestViewContexts.keys.sorted() {
            guard let source = latestViewContexts[key] else { continue }
            append(Event(sequence: events.count, uptime: time, kind: contextKind,
                         headerID: source.headerID, selectedTab: source.selectedTab,
                         headerOffset: source.headerOffset, contentOffset: source.contentOffset,
                         maximumOffset: source.maximumOffset, mode: source.mode,
                         reason: reason, consumer: source.consumer,
                         updateID: updateID, sourceSequence: source.sequence))
        }
    }

    static func page<Tab>(kind: String, id: String, tab: Tab, header: HeaderModel<Tab>?,
                          offset: CGFloat, appeared: Bool, registration: Bool, reason: String? = nil) {
        guard isEnabled else { return }
        let context = header?.headerContext
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: kind, headerID: header?.traceID, pageID: id, tab: String(reflecting: tab),
                     selectedTab: context.map { String(reflecting: $0.selectedTab) },
                     headerOffset: context.map { Double($0.offset) }, contentOffset: Double(offset),
                     maximumOffset: context.map { Double($0.maxOffset) },
                     mode: header.map { modeName($0.config.crossTabSyncMode) },
                     appeared: appeared, reason: reason, registration: registration))
    }

    static func input<Tab>(kind: String, header: HeaderModel<Tab>, tab: Tab, offset: CGFloat? = nil) {
        guard isEnabled else { return }
        let context = header.headerContext
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: kind, headerID: header.traceID, tab: String(reflecting: tab),
                     selectedTab: String(reflecting: context.selectedTab),
                     headerOffset: Double(context.offset), contentOffset: offset.map { Double($0) },
                     maximumOffset: Double(context.maxOffset), mode: modeName(header.config.crossTabSyncMode)))
    }

    public static func scrollPhase(tab: String, phase: String) {
        guard isEnabled else { return }
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "phase", tab: tab, reason: phase))
    }

    /// Diagnostic only: body evaluation without reading probe state storage.
    public static func contentBody(tab: String, registration: Bool) {
        guard isEnabled else { return }
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "contentBody", tab: tab, registration: registration))
    }

    /// Diagnostic only: state-storage identity at the root of client tab content.
    public static func contentLifecycle(tab: String, phase: String, stateID: String,
                                        objectID: String, visits: Int, registration: Bool) {
        guard isEnabled else { return }
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "contentLifecycle", pageID: objectID, tab: tab,
                     reason: "\(phase) state=\(stateID) visits=\(visits)", registration: registration))
    }

    /// Called after the observed action; serialization is not on the emission path.
    public static func exportJSON() -> String {
        let report = Report(enabled: isEnabled, overflow: overflow, events: events)
        guard let data = try? JSONEncoder().encode(report), let value = String(data: data, encoding: .utf8) else {
            return "{\"error\":\"Trace encoding failed\"}"
        }
        return value
    }

    private static func modeName(_ mode: MaterialTabsConfig.CrossTabSyncMode) -> String {
        switch mode {
        case .preserveScrollPosition: "preserve"
        case .resetScrollPosition: "resetPosition"
        case .resetTitleOnScroll: "resetTitle"
        }
    }
}

/// Immutable scalar copy: HeaderContext is observable reference storage. Retaining
/// that reference in a preference would erase old values before delivery.
struct TraceContextSnapshot<Tab: Hashable>: Equatable {
    let selectedTab: Tab
    let offset: CGFloat
    let contentOffset: CGFloat
    let maxOffset: CGFloat

    init(_ context: HeaderContext<Tab>) {
        selectedTab = context.selectedTab
        offset = context.offset
        contentOffset = context.contentOffset
        maxOffset = context.maxOffset
    }
}

/// Captures values when the header consumes them, without scheduling work.
/// Only the last consumed value is sampled by the existing passive update hook.
/// Neither body evaluation nor an update boundary proves pixel presentation.
struct MaterialTabsContextObserver<Tab: Hashable>: ViewModifier {
    let context: TraceContextSnapshot<Tab>
    let headerID: String
    let mode: MaterialTabsConfig.CrossTabSyncMode
    var consumer = "header"

    func body(content: Content) -> some View {
        // onPreferenceChange can miss the final value of a same-update restore.
        // Record consumption directly; do not replace it with a later model read.
        MaterialTabsTrace.viewContext(id: headerID, new: context, mode: mode, consumer: consumer)
        return content
            .onDisappear { MaterialTabsTrace.viewDetached(id: headerID, consumer: consumer) }
    }
}
#endif
