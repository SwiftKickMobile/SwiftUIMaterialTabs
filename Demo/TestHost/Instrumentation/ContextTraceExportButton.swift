#if DEBUG
import SwiftUI
@_spi(Testing) import SwiftUIMaterialTabs

/// Its state changes only on explicit export, after the observed test action.
/// Keeping it separate avoids invalidating the demo or fixture's view state.
struct ContextTraceExportButton: View {
    @State private var report = ""

    var body: some View {
        VStack(alignment: .trailing) {
            if ProcessInfo.processInfo.environment["SUIMT_VIEW_CONTEXT_PROBE"] == "1" {
                MaterialTabsContextProbe()
            }
            HStack {
                if ProcessInfo.processInfo.environment["SUIMT_TRACE_SELF_TEST"] == "1" {
                    Button("Probe") { MaterialTabsTrace.runRecorderSelfTest() }
                        .accessibilityIdentifier("context-trace-probe")
                }
                Button("Trace") { report = MaterialTabsTrace.exportJSON() }
                    .padding(8)
                    .background(.background)
                    .accessibilityIdentifier("context-trace-export")
                    .accessibilityValue(Text(verbatim: report))
            }
        }
    }
}
#endif
