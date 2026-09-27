import Foundation

struct ContextTraceReport: Codable {
    var schemaVersion = 3
    var enabled = true
    var overflow = false
    var events: [ContextTraceEvent]
}

struct ContextTraceEvent: Codable {
    var sequence: Int
    var uptime: TimeInterval
    var kind: String
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
}

struct ContextViolation: CustomStringConvertible {
    let rule: String
    let sequence: Int?
    let detail: String
    var description: String { "\(rule) at event \(sequence.map(String.init) ?? "n/a"): \(detail)" }
}

/// Integrity checks used by the runtime observer calibration controls.
struct ObserverTraceIntegrity {
    static func boundaryIntegrity(_ report: ContextTraceReport) -> [ContextViolation] {
        var latest: [String: ContextTraceEvent] = [:]
        var boundary: ContextTraceEvent?
        var expectedUpdateID = 0
        var sampled: Set<String> = []
        var failures: [ContextViolation] = []
        func fail(_ event: ContextTraceEvent, _ detail: String) {
            failures.append(.init(rule: "boundary-integrity", sequence: event.sequence, detail: detail))
        }
        func checkCoverage() {
            if let boundary, sampled != Set(latest.keys) {
                fail(boundary, "Not every active view was sampled at the boundary")
            }
        }
        for event in report.events {
            if event.kind == "updateContext" {
                let key = "\(event.headerID ?? "")/\(event.consumer ?? "")"
                guard let boundary, let source = latest[key],
                      event.updateID == boundary.updateID, event.uptime == boundary.uptime,
                      event.sourceSequence == source.sequence,
                      event.selectedTab == source.selectedTab,
                      event.headerOffset == source.headerOffset, event.contentOffset == source.contentOffset,
                      event.maximumOffset == source.maximumOffset, event.mode == source.mode,
                      sampled.insert(key).inserted else {
                    fail(event, "Sample does not match its boundary and latest view-context source")
                    continue
                }
            } else {
                checkCoverage()
                boundary = nil
                if event.kind == "updateBoundary" {
                    if event.updateID != expectedUpdateID || event.reason != "UIUpdateLink.afterUpdateComplete"
                        || event.modelTime?.isFinite != true || event.completionDeadline?.isFinite != true
                        || event.estimatedPresentationTime?.isFinite != true {
                        fail(event, "Missing update identity, timing, or expected phase")
                    }
                    expectedUpdateID += 1
                    boundary = event
                    sampled = []
                } else if event.kind == "viewContext", let id = event.headerID, let consumer = event.consumer {
                    latest["\(id)/\(consumer)"] = event
                } else if event.kind == "viewDetached", let id = event.headerID, let consumer = event.consumer {
                    latest.removeValue(forKey: "\(id)/\(consumer)")
                }
            }
        }
        checkCoverage()
        if expectedUpdateID == 0 {
            failures.append(.init(rule: "boundary-integrity", sequence: nil, detail: "No UIUpdateLink boundary callbacks"))
        }
        return failures
    }
}
