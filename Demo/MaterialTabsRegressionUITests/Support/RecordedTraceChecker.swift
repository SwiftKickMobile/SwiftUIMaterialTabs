import Foundation

/// JSON preserves the recorded values without substituting model targets for observations.
indirect enum TraceJSON: Codable, Equatable {
    case object([String: TraceJSON]), array([TraceJSON]), string(String), number(Double), bool(Bool), null
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Double.self) { self = .number(v) }
        else if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode([TraceJSON].self) { self = .array(v) }
        else { self = .object(try c.decode([String: TraceJSON].self)) }
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .object(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .number(let v): try c.encode(v)
        case .bool(let v): try c.encode(v)
        case .null: try c.encodeNil()
        }
    }
    subscript(_ key: String) -> Self { if case .object(let v) = self { return v[key] ?? .null }; return .null }
    subscript(_ index: Int) -> Self { let a = array; return a.indices.contains(index) ? a[index] : .null }
    var array: [Self] { if case .array(let v) = self { return v }; return [] }
    var object: [String: Self] { if case .object(let v) = self { return v }; return [:] }
    var string: String { if case .string(let v) = self { return v }; return "" }
    var number: Double { if case .number(let v) = self { return v }; return .nan }
    var bool: Bool { self == .bool(true) }
    var exists: Bool { self != .null }
    func number(or fallback: Double) -> Double { exists ? number : fallback }
}

struct RecordedTraceError: Error, CustomStringConvertible {
    enum Kind: String { case failure, inconclusive }
    let kind: Kind
    let detail: String
    var description: String { "\(kind.rawValue.uppercased()): \(detail)" }
}

/// Port of the validated recorded-input oracle. Runs AFTER replay, never between
/// gestures, and never queries the accessibility tree or changes library state.
struct RecordedTraceChecker {
    typealias J = TraceJSON
    let plans: J
    static let tabs = ["overview", "activity", "notes"]

