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

    private static func append(_ event: Event) {
        guard events.count < 100_000 else { overflow = true; return }
        events.append(event)
    }

    static func context<Tab>(id: String, old: HeaderContext<Tab>, new: HeaderContext<Tab>,
                             mode: MaterialTabsConfig.CrossTabSyncMode) {
        guard isEnabled else { return }
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "context", headerID: id, selectedTab: String(reflecting: new.selectedTab),
                     headerOffset: Double(new.offset), contentOffset: Double(new.contentOffset),
                     maximumOffset: Double(new.maxOffset), mode: modeName(mode),
                     contentChanged: old.contentOffset != new.contentOffset,
                     safeAreaTop: Double(new.safeArea.top), tabBarHeight: Double(new.tabBarHeight),
                     headerWidth: Double(new.width)))
    }

    static func viewContext<Tab>(id: String, old: HeaderContext<Tab>, new: HeaderContext<Tab>,
                                 mode: MaterialTabsConfig.CrossTabSyncMode, consumer: String,
                                 preference: Bool = false) {
        guard isEnabled else { return }
        // Record the value delivered by SwiftUI, NOT a fresh read of model.state.
        // A later mutation can already have happened when the callback executes.
        let event = Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "viewContext", headerID: id, selectedTab: String(reflecting: new.selectedTab),
                     headerOffset: Double(new.offset), contentOffset: Double(new.contentOffset),
                     maximumOffset: Double(new.maxOffset), mode: modeName(mode),
                     reason: preference ? "SwiftUI.onPreferenceChange" : "SwiftUI.onChange",
                     contentChanged: preference
                        ? latestViewContexts["\(id)/\(consumer)"]?.contentOffset != Double(new.contentOffset)
                        : old.contentOffset != new.contentOffset,
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

    /// Diagnostic only: distinguish a stale onChange cache from the value
    /// actually supplied to the observer's body. This is NOT a render boundary.
    static func viewEvaluated<Tab>(id: String, context: HeaderContext<Tab>, consumer: String) {
        guard isEnabled, ProcessInfo.processInfo.environment["SUIMT_FLICK_FIXTURE"] == "1" else { return }
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "viewEvaluation", headerID: id,
                     selectedTab: String(reflecting: context.selectedTab),
                     headerOffset: Double(context.offset), contentOffset: Double(context.contentOffset),
                     maximumOffset: Double(context.maxOffset), consumer: consumer))
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
        let context = header?.state.headerContext
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: kind, headerID: header?.traceID, pageID: id, tab: String(reflecting: tab),
                     selectedTab: context.map { String(reflecting: $0.selectedTab) },
                     headerOffset: context.map { Double($0.offset) }, contentOffset: Double(offset),
                     maximumOffset: context.map { Double($0.maxOffset) },
                     mode: header.map { modeName($0.state.config.crossTabSyncMode) },
                     appeared: appeared, reason: reason, registration: registration))
    }

    static func input<Tab>(kind: String, header: HeaderModel<Tab>, tab: Tab, offset: CGFloat? = nil) {
        guard isEnabled else { return }
        let context = header.state.headerContext
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: kind, headerID: header.traceID, tab: String(reflecting: tab),
                     selectedTab: String(reflecting: context.selectedTab),
                     headerOffset: Double(context.offset), contentOffset: offset.map { Double($0) },
                     maximumOffset: Double(context.maxOffset), mode: modeName(header.state.config.crossTabSyncMode)))
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

    public static func scrollRange(tab: String, offset: Double, maximum: Double, viewport: Double) {
        guard isEnabled, viewport > 0 else { return }
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "range", tab: tab, contentOffset: offset, maximumContentOffset: maximum))
    }

    /// Called after the observed action; serialization is not on the emission path.
    public static func exportJSON() -> String {
        let report = Report(enabled: isEnabled, overflow: overflow, events: events)
        guard let data = try? JSONEncoder().encode(report), let value = String(data: data, encoding: .utf8) else {
            return "{\"error\":\"Trace encoding failed\"}"
        }
        return value
    }

    /// Exercises the recorder on a detached model in one synchronous call.
    /// It never changes any model displayed by the demo.
    public static func runRecorderSelfTest() {
        guard isEnabled else { return }
        let probe = HeaderModel<Int>(selectedTab: 0)
        append(Event(sequence: events.count, uptime: ProcessInfo.processInfo.systemUptime,
                     kind: "probeBegin", headerID: probe.traceID))
        probe.titleHeightChanged(150)
        probe.tabBarHeightChanged(46)
        probe.scrolled(tab: 0, contentOffset: 175, deltaContentOffset: 175)
        probe.scrolled(tab: 0, contentOffset: 0, deltaContentOffset: -175)
        probe.scrolled(tab: 0, contentOffset: 175, deltaContentOffset: 175)
    }

    private static func modeName(_ mode: MaterialTabsConfig.CrossTabSyncMode) -> String {
        switch mode {
        case .preserveScrollPosition: "preserve"
        case .resetScrollPosition: "resetPosition"
        case .resetTitleOnScroll: "resetTitle"
        }
    }
}

