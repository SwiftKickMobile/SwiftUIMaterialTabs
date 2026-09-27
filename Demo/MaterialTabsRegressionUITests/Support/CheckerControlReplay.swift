import Foundation

/// Frozen inputs from the pre-migration checker controls. This adapter is also
/// used for the one-time parity audit; the Xcode plans need only Swift and JSON.
enum CheckerControlReplay {
    static func evaluate(_ vector: TraceJSON, checker: RecordedTraceChecker) throws -> TraceJSON {
        let a = vector["arguments"]
        switch vector["function"].string {
        case "check":
            _ = try checker.check(a["report"], label: a["label"].exists ? a["label"].string : nil, requireActual: a["require_actual"].bool)
            return .null
        case "check_initial_pager": try checker.initialPager(a["report"], tab: a["initial_tab"].string, firstInput: a["first_input"].number); return .null
        case "check_content_lifetimes": return try checker.lifetimes(a["events"].array)
        case "completed_contexts": return .array(try checker.completedContexts(a["events"].array, sampling: a["sampling"].string))
        case "actual_scroll_at", "actual_offset_at":
            let (scroll, offset) = try checker.actualScroll(a["report"], at: a["checkpoint"].number,
                readyAt: a["ready_at"].exists ? a["ready_at"].number : nil,
                destination: a["destination"].exists ? a["destination"].string : nil)
            return vector["function"].string == "actual_offset_at" ? .number(offset) : .array([scroll, .number(offset)])
        case "check_bottom_checkpoint": return try checker.bottom(a["report"], gesture: a["gesture"].array, end: a["end"].number, previous: a["previous"])
        case "check_flick_motion": return try checker.flick(a["report"], gesture: a["gesture"].array, checkpoint: a["checkpoint"].number)
        case "decelerating_source_before": return try checker.decelerating(a["report"], cutoff: a["cutoff"].number)
        case "parked_source_before": return .number(try checker.parked(a["report"], id: a["scroll_id"], departure: a["departure"].number, cutoff: a["cutoff"].number))
        case "check_external_command": try checker.external(a["report"], contexts: a["contexts"].array, step: a["step"], start: a["start"].number, end: a["end"].number); return .null
        case "check_short_content_range": try checker.shortRange(a["scroll"], maximum: a["maximum_collapse"].number); return .null
        case "expected_selection_offset": return .number(try checker.expectedOffset(mode: a["mode"].string, relative: a["relative"].number, header: a["header"].number, maximum: a["maximum"].number))
        case "check_native_reference": try checker.nativeReference(a["report"], plan: a["plan"], width: a["width"].number, height: a["height"].number); return .null
        default: throw RecordedTraceError(kind: .inconclusive, detail: "Unmapped migration control: \(vector["function"].string)")
        }
    }
    static func mismatch(_ vector: TraceJSON, checker: RecordedTraceChecker) -> String? {
        do {
            let actual = try evaluate(vector, checker: checker)
            if vector["outcome"].string != "pass" { return "Expected \(vector["outcome"].string), but Swift accepted input" }
            if actual != vector["value"] { return "Accepted input but helper result differs from frozen result" }
        } catch let error as RecordedTraceError {
            if error.kind.rawValue != vector["outcome"].string { return "Expected \(vector["outcome"].string), got \(error)" }
        } catch { return "Unexpected validation error: \(error)" }
        return nil
    }
}
