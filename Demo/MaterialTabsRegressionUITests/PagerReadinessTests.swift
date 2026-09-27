import XCTest

final class PagerReadinessTests: XCTestCase {
    private func report(offset: Double = 402, flag: String? = nil, time: Double = 2, copies: Int = 1) -> TraceJSON {
        var pager: [String: TraceJSON] = ["frameX": .number(0), "boundsWidth": .number(402),
            "contentWidth": .number(1206), "offsetX": .number(offset), "tracking": .bool(false),
            "dragging": .bool(false), "decelerating": .bool(false)]
        if let flag { pager[flag] = .bool(true) }
        return .object(["nativeScrollOverflow": .bool(false), "nativeScrollSnapshots": .array([
            .object(["phase": .string("export"), "uptime": .number(time), "windowWidth": .number(402),
                     "scrolls": .array(Array(repeating: .object(pager), count: copies))])])])
    }
    func testIdleDoesNotMeanCorrectTabOrOffset() throws {
        for offset in [0.0, 402, 804, 555] {
            XCTAssertTrue(try PagerReadiness.isIdle(report(offset: offset), requestedAt: 1))
        }
    }
    func testEveryNativeMotionFlagDefersNextGesture() throws {
        for flag in ["tracking", "dragging", "decelerating"] {
            XCTAssertFalse(try PagerReadiness.isIdle(report(flag: flag), requestedAt: 1))
        }
    }
    func testMissingStaleOrAmbiguousEvidenceCannotBeReady() throws {
        for value in [TraceJSON.null, report(time: 0), report(copies: 0), report(copies: 2), report(offset: .nan)] {
            XCTAssertThrowsError(try PagerReadiness.isIdle(value, requestedAt: 1))
        }
    }
}
