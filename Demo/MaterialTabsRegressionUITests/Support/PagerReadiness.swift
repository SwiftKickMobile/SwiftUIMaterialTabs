import Foundation

/// Sequencing predicate, not a correctness oracle. A stopped pager at the WRONG
/// position is ready to validate too. Never wait for the requested tab/offset.
enum PagerReadiness {
    static func isIdle(_ report: TraceJSON, requestedAt: Double) throws -> Bool {
        func evidence(_ condition: Bool, _ message: String) throws {
            if !condition { throw RecordedTraceError(kind: .inconclusive, detail: message) }
        }
        try evidence(!report["nativeScrollOverflow"].bool, "Truncated paging-readiness capture")
        guard let sample = report["nativeScrollSnapshots"].array.last else {
            throw RecordedTraceError(kind: .inconclusive, detail: "Missing paging-readiness capture")
        }
        try evidence(sample["phase"].string == "export" && sample["uptime"].number >= requestedAt,
                     "Paging-readiness capture predates its request")
        let width = sample["windowWidth"].number
        let pagers = sample["scrolls"].array.filter {
            abs($0["frameX"].number) <= 0.5 && abs($0["boundsWidth"].number - width) <= 0.5 &&
            abs($0["contentWidth"].number - 3 * width) <= 0.5
        }
        try evidence(width > 0 && pagers.count == 1, "No unique horizontal pager for readiness")
        let pager = pagers[0], flags = ["tracking", "dragging", "decelerating"]
        try evidence(pager["offsetX"].number.isFinite && flags.allSatisfy {
            pager[$0] == .bool(true) || pager[$0] == .bool(false)
        }, "Incomplete native paging-readiness values")
        return !flags.contains { pager[$0].bool }
    }
}
