import XCTest

final class RegressionCatalogTests: XCTestCase {
    private let recorded = ["testRecordedManualDragAndOverviewTap", "testRecordedAdjacentExpandedReturn", "testNotesExpansionWithoutOverscroll"]
    private func definitions() throws -> [String: TraceJSON] { try RegressionResources.json("query-free-cases").object }
    private func methods(_ plan: String) throws -> Set<String> {
        let value = try JSONDecoder().decode(TraceJSON.self, from: RegressionResources.data(plan, extension: "xctestplan"))
        let target = try XCTUnwrap(value["testTargets"].array.first { $0["target"]["name"].string == "MaterialTabsRegressionUITests" })
        return Set(target["selectedTests"].array.map(\.string).filter { $0.hasPrefix("ManualTouchReplayUITests/") }.map { String($0.dropFirst("ManualTouchReplayUITests/".count)) })
    }
    func testCoreHasThirteenScenarios() throws { XCTAssertEqual(try methods("Core").count, 13) }
    func testExtendedHas104Scenarios() throws { XCTAssertEqual(try methods("Extended").count, 104) }
    func testExtendedIncludesCore() throws { XCTAssertTrue(try methods("Core").isSubset(of: methods("Extended"))) }
    func testExtendedMatchesAllNonDeferredDefinitions() throws {
        let expected = try definitions().values.filter { !["external-position", "flick-diagnostic"].contains($0["family"].string) }.map { $0["method"].string }
        XCTAssertEqual(try methods("Extended"), Set(expected + recorded + ["testNormalDemoLaunch"]))
    }
    func testCoreMatchesFocusedDefinitions() throws {
        let expected = try definitions().values.filter { !$0["suite"].exists || $0["suite"].string == "focused" }.map { $0["method"].string }
        XCTAssertEqual(try methods("Core"), Set(expected + recorded))
    }
    func testEveryUIEntryPointExists() throws {
        let type = try XCTUnwrap(NSClassFromString("ManualTouchReplayUITests") as? NSObject.Type)
        for method in try methods("Extended") { XCTAssertTrue(type.instancesRespond(to: NSSelectorFromString(method)), method) }
    }
    func testMethodNamesAreUnique() throws {
        let names = try definitions().values.map { $0["method"].string }
        XCTAssertEqual(Set(names).count, names.count)
        XCTAssertFalse(names.contains(""))
    }
    func testValidatorCasesAreComplete() throws {
        let vectors = try RegressionResources.json("trace-validator-cases").array
        XCTAssertEqual(vectors.count, 125)
        XCTAssertEqual(Set(vectors.map { $0["test"].string }).count, 91)
        XCTAssertEqual(Set(vectors.map { $0["outcome"].string }), ["pass", "failure", "inconclusive"])
    }
    func testHeaderConfigurationsHaveSixCases() throws {
        XCTAssertEqual(try definitions().values.filter { $0["family"].string == "header-configuration" }.count, 6)
    }
    func testOnlyNativeReferenceNeedsIOS26() throws {
        let native = try definitions().values.filter { $0["fixture"]["nativeReference"].bool }
        XCTAssertEqual(native.count, 1)
        XCTAssertEqual(native.first?["method"].string, "testVisualNativeReference")
        XCTAssertEqual(try methods("Extended").subtracting(["testVisualNativeReference"]).count, 103)
    }
    func testPlansKeepUIExecutionSerialAndBothFastSuites() throws {
        for name in ["Core", "Extended"] {
            let plan = try JSONDecoder().decode(TraceJSON.self, from: RegressionResources.data(name, extension: "xctestplan"))
            let targets = plan["testTargets"].array
            XCTAssertEqual(targets.count, 2)
            XCTAssertTrue(targets.allSatisfy { $0["parallelizable"] == .bool(false) })
            let ui = try XCTUnwrap(targets.first { $0["target"]["name"].string == "MaterialTabsRegressionUITests" })
            let selected = Set(ui["selectedTests"].array.map(\.string))
            XCTAssertTrue(selected.contains("RecordedTraceCheckerTests"))
            XCTAssertTrue(selected.contains("RegressionCatalogTests"))
        }
    }
}
