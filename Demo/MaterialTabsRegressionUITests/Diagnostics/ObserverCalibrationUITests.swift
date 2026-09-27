import XCTest

/// Runtime controls for the observation pipeline, separate from the release plans.
@MainActor
final class ObserverCalibrationUITests: XCTestCase {
    private var app: XCUIApplication!
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { app?.terminate() }

    private func launch(native: Bool, recorderProbe: Bool = false, viewProbe: Bool = false) throws {
        app = XCUIApplication(bundleIdentifier: "com.swiftkickmobile.Demo")
        app.launchEnvironment = [
            "SUIMT_CONTEXT_TRACE": "1", "SUIMT_UI_REGRESSION": "1",
            "SUIMT_NATIVE_EDGE": native ? "1" : "0", "SUIMT_INITIAL_TAB": "1",
            "SUIMT_SYNC_MODE": "resetTitle",
            "SUIMT_TRACE_SELF_TEST": recorderProbe ? "1" : "0",
            "SUIMT_VIEW_CONTEXT_PROBE": viewProbe ? "1" : "0"
        ]
        app.launch()
        XCTAssertTrue(app.buttons["context-trace-export"].waitForExistence(timeout: 10))
    }
    private func pause() { RunLoop.current.run(until: Date().addingTimeInterval(0.75)) }
    private func report(_ name: String) throws -> ContextTraceReport {
        let export = app.buttons["context-trace-export"]
        export.tap()
        let text = try XCTUnwrap(export.value as? String)
        let attachment = XCTAttachment(string: text)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let result = try JSONDecoder().decode(ContextTraceReport.self, from: Data(text.utf8))
        XCTAssertTrue(ObserverTraceIntegrity.boundaryIntegrity(result).isEmpty)
        return result
    }

    func testRecorderCapturesRecoveringSpikeInOneSynchronousCall() throws {
        try launch(native: false, recorderProbe: true)
        app.buttons["context-trace-probe"].tap()
        let snapshot = try report("recorder-source-self-test")
        let id = try XCTUnwrap(snapshot.events.last { $0.kind == "probeBegin" }?.headerID)
        let offsets = snapshot.events.filter { $0.headerID == id && $0.kind == "context" }.compactMap(\.headerOffset)
        let changes = offsets.reduce(into: [Double]()) { result, value in
            if result.last != value { result.append(value) }
        }
        XCTAssertEqual(changes, [0, 150, 0, 150], "Recorder must retain the spike despite a correct final value")
    }


    func testViewObserverFiltersMutationsBetweenUpdates() throws {
        try launch(native: false, viewProbe: true)
        let before = try report("view-probe-before")
        let initial = try XCTUnwrap(before.events.last { $0.kind == "viewContext" && $0.consumer == "probe" })
        let id = try XCTUnwrap(initial.headerID)
        XCTAssertEqual(initial.headerOffset, 150)
        let start = ProcessInfo.processInfo.systemUptime
        app.buttons["context-probe-coalesced"].tap()
        pause()
        let after = try report("view-probe-coalesced")
        let raw = after.events.filter { $0.headerID == id && $0.kind == "context" && $0.uptime >= start }
        let views = after.events.filter { $0.headerID == id && $0.kind == "viewContext" && $0.uptime >= start }
        XCTAssertTrue(raw.contains { $0.headerOffset == 0 && $0.contentOffset == 0 }, "The raw spike must actually have happened")
        XCTAssertFalse(views.contains { $0.headerOffset == 0 || $0.contentOffset == 0 }, "Overwritten mutations must not be invented as view samples")
        XCTAssertEqual(after.events.last { $0.headerID == id && $0.kind == "viewContext" }?.headerOffset, 150)
        print("VIEW_FILTER_CONTROL rawEvents=\(raw.count) viewEvents=\(views.count)")
    }


    func testViewObserverRetainsIncorrectValueConsumedByAViewUpdate() throws {
        try launch(native: false, viewProbe: true)
        let before = try report("view-probe-before-exposed-change")
        let id = try XCTUnwrap(before.events.last { $0.kind == "viewContext" && $0.consumer == "probe" }?.headerID)
        app.buttons["context-probe-zero"].tap()
        pause()
        let zero = try report("view-probe-exposed-zero")
        XCTAssertEqual(zero.events.last { $0.kind == "viewContext" && $0.headerID == id }?.headerOffset, 0)
        app.buttons["context-probe-restore"].tap()
        pause()
        let after = try report("view-probe-restored")
        let values = after.events.filter { $0.kind == "viewContext" && $0.headerID == id }.compactMap(\.headerOffset)
        let changes = values.reduce(into: [Double]()) { result, value in
            if result.last != value { result.append(value) }
        }
        XCTAssertEqual(changes, [150, 0, 150], "A bad consumed value must survive the later correction in the trace")
        print("VIEW_EXPOSED_CONTROL samples=\(changes)")
    }


    func testUpdateBoundaryFiltersSynchronousSpike() throws {
        try launch(native: false, viewProbe: true)
        let before = try report("boundary-probe-before")
        let initial = try XCTUnwrap(before.events.last { $0.kind == "updateContext" && $0.consumer == "probe" })
        let id = try XCTUnwrap(initial.headerID)
        XCTAssertEqual(initial.headerOffset, 150)
        let start = ProcessInfo.processInfo.systemUptime
        app.buttons["context-probe-coalesced"].tap()
        pause()
        let after = try report("boundary-probe-coalesced")
        let raw = after.events.filter { $0.headerID == id && $0.kind == "context" && $0.uptime >= start }
        let samples = after.events.filter { $0.headerID == id && $0.kind == "updateContext" && $0.uptime >= start }
        XCTAssertTrue(raw.contains { $0.headerOffset == 0 && $0.contentOffset == 0 })
        XCTAssertFalse(samples.isEmpty, "Missing boundary callbacks cannot count as filtering")
        XCTAssertTrue(samples.allSatisfy { $0.headerOffset == 150 && $0.contentOffset == 150 })
        print("BOUNDARY_FILTER_CONTROL rawEvents=\(raw.count) boundarySamples=\(samples.count)")
    }


    func testUpdateBoundaryRetainsSpikeAcrossUpdates() throws {
        try launch(native: false, viewProbe: true)
        let before = try report("boundary-probe-before-exposed-change")
        let id = try XCTUnwrap(before.events.last { $0.kind == "updateContext" && $0.consumer == "probe" }?.headerID)
        app.buttons["context-probe-zero"].tap()
        pause()
        let zero = try report("boundary-probe-exposed-zero")
        XCTAssertEqual(zero.events.last { $0.kind == "updateContext" && $0.headerID == id }?.headerOffset, 0)
        app.buttons["context-probe-restore"].tap()
        pause()
        let after = try report("boundary-probe-restored")
        let values = after.events.filter { $0.kind == "updateContext" && $0.headerID == id }.compactMap(\.headerOffset)
        let changes = values.reduce(into: [Double]()) { result, value in
            if result.last != value { result.append(value) }
        }
        XCTAssertEqual(changes, [150, 0, 150], "A spike spanning update boundaries must remain after correction")
        print("BOUNDARY_EXPOSED_CONTROL samples=\(changes)")
    }


}
