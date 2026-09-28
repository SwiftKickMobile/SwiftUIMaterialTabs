import Foundation
import XCTest

enum RegressionResources {
    static func data(_ name: String, extension ext: String = "json") throws -> Data {
        let bundle = Bundle(for: RecordedTraceValidation.self)
        guard let url = bundle.url(forResource: name, withExtension: ext) ?? bundle.url(forResource: name, withExtension: ext, subdirectory: "Fixtures") else {
            throw RecordedTraceError(kind: .inconclusive, detail: "Missing bundled resource \(name).\(ext)")
        }
        return try Data(contentsOf: url)
    }
    static func json(_ name: String) throws -> TraceJSON {
        let source = try JSONDecoder().decode(TraceJSON.self, from: data(name))
        guard source["shared"].exists else { return source }
        // Expand shared fixtures before replay; the checker receives complete values.
        func expand(_ value: TraceJSON, ancestors: Set<String> = []) throws -> TraceJSON {
            if case .string(let key) = value["$ref"] {
                guard !ancestors.contains(key), let shared = source["shared"].object[key] else {
                    throw RecordedTraceError(kind: .inconclusive, detail: "Missing or cyclic fixture reference: \(key)")
                }
                return try expand(shared, ancestors: ancestors.union([key]))
            }
            switch value {
            case .array(let values): return .array(try values.map { try expand($0, ancestors: ancestors) })
            case .object(let values): return .object(try values.mapValues { try expand($0, ancestors: ancestors) })
            default: return value
            }
        }
        return try expand(source["cases"])
    }
}

/// Objective-C replay driver calls this only after all recorded input is over.
@objc(SUIMTRecordedTraceValidation)
public final class RecordedTraceValidation: NSObject {
    @objc(validateExternalCommandsInData:label:)
    public static func validateExternalCommands(data: Data, label: String) -> String? {
        do {
            let report = try JSONDecoder().decode(TraceJSON.self, from: data)
            let checker = RecordedTraceChecker(plans: try RegressionResources.json("query-free-cases"))
            let plan = report["replayPlan"]
            let gestures = checker.gestures(report)
            let contexts = try checker.completedContexts(report["context"]["events"].array,
                                                         sampling: report["contextSampling"].string)
            var commands = 0
            for (index, step) in plan["steps"].array.enumerated() where step["commandRow"].exists {
                try checker.require(gestures.indices.contains(index), "Missing external-command gesture", evidence: true)
                let end = index + 1 < gestures.count ? gestures[index + 1][0]["touchTimestamp"].number : report["savedAt"].number
                try checker.external(report, contexts: contexts, step: step,
                                     start: gestures[index][0]["touchTimestamp"].number, end: end)
                commands += 1
            }
            try checker.require(commands == 2, "Issue #27 must verify both Row 10 and Top")
            return nil
        } catch { return "\(label): \(error)" }
    }

    @objc public static func scenarioData() throws -> Data {
        try JSONEncoder().encode(RegressionResources.json("query-free-cases"))
    }
    @objc(pagingStateInData:after:)
    public static func pagingState(data: Data, after request: Double) -> String {
        do {
            let report = try JSONDecoder().decode(TraceJSON.self, from: data)
            return try PagerReadiness.isIdle(report, requestedAt: request) ? "idle" : "moving"
        } catch { return "\(error)" }
    }

    @objc(validateData:label:)
    public static func validate(data: Data, label: String) -> String? {
        do {
            let report = try JSONDecoder().decode(TraceJSON.self, from: data)
            let checker = RecordedTraceChecker(plans: try RegressionResources.json("query-free-cases"))
            let count = try checker.check(report, label: label, requireActual: true, requireLifetimes: true)
            NSLog("SUIMT_XCTEST_VALIDATED %@ (%ld context transitions; actual offsets and client state checked where applicable)", label, count)
            return nil
        } catch { return "\(label): \(error)" }
    }
}

/// XCTest continues to enumerate tests after a failure. Under these plans,
/// remaining UI cases are explicitly skipped, never silently reported passed.
@objc(SUIMTRegressionRunObserver)
public final class RegressionRunObserver: NSObject, XCTestObservation {
    private static let shared = RegressionRunObserver()
    private static var installed = false
    private var firstFailure: String?
    @objc public static func install() {
        guard !installed else { return }
        installed = true
        XCTestObservationCenter.shared.addTestObserver(shared)
    }
    @objc public static var precedingFailure: String? {
        ProcessInfo.processInfo.environment["SUIMT_FAIL_FAST"] == "1" ? shared.firstFailure : nil
    }
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        if firstFailure == nil { firstFailure = "\(testCase.name): \(description)" }
    }
}