    func require(_ condition: Bool, _ detail: String, evidence: Bool = false) throws {
        if !condition { throw RecordedTraceError(kind: evidence ? .inconclusive : .failure, detail: detail) }
    }
    func equal(_ actual: Double, _ expected: Double, _ detail: String) throws {
        try require(actual.isFinite && expected.isFinite && abs(actual - expected) <= 0.5,
                    "\(detail): expected \(expected), got \(actual)")
    }
    func name(_ value: J) -> String { value.string.split(separator: ".").last.map(String.init) ?? "" }
    func key(_ event: J) -> [J] { [event["headerID"], event["consumer"]] }
    func gestures(_ report: J) -> [[J]] {
        var identifiers: [J] = [], result: [[J]] = []
        for touch in report["touches"].array {
            if let i = identifiers.firstIndex(of: touch["id"]) { result[i].append(touch) }
            else { identifiers.append(touch["id"]); result.append([touch]) }
        }
        return result
    }
    func movement(_ gesture: [J]) -> Double {
        guard let first = gesture.first else { return .nan }
        return gesture.map { abs($0["y"].number - first["y"].number) + abs($0["x"].number - first["x"].number) }.max() ?? .nan
    }
    func latestCapture(_ report: J, before cutoff: Double) throws -> J {
        guard let sample = report["nativeScrollSnapshots"].array.last(where: { $0["uptime"].number < cutoff }) else {
            throw RecordedTraceError(kind: .inconclusive, detail: "No actual scroll measurement at checkpoint")
        }
        return sample
    }
    func vertical(_ scroll: J, width: Double) -> Bool {
        abs(scroll["frameX"].number) <= 0.5 && abs(scroll["frameWidth"].number - width) <= 0.5 &&
        scroll["contentWidth"].number <= scroll["boundsWidth"].number + 0.5 &&
        scroll["contentHeight"].number + scroll["insetTop"].number(or: 0) + scroll["insetBottom"].number(or: 0) > scroll["boundsHeight"].number + 0.5
    }
    func normalized(_ scroll: J) throws -> Double {
        let actual = scroll["offsetY"].number + scroll["insetTop"].number
        try require(actual.isFinite && abs(actual - scroll["normalizedOffset"].number) <= 0.01,
                    "Invalid native offset normalization", evidence: true)
        if scroll["presentationOffset"].exists {
            try require(abs(scroll["presentationOffset"].number - actual) <= 0.5,
                        "Checkpoint still contains a presentation animation", evidence: true)
        }
        return actual
    }
    func initialPager(_ report: J, tab: String, firstInput: Double) throws {
        let sample = try latestCapture(report, before: firstInput), width = sample["windowWidth"].number
        let pagers = sample["scrolls"].array.filter {
            abs($0["boundsWidth"].number - width) <= 0.5 && abs($0["frameX"].number) <= 0.5 && abs($0["contentWidth"].number - 3 * width) <= 0.5
        }
        try require(pagers.count == 1, "No unique three-page horizontal pager before input", evidence: true)
        guard let index = Self.tabs.firstIndex(of: tab) else { throw RecordedTraceError(kind: .inconclusive, detail: "Unknown initial tab") }
        let actual = pagers[0]["offsetX"].number + pagers[0]["insetLeft"].number(or: 0)
        try require(actual.isFinite && abs(actual - Double(index) * width) <= 0.5,
                    "Invalid launch setup: requested \(tab), actual pager offset \(actual) BEFORE input", evidence: true)
    }
    func lifetimes(_ events: [J]) throws -> J {
        var identities: [String: J] = [:]
        let regex = try NSRegularExpression(pattern: "state=([^ ]+)")
        for event in events where event["kind"].string == "contentLifecycle" && !event["registration"].bool {
            let reason = event["reason"].string as NSString
            guard let match = regex.firstMatch(in: reason as String, range: NSRange(location: 0, length: reason.length)), !event["pageID"].string.isEmpty else {
                throw RecordedTraceError(kind: .inconclusive, detail: "Incomplete client state identity observation")
            }
            let tab = event["tab"].string.lowercased()
            let identity = J.array([event["pageID"], .string(reason.substring(with: match.range(at: 1)))])
            if let old = identities[tab] { try require(old == identity, "\(tab): client tab state was replaced") }
            identities[tab] = identity
        }
        try require(!identities.isEmpty, "No client state identity observations", evidence: true)
        let selected = Set(events.filter { $0["kind"].string == "context" && $0["selectedTab"].exists }.map { name($0["selectedTab"]).lowercased() })
        try require(selected.isSubset(of: Set(identities.keys)), "Missing client state for selected tabs", evidence: true)
        return .object(identities)
    }
    func completedContexts(_ events: [J], sampling: String = "UIUpdateLink.afterUpdateComplete") throws -> [J] {
        let display = sampling == "CADisplayLink.callback"
        try require(display || sampling == "UIUpdateLink.afterUpdateComplete", "Unsupported context sampling: \(sampling)", evidence: true)
        let boundaryKind = display ? "displayTick" : "updateBoundary", contextKind = display ? "displayContext" : "updateContext"
        let timing = display ? ["modelTime", "estimatedPresentationTime"] : ["modelTime", "completionDeadline", "estimatedPresentationTime"]
        let fields = ["headerID", "consumer", "selectedTab", "headerOffset", "contentOffset", "maximumOffset", "mode"]
        var latest: [J] = [], sampled: [[J]] = [], result: [J] = [], boundary: J? = nil, nextUpdate = 0
        for (index, event) in events.enumerated() {
            try require(event["sequence"].number == Double(index) && (index == 0 || event["uptime"].number >= events[index - 1]["uptime"].number), "Missing/reordered events", evidence: true)
            let k = key(event), kind = event["kind"].string
            if ["updateBoundary", "updateContext", "displayTick", "displayContext"].contains(kind) {
                try require([boundaryKind, contextKind].contains(kind), "Mixed or mislabeled context sampling phases", evidence: true)
            }
            if kind == contextKind {
                let source = latest.first { key($0) == k }
                try require(boundary != nil && source != nil && !sampled.contains(k) &&
                            event["updateID"] == boundary?["updateID"] && event["uptime"] == boundary?["uptime"] &&
                            event["sourceSequence"] == source?["sequence"] && fields.allSatisfy { event[$0] == source?[$0] },
                            "Completed context does not match its latest view-consumed source", evidence: true)
                sampled.append(k)
                if event["consumer"].string == "header" {
                    try require(event["headerOffset"].number.isFinite && event["contentOffset"].number.isFinite, "Missing/nonfinite context offsets", evidence: true)
                    result.append(event)
                }
                continue
            }
            if boundary != nil { try require(sampled.count == latest.count && latest.allSatisfy { sampled.contains(key($0)) }, "Not every active view was sampled at the completed update", evidence: true) }
            boundary = nil
            if kind == "viewContext" {
                latest.removeAll { key($0) == k }; latest.append(event)
            } else if kind == "viewDetached" { latest.removeAll { key($0) == k } }
            else if kind == boundaryKind {
                try require(event["updateID"].number == Double(nextUpdate) && event["reason"].string == sampling && timing.allSatisfy { event[$0].number.isFinite }, "Invalid completed-update identity/phase/timing", evidence: true)
                nextUpdate += 1; boundary = event; sampled = []
            }
        }
        if boundary != nil { try require(sampled.count == latest.count && latest.allSatisfy { sampled.contains(key($0)) }, "Incomplete final update", evidence: true) }
        try require(!result.isEmpty, "No completed-update header contexts; raw callbacks cannot substitute", evidence: true)
        return result
    }
    func actualScroll(_ report: J, at checkpoint: Double, readyAt: Double? = nil, destination: String? = nil) throws -> (J, Double) {
        try require(!report["nativeScrollOverflow"].bool, "Truncated native scroll capture", evidence: true)
        let sample = try latestCapture(report, before: checkpoint)
        if let readyAt { try require(sample["uptime"].number >= readyAt, "Actual measurement predates destination synchronization", evidence: true) }
        if let destination {
            let pagers = sample["scrolls"].array.filter { abs($0["frameX"].number) <= 0.5 && abs($0["frameWidth"].number - sample["windowWidth"].number) <= 0.5 && $0["contentWidth"].number > $0["boundsWidth"].number + 0.5 }
            try require(pagers.count == 1 && pagers[0]["offsetX"].exists, "Cannot verify actual horizontal destination", evidence: true)
            guard let index = Self.tabs.firstIndex(of: destination) else { throw RecordedTraceError(kind: .inconclusive, detail: "Unknown destination") }
            try equal(pagers[0]["offsetX"].number, Double(index) * pagers[0]["boundsWidth"].number, "Actual pager did not reach the requested tab")
        }
        let candidates = sample["scrolls"].array.filter { vertical($0, width: sample["windowWidth"].number) }
        try require(candidates.count == 1, "Expected one visible vertical scroll view, found \(candidates.count)", evidence: true)
        let scroll = candidates[0]
        try require(!["tracking", "dragging", "decelerating"].contains { scroll[$0].bool }, "Selection checkpoint still contains active scrolling", evidence: true)
        return (scroll, try normalized(scroll))
    }
    func bottom(_ report: J, gesture: [J], end: Double, previous: J = .null) throws -> J {
        let (scroll, actual) = try actualScroll(report, at: end)
        try require(scroll["insetBottom"].exists, "Missing native bottom inset", evidence: true)
        let maximum = scroll["contentHeight"].number - scroll["boundsHeight"].number + scroll["insetTop"].number + scroll["insetBottom"].number
        try require(maximum > 0, "Bottom fixture must contain scrollable content")
        try equal(actual, maximum, "Bottom not reached")
        let overscroll = report["nativeScrollSnapshots"].array.filter { gesture[0]["touchTimestamp"].number <= $0["uptime"].number && $0["uptime"].number < end }.flatMap { $0["scrolls"].array }.filter { $0["id"] == scroll["id"] }.map { $0["normalizedOffset"].number }
        try require((overscroll.max() ?? -.infinity) > actual + 0.5, "No observed outward overscroll at bottom")
        if previous.exists { try require(scroll["id"] == previous[0] && abs(actual - previous[1].number) <= 0.5, "Bottom stop did not repeat") }
        return .array([scroll["id"], .number(actual)])
    }
    func flick(_ report: J, gesture: [J], checkpoint: Double) throws -> J {
        let start = gesture[0]["touchTimestamp"].number, lift = gesture.last!["touchTimestamp"].number
        try require(lift > start && lift - start <= 0.5, "Flick input was not fast")
        try require(gesture.last!["y"].number - gesture[0]["y"].number < -200, "Flick did not move upward far enough")
        let (scroll, _) = try actualScroll(report, at: start)
        let moving = report["nativeScrollSnapshots"].array.filter { lift <= $0["uptime"].number && $0["uptime"].number < checkpoint }.flatMap { $0["scrolls"].array }.filter { $0["id"] == scroll["id"] && $0["decelerating"].bool && !$0["tracking"].bool }
        try require(!moving.isEmpty, "Flick did not produce observed post-lift deceleration", evidence: true)
        return scroll["id"]
    }
    func decelerating(_ report: J, cutoff: Double) throws -> J {
        let sample = try latestCapture(report, before: cutoff)
        try require(cutoff - sample["uptime"].number <= 0.1, "No recent native sample at the selection action", evidence: true)
        let visible = sample["scrolls"].array.filter { vertical($0, width: sample["windowWidth"].number) }
        try require(visible.count == 1, "Cannot identify the decelerating source page", evidence: true)
        try require(visible[0]["decelerating"].bool && !visible[0]["tracking"].bool, "Tab selection did not occur during deceleration", evidence: true)
        return visible[0]["id"]
    }
    func parked(_ report: J, id: J, departure: Double, cutoff: Double) throws -> Double {
        guard let latest = report["nativeScrollSnapshots"].array.last(where: { departure < $0["uptime"].number && $0["uptime"].number < cutoff }) else { throw RecordedTraceError(kind: .inconclusive, detail: "No native capture while source page was away") }
        let detached = latest["parkedScrolls"].array.filter { $0["id"] == id }
        let matches = latest["scrolls"].array.filter { $0["id"] == id } + detached
        try require(matches.count == 1, "Departed native scroll view is unavailable before return", evidence: true)
        let scroll = matches[0]
        try require(!["tracking", "dragging", "decelerating"].contains { scroll[$0].bool }, "Departed page has not stopped before return", evidence: true)
        let actual = try normalized(scroll)
        try require(!detached.isEmpty || abs(scroll["frameX"].number) > 0.5, "Expected parked source to be offscreen before return", evidence: true)
        return actual
    }
    func shortRange(_ scroll: J, maximum: Double) throws {
        try require(scroll["insetBottom"].exists, "Missing short-content bottom inset", evidence: true)
        let range = scroll["contentHeight"].number - scroll["boundsHeight"].number + scroll["insetTop"].number + scroll["insetBottom"].number
        try require(maximum > 0 && abs(range - maximum) <= 0.5, "Short fixture range must equal collapse range \(maximum), got \(range)")
    }
    func expectedOffset(mode: String, relative: Double, header: Double, maximum: Double) throws -> Double {
        try require(["resetTitle", "preserve", "resetPosition"].contains(mode), "Unsupported relative-position contract")
        return mode == "resetPosition" && header < maximum ? header : relative + header
    }
    func nativeReference(_ report: J, plan: J, width: Double, height: Double) throws {
        try require([26.0, 27.0].contains(report["osMajor"].number), "Native safeAreaBar reference requires iOS 26 or newer", evidence: true)
        try require(!report["rowFrameOverflow"].bool, "Truncated native header geometry", evidence: true)
        let input = gestures(report)
        try require(input.count == 2 && plan["steps"].array.count == 2, "Missing native-reference gestures")
        var positions: [Double] = [], bottoms: [Double] = []
        for checkpoint in [input[0][0]["touchTimestamp"].number, input[1][0]["touchTimestamp"].number, report["savedAt"].number] {
            let (scroll, offset) = try actualScroll(report, at: checkpoint)
            guard let frame = report["rowFrames"].array.last(where: { $0["uptime"].number < checkpoint && $0["tab"].string == "native-header" && $0["row"].number == -1 }), frame["present"].bool else { throw RecordedTraceError(kind: .inconclusive, detail: "Missing observed native header geometry") }
            try equal(frame["height"].number, 196, "Unexpected native header height")
            try equal(frame["width"].number, width, "Unexpected native header width")
            let bottom = frame["minY"].number + frame["height"].number
            try equal(bottom, scroll["frameY"].number + scroll["insetTop"].number, "Native safe area does not end at header bottom")
            positions.append(offset); bottoms.append(bottom)
        }
        try require(abs(positions[0]) <= 0.5 && abs(positions[2]) <= 0.5, "Native reference did not start/return to rest")
        try require(positions[1] > 200, "Native reference never scrolled sufficiently")
        try require(bottoms.max()! - bottoms.min()! <= 0.5, "Native fixed header moved")
        for (gesture, direction) in zip(input, [-1.0, 1.0]) {
            try require(gesture.first?["phase"].string == "began" && gesture.last?["phase"].string == "ended", "Incomplete native gesture")
            try require(gesture.allSatisfy { $0["windowWidth"].number == width && $0["windowHeight"].number == height }, "Unsupported native viewport")
            try require(direction * (gesture.last!["y"].number - gesture[0]["y"].number) > 200, "Wrong native drag direction/distance")
        }
    }
    func external(_ report: J, contexts: [J], step: J, start: Double, end: Double) throws {
        let owner = step["commandTab"].string, row = step["commandRow"]
        try require(report["externalRequests"].array.contains { start <= $0["uptime"].number && $0["uptime"].number < end && $0["tab"].string == owner && $0["row"] == row }, "Toolbar tap did not deliver the requested external item command", evidence: true)
        guard let context = contexts.last(where: { $0["uptime"].number < end }) else { throw RecordedTraceError(kind: .inconclusive, detail: "No completed context after external request") }
        try require(name(context["selectedTab"]).lowercased() == owner, "External request changed selected tab")
        let (scroll, actual) = try actualScroll(report, at: end, destination: owner)
        try equal(actual, context["contentOffset"].number, "External request context differs from actual scroll position")
        try require(!report["rowFrameOverflow"].bool, "Truncated row geometry capture", evidence: true)
        guard let frame = report["rowFrames"].array.last(where: { $0["uptime"].number < end && $0["tab"].string == owner && $0["row"] == row }), frame["present"].bool else { throw RecordedTraceError(kind: .inconclusive, detail: "Requested row has no current geometry observation") }
        try require(["minX", "minY", "width"].allSatisfy { frame[$0].number.isFinite }, "Invalid row geometry", evidence: true)
        try require(abs(frame["minX"].number) <= 0.5 && abs(frame["width"].number - scroll["boundsWidth"].number) <= 0.5, "Requested row is on an offscreen page")
        try equal(frame["minY"].number, scroll["frameY"].number(or: 0) + scroll["insetTop"].number, "Requested row did not align at content top")
    }

