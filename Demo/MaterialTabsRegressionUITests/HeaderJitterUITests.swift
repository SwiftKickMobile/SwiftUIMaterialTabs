import XCTest

final class HeaderJitterUITests: XCTestCase {
    func testPartiallyCollapsedHeaderRemainsStillWhenSwitching() throws {
        let app = XCUIApplication(bundleIdentifier: "com.swiftkickmobile.TestHost")
        app.launchEnvironment["SUIMT_JITTER_REGRESSION"] = "1"
        app.launch()
        let appointment = app.buttons["Appointment"]
        let offers = app.buttons["Offers"]
        XCTAssertTrue(offers.waitForExistence(timeout: 10))
        let expandedTop = appointment.frame.minY
        offers.tap()
        let source = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
        let destination = source.withOffset(CGVector(dx: 0, dy: -25))
        source.press(forDuration: 0.2, thenDragTo: destination)
        let partialTop = appointment.frame.minY
        guard partialTop < expandedTop - 15, partialTop > expandedTop - 165 else {
            XCTFail("Expected a partially collapsed header; expanded=\(expandedTop), current=\(partialTop)")
            return
        }
        appointment.tap()
        let result = app.staticTexts["motionResult"]
        let completed = NSPredicate(format: "label MATCHES 'Motion [0-9.]+ samples [0-9]+'")
        expectation(for: completed, evaluatedWith: result)
        waitForExpectations(timeout: 5)
        let fields = result.label.split(separator: " ")
        let maximum = try XCTUnwrap(Double(fields[1]))
        let samples = try XCTUnwrap(Int(fields[3]))
        XCTAssertGreaterThan(samples, 3, "Presentation-frame sampling must actually run")
        XCTAssertLessThanOrEqual(maximum, 3, "Partially collapsed header moved during the switch")
    }
}
