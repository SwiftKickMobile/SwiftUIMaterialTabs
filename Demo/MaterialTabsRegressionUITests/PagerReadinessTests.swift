import XCTest

final class SafeAreaPaddingUITests: XCTestCase {
    func testTabSwitchPreservesPositionWithBottomSafeAreaPadding() throws {
        let app = XCUIApplication(bundleIdentifier: "com.swiftkickmobile.TestHost")
        app.launchEnvironment["SUIMT_PADDING_REGRESSION"] = "1"
        app.launch()
        let appointment = app.buttons["Appointment"]
        let offers = app.buttons["Offers"]
        let firstRow = app.staticTexts["Appointment row 0"]
        XCTAssertTrue(appointment.waitForExistence(timeout: 10))
        XCTAssertTrue(firstRow.waitForExistence(timeout: 10))
        let initialTop = appointment.frame.minY
        let initialRowTop = firstRow.frame.minY
        for cycle in 1...3 {
            offers.tap()
            appointment.tap()
            XCTAssertEqual(appointment.frame.minY, initialTop, accuracy: 2,
                           "Header moved after round trip \(cycle)")
            XCTAssertEqual(firstRow.frame.minY, initialRowTop, accuracy: 2,
                           "Appointment content moved after round trip \(cycle)")
        }
    }
}

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
