#if DEBUG
import SwiftUI
@_spi(Testing) import SwiftUIMaterialTabs

/// Manual diagnostics: read once AFTER the user's sequence. No subscriptions or
/// published state are added to the header or scroll models.
struct ContextTraceReadout: View {
    @State private var snapshot: Snapshot?
    @State private var error: String?

    private struct Snapshot {
        let tab: String
        let header: Double
        let published: Double
        let measured: Double?
    }

    private struct Page {
        var headerID: String?
        var tab: String?
        var appeared = false
        var registration = false
        var measured: Double?
    }

    private var label: String {
        ProcessInfo.processInfo.environment["SUIMT_MANUAL_TRACE_LABEL"] ?? "Context diagnostics"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption.bold())
            if let snapshot {
                row("Selected tab", snapshot.tab)
                row("Header offset", format(snapshot.header))
                row("Context offset", format(snapshot.published))
                row("Measured offset", snapshot.measured.map(format) ?? "Not recorded")
                if let measured = snapshot.measured, abs(measured - snapshot.published) > 0.5 {
                    Text("Context and measured offset disagree")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                }
                Text("Snapshot only; press Read values to refresh.").font(.caption2)
            }
            if let error { Text(error).font(.caption).foregroundStyle(.red) }
            HStack {
                Button("Read values", action: read)
                    .accessibilityIdentifier("manual-read-context")
                if snapshot != nil || error != nil {
                    Spacer()
                    Button("Hide") { snapshot = nil; error = nil }
                }
            }
            .font(.callout.bold())
        }
        .padding(12)
        .frame(width: 285)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(8)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).monospacedDigit()
        }
        .font(.callout)
    }

    private func format(_ value: Double) -> String { String(format: "%.1f", value == 0 ? 0 : value) }

    private func read() {
        do {
            let data = Data(MaterialTabsTrace.exportJSON().utf8)
            guard let report = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  report["enabled"] as? Bool == true, report["overflow"] as? Bool == false,
                  let events = report["events"] as? [[String: Any]],
                  let context = events.last(where: { $0["kind"] as? String == "context" }),
                  let headerID = context["headerID"] as? String,
                  let tab = context["selectedTab"] as? String,
                  let header = context["headerOffset"] as? Double,
                  let published = context["contentOffset"] as? Double else {
                error = "Trace unavailable or full. Relaunch the manual fixture."
                return
            }
            var pages: [String: Page] = [:]
            for event in events {
                guard let id = event["pageID"] as? String else { continue }
                var page = pages[id] ?? Page()
                if let value = event["headerID"] as? String { page.headerID = value }
                if let value = event["tab"] as? String { page.tab = value }
                if let value = event["appeared"] as? Bool { page.appeared = value }
                if let value = event["registration"] as? Bool { page.registration = value }
                if event["kind"] as? String == "offsetObserved" {
                    page.measured = event["contentOffset"] as? Double
                }
                pages[id] = page
            }
            let candidates = pages.values.filter {
                $0.headerID == headerID && $0.tab == tab && $0.appeared && !$0.registration
            }
            let name = ["0": "A", "1": "B", "2": "C"][tab] ?? tab
            snapshot = Snapshot(tab: name, header: header, published: published,
                                measured: candidates.count == 1 ? candidates.first?.measured : nil)
            error = candidates.count == 1 ? nil : "Cannot identify one active scroll model."
        } catch {
            self.error = "Could not decode the trace: \(error.localizedDescription)"
        }
    }
}
#endif