    @discardableResult
    func check(_ report: J, label: String? = nil, requireActual: Bool = false, requireLifetimes: Bool = false) throws -> Int {
        if let label { try require(report["captureLabel"].string == label, "Trace belongs to a different test") }
        let declared = plans[report["captureLabel"].string]
        if declared.exists && report["replayPlan"].exists {
            try require(report["replayPlan"] == declared, "Captured plan differs from checked-in test definition")
        }
        let plan = report["replayPlan"].exists ? report["replayPlan"] : declared
        let viewport = report["fixtureViewport"], fixture = plan["fixture"]
        var width = 402.0, height = 874.0
        let sampling = report["contextSampling"].exists ? report["contextSampling"].string : "UIUpdateLink.afterUpdateComplete"
        if viewport.exists {
            let major = viewport["osMajor"].number
            try require([17.0, 18.0, 26.0, 27.0].contains(major) && viewport["osMajor"] == report["osMajor"], "Unsupported or mismatched runtime/viewport profile", evidence: true)
            let expectedSampling = major < 26 ? "CADisplayLink.callback" : "UIUpdateLink.afterUpdateComplete"
            try require(report["contextSampling"].string == expectedSampling, "Sampling phase does not match this OS profile", evidence: true)
            width = major == 17 ? 393 : 402; height = major == 17 ? 852 : 874
            let tabTop = major == 17 ? 105.66666666666667 : major == 18 ? 108.33333333333333 : 124
            try require(viewport["width"].number == width && viewport["height"].number == height && abs(viewport["collapsedTabTop"].number - tabTop) <= 0.01, "Viewport profile differs from the independently calibrated fixture", evidence: true)
        }
        try require(report["inputOverflow"] == .bool(false) && report["context"]["overflow"] == .bool(false), "Truncated capture")
        try require(report["context"]["enabled"] == .bool(true) && report["context"]["schemaVersion"].number == 3, "Context recorder disabled or incompatible schema", evidence: true)
        try require(report["activeTouchCount"].number == 0, "Unfinished gesture")
        if fixture["nativeReference"].bool { try nativeReference(report, plan: plan, width: width, height: height); return 0 }
        let events = report["context"]["events"].array
        let contexts = try completedContexts(events, sampling: sampling), input = gestures(report)
        if plan.exists { try require(input.count == plan["steps"].array.count, "Missing or extra input gestures") }
        let extended = fixture.exists
        try require(!input.isEmpty, "No input gestures")
        if requireActual && extended {
            try initialPager(report, tab: fixture["initialTab"].string, firstInput: input[0][0]["touchTimestamp"].number)
            if fixture["shortContent"].bool {
                let (scroll, _) = try actualScroll(report, at: input[0][0]["touchTimestamp"].number)
                try shortRange(scroll, maximum: fixture["titleHeight"].number - fixture["minimumTitleHeight"].number)
            }
        }
        // Scope saved reading positions to the header identity and tab.
        var relative: [String: Double] = [:], departures: [String: (J, Double, Double)] = [:]
        var bottomCheckpoint: J = .null, selections = 0
        func pageKey(_ header: J, _ tab: String) -> String { header.string + "/" + tab }
        func endOf(_ index: Int) -> Double { index + 1 < input.count ? input[index + 1][0]["touchTimestamp"].number : report["savedAt"].number }
        for (index, gesture) in input.enumerated() {
            try require(gesture[0]["phase"].string == "began" && gesture.last!["phase"].string == "ended", "Incomplete gesture")
            try require(gesture.allSatisfy { $0["windowWidth"].number == width && $0["windowHeight"].number == height }, "Unsupported fixture viewport")
            let step = plan["steps"][index], move = movement(gesture)
            if extended {
                try require(name(contexts[0]["selectedTab"]) == fixture["initialTab"].string, "Wrong initial tab; cold-route coverage is invalid")
                let during = contexts.filter { $0["uptime"].number >= input[0][0]["touchTimestamp"].number }
                try require(!during.isEmpty && during.allSatisfy { $0["mode"] == fixture["mode"] }, "Requested sync mode was not applied")
                if fixture["minimumTitleHeight"].exists {
                    let maximum = fixture["titleHeight"].number - fixture["minimumTitleHeight"].number
                    try require(maximum >= 0, "Invalid requested header dimensions")
                    try require(during.allSatisfy { abs($0["maximumOffset"].number - maximum) <= 0.5 }, "Requested header dimensions were not applied")
                }
            }
            if step.exists {
                let kind = step["kind"].string
                if kind == "flickUp" {
                    _ = try flick(report, gesture: gesture, checkpoint: endOf(index))
                    if !step["autoSwitch"].bool { continue }
                }
                if ["up", "down"].contains(kind) {
                    try require(move > 20, "Expected vertical drag was not delivered")
                    let dy = gesture.last!["y"].number - gesture[0]["y"].number
                    try require(kind == "up" ? dy < -20 : dy > 20, "Wrong vertical drag direction")
                    if step["bottomCheckpoint"].exists {
                        try require(step["bottomCheckpoint"].string != "confirm" || bottomCheckpoint.exists, "Missing first bottom checkpoint", evidence: true)
                        bottomCheckpoint = try bottom(report, gesture: gesture, end: endOf(index), previous: bottomCheckpoint)
                    }
                    continue
                }
                if step["autoSwitch"].bool {
                    try require(events.contains { gesture.last!["touchTimestamp"].number <= $0["uptime"].number && $0["uptime"].number < endOf(index) && $0["kind"].string == "phase" && $0["reason"].string == "decelerating" && $0["tab"].string.lowercased() == fixture["initialTab"].string }, "No SwiftUI deceleration callback for automatic selection", evidence: true)
                } else if kind == "tap" {
                    try require(move <= 1, "Expected tap was delivered as a drag")
                    if step["commandRow"].exists {
                        try external(report, contexts: contexts, step: step, start: gesture[0]["touchTimestamp"].number, end: endOf(index)); continue
                    }
                } else {
                    let dx = gesture.last!["x"].number - gesture[0]["x"].number
                    try require(kind == "right" ? dx > 200 : dx < -200, "Wrong swipe direction/distance")
                }
            } else if move > 1 { continue }
            let start = gesture[0]["touchTimestamp"].number
            var end = endOf(index)
            if index + 1 < input.count && movement(input[index + 1]) <= 1 {
                // The current page owns content until the NEXT tap action, not
                // merely until the next touch-down. No arbitrary grace period.
                if let change = events.first(where: { end <= $0["uptime"].number && $0["uptime"].number < endOf(index + 1) && $0["kind"].string == "selectionRequest" && $0["tab"] != $0["selectedTab"] }) { end = change["uptime"].number }
            }
            let changes = events.filter { start <= $0["uptime"].number && $0["uptime"].number < end && $0["kind"].string == "selectionRequest" && $0["tab"] != $0["selectedTab"] }
            try require(!changes.isEmpty, "Selection input \(index) did not produce a tab transition")
            let change = changes[0], source = name(change["selectedTab"]), headerID = change["headerID"]
            let x = gesture[0]["x"].number / (gesture[0]["windowWidth"].number / 3)
            try require(x.isFinite && x >= 0, "Invalid tap coordinate", evidence: true)
            let destination = step.exists ? step["tab"].string : Self.tabs[min(2, Int(x))]
            let actionSelection = move <= 1 || step["autoSwitch"].bool
            let cutoff = actionSelection ? change["uptime"].number : start
            guard let before = contexts.last(where: { $0["uptime"].number < cutoff && $0["headerID"] == headerID }) else { throw RecordedTraceError(kind: .inconclusive, detail: "No completed context before selection input") }
            try require(name(before["selectedTab"]) == source, "Selection did not start from the expected tab")
            let header = before["headerOffset"].number
            if step.exists {
                let range = step["headerRange"].exists ? step["headerRange"] : plan["headerRange"]
                try require(range[0].number - 0.5 <= header && header <= range[1].number + 0.5, "Wrong header setup: expected \(range), got \(header)")
            }
            relative[pageKey(headerID, source)] = before["contentOffset"].number - header
            if step["requireDeceleratingSource"].bool { departures[pageKey(headerID, source)] = (try decelerating(report, cutoff: change["uptime"].number), change["uptime"].number, header) }
            if step["restoreParkedSource"].bool {
                guard let (id, at, oldHeader) = departures[pageKey(headerID, destination)] else { throw RecordedTraceError(kind: .inconclusive, detail: "Return has no observed decelerating departure") }
                relative[pageKey(headerID, destination)] = try parked(report, id: id, departure: at, cutoff: start) - oldHeader
            }
            let expected = try expectedOffset(mode: before["mode"].string, relative: relative[pageKey(headerID, destination)] ?? 0, header: header, maximum: before["maximumOffset"].number)
            let windowStart = actionSelection ? change["uptime"].number : start
            let window = contexts.filter { windowStart <= $0["uptime"].number && $0["uptime"].number < end }
            try require(!window.isEmpty, "No completed-update contexts during selection", evidence: true)
            try require(window.allSatisfy { $0["headerID"] == headerID }, "Header identity changed during selection")
            try require(name(window.last!["selectedTab"]) == destination, "Input \(index) did not select \(destination)")
            let restored = events.first { change["uptime"].number <= $0["uptime"].number && $0["uptime"].number < end && $0["kind"].string == "syncTarget" && $0["headerID"] == headerID && name($0["tab"]) == destination && $0["registration"] == .bool(false) && $0["appeared"] == .bool(true) }
            let restorationContext = restored.flatMap { restore in events.first { $0["sequence"].number > restore["sequence"].number && $0["uptime"].number < end && $0["kind"].string == "context" && $0["headerID"] == headerID && name($0["selectedTab"]) == destination } }
            var contentSamples = 0
            for context in window {
                try equal(context["headerOffset"].number, header, "\(source)->\(destination) header context at event \(context["sequence"].number)")
                // A copied cached context is not fresh merely because its sample
                // timestamp is later. Unchanged inputs are compared to the
                // recorded restoration input, NEVER to the expected test value.
                let unchanged = restorationContext.map { r in ["headerID", "selectedTab", "headerOffset", "contentOffset", "maximumOffset", "mode"].allSatisfy { context[$0] == r[$0] } } ?? false
                let fresh = unchanged || restored.map { context["sourceSequence"].number > $0["sequence"].number } == true
                if let restored, fresh && context["uptime"].number >= restored["uptime"].number && name(context["selectedTab"]) == destination {
                    contentSamples += 1
                    try equal(context["contentOffset"].number, expected, "\(source)->\(destination) content context at event \(context["sequence"].number) (not a visual-reset claim)")
                }
            }
            try require(contentSamples > 0, "No completed \(destination) context after its synchronization", evidence: true)
            if requireActual {
                let (_, actual) = try actualScroll(report, at: end, readyAt: restored?["uptime"].number, destination: destination)
                try equal(actual, expected, "\(source)->\(destination) actual scroll position at checkpoint")
            }
            selections += 1
        }
        try require(selections > 0, "No selections checked")
        let recordedCounts = ["recorded-reproduction": 1, "recorded-adjacent-return": 2, "recorded-nonadjacent-return": 3, "recorded-nonadjacent-exact-return": 3]
        let count = plan.exists ? plan["steps"].array.filter { $0["tab"].exists }.count : recordedCounts[report["captureLabel"].string]
        if let count { try require(selections == count, "Expected \(count) transitions, checked \(selections)") }
        if requireLifetimes { _ = try lifetimes(events) }
        return selections
    }
}