/// SwiftUI preference observation, not a compositor/frame-presented callback.
/// The callback appends data only; it never publishes state or schedules work.
struct MaterialTabsContextObserver<Tab: Hashable>: ViewModifier {
    let context: HeaderContext<Tab>
    let headerID: String
    let mode: MaterialTabsConfig.CrossTabSyncMode
    var consumer = "header"

    private struct Input: Equatable {
        let context: HeaderContext<Tab>
        let headerID: String
        let mode: MaterialTabsConfig.CrossTabSyncMode
    }

    private struct ObservedInput: PreferenceKey {
        static var defaultValue: Input? { nil }
        static func reduce(value: inout Input?, nextValue: () -> Input?) {
            if let next = nextValue() { value = next }
        }
    }

    func body(content: Content) -> some View {
        MaterialTabsTrace.viewEvaluated(id: headerID, context: context, consumer: consumer)
        // A same-cycle restoration can update this body without delivering the
        // corresponding onChange callback (captured in the phase-switch fixture).
        // Propagate the value through SwiftUI's preference pass instead. Do not
        // substitute a model read or treat body evaluation as a presented frame.
        return content
        .preference(key: ObservedInput.self, value: Input(context: context, headerID: headerID, mode: mode))
        .onPreferenceChange(ObservedInput.self) { input in
            guard let input else { return }
            MaterialTabsTrace.viewContext(id: input.headerID, old: input.context, new: input.context,
                                          mode: input.mode, consumer: consumer, preference: true)
        }
        .onDisappear { MaterialTabsTrace.viewDetached(id: headerID, consumer: consumer) }
    }
}

/// End-to-end positive/negative controls for the SAME observer used by HeaderView.
/// This detached model is never used to position the app's actual tabs.
@_spi(Testing)
@MainActor public struct MaterialTabsContextProbe: View {
    @StateObject private var model = MaterialTabsContextProbe.makeModel()

    public init() {}

    private static func makeModel() -> HeaderModel<Int> {
        let model = HeaderModel<Int>(selectedTab: 0)
        model.configChanged(.init(crossTabSyncMode: .preserveScrollPosition))
        model.titleHeightChanged(150)
        model.tabBarHeightChanged(46)
        model.scrolled(tab: 0, contentOffset: 150, deltaContentOffset: 150)
        return model
    }

    public var body: some View {
        VStack {
            Text("Probe offset: \(model.state.headerContext.offset)")
            HStack {
                Button("Between updates") {
                    model.scrolled(tab: 0, contentOffset: 0, deltaContentOffset: -150)
                    model.scrolled(tab: 0, contentOffset: 150, deltaContentOffset: 150)
                }
                .accessibilityIdentifier("context-probe-coalesced")
                Button("Expose zero") {
                    model.scrolled(tab: 0, contentOffset: 0, deltaContentOffset: -150)
                }
                .accessibilityIdentifier("context-probe-zero")
                Button("Restore") {
                    model.scrolled(tab: 0, contentOffset: 150, deltaContentOffset: 150)
                }
                .accessibilityIdentifier("context-probe-restore")
            }
        }
        .font(.caption)
        .modifier(MaterialTabsContextObserver(context: model.state.headerContext,
                                              headerID: model.traceID,
                                              mode: model.state.config.crossTabSyncMode,
                                              consumer: "probe"))
    }
}
#endif
