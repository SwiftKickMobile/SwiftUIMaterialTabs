import SwiftUI
import Combine
import SwiftUIMaterialTabs
#if DEBUG
@_spi(Testing) import SwiftUIMaterialTabs
#endif

/// Stable fixture for header continuity, page retention, and native scroll-edge tests.
struct MaterialTabsTestView: View {
    private enum Tab: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case activity = "Activity"
        case notes = "Notes"

        var id: Self { self }
    }

    private enum EdgeStyle: String, CaseIterable, Identifiable {
        case automatic = "Automatic"
        case soft = "Soft"
        case hard = "Hard"

        var id: Self { self }

        @available(iOS 26.0, *)
        var style: ScrollEdgeEffectStyle {
            switch self {
            case .automatic: .automatic
            case .soft: .soft
            case .hard: .hard
            }
        }
    }

    private enum Layout: String {
        case materialTabs = "SUIMT + safeAreaBar"
        case overlay = "SUIMT overlay"
    }

    @State private var selectedTab: Tab = .activity
    @State private var layout: Layout = .materialTabs
    @State private var edgeStyle: EdgeStyle = .automatic
    @State private var resetID = 0

    init() {
        let env = ProcessInfo.processInfo.environment
        if env["SUIMT_BROAD_REPLAY"] == "1" {
            let initial = Tab.allCases.first { $0.rawValue.lowercased() == env["SUIMT_INITIAL_TAB"] } ?? .activity
            _selectedTab = State(initialValue: initial)
            _layout = State(initialValue: env["SUIMT_NATIVE_EDGE"] == "0" ? .overlay : .materialTabs)
        }
    }

    private var replayConfig: MaterialTabsConfig {
        guard ProcessInfo.processInfo.environment["SUIMT_BROAD_REPLAY"] == "1" else { return .init() }
        switch ProcessInfo.processInfo.environment["SUIMT_SYNC_MODE"] {
        case "preserve": return .init(crossTabSyncMode: .preserveScrollPosition)
        case "resetPosition": return .init(crossTabSyncMode: .resetScrollPosition)
        default: return .init()
        }
    }

    private var replayRowCount: Int {
        guard ProcessInfo.processInfo.environment["SUIMT_BROAD_REPLAY"] == "1" else { return 30 }
        return max(1, Int(ProcessInfo.processInfo.environment["SUIMT_ROW_COUNT"] ?? "30") ?? 30)
    }

    private var replayTitleHeight: CGFloat {
        guard ProcessInfo.processInfo.environment["SUIMT_BROAD_REPLAY"] == "1" else { return 150 }
        return CGFloat(max(0, Double(ProcessInfo.processInfo.environment["SUIMT_TITLE_HEIGHT"] ?? "150") ?? 150))
    }

    private var replayMinimumTitleHeight: CGFloat {
        guard ProcessInfo.processInfo.environment["SUIMT_BROAD_REPLAY"] == "1" else { return 0 }
        return CGFloat(max(0, Double(ProcessInfo.processInfo.environment["SUIMT_MIN_TITLE_HEIGHT"] ?? "0") ?? 0))
    }
    var body: some View {
        NavigationStack {
            styledTestContent
            .id(resetID)
            .background {
                testBackdrop
                    .ignoresSafeArea()
            }
            .navigationTitle(testTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back to top", systemImage: "arrow.up.to.line") {
                        resetID += 1
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if #available(iOS 26.0, *) {
                        Picker("Scroll-edge style", selection: $edgeStyle) {
                            ForEach(EdgeStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Prototype settings")
                }
            }
            .onChange(of: layout) { resetID += 1 }
            .onChange(of: edgeStyle) { resetID += 1 }
        }
        .tint(.primary)
    }

    @ViewBuilder
    private var styledTestContent: some View {
        if #available(iOS 26.0, *) {
            testContent.scrollEdgeEffectStyle(edgeStyle == .automatic ? nil : edgeStyle.style, for: .top)
        } else {
            testContent
        }
    }

    private var testTitle: String {
        if #available(iOS 26.0, *) { return layout.rawValue }
        return "SUIMT · legacy navigation"
    }

    private var testContent: some View { materialTabsContent }

    @ViewBuilder
    private var materialTabsContent: some View {
        if #available(iOS 26.0, *) {
            materialTabsBase.materialTabsScrollEdgeEffect(nativeEffectEnabled)
        } else {
            materialTabsBase
        }
    }

    private var materialTabsBase: some View {
        MaterialTabs(
                selectedTab: $selectedTab,
                config: replayConfig,
                headerTitle: { context in
                    if replayTitleHeight > 0 {
                    VStack(spacing: 8) {
                        Text(context.selectedTab.rawValue)
                            .font(.largeTitle.bold())
                        Text("Collapsible header")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: replayTitleHeight)
                    .minTitleHeight(.absolute(replayMinimumTitleHeight))
                    .headerStyle(OffsetHeaderStyle<Tab>(fade: true), context: context)
                    }
                },
                headerTabBar: { context in
                    MaterialTabBar<Tab>(
                        selectedTab: $selectedTab,
                        sizing: .equalWidth,
                        spacing: 0,
                        fillAvailableSpace: true,
                        context: context
                    )
                    .foregroundStyle(.primary, .secondary)
                },
                headerBackground: { context in
                    if context.selectedTab == .notes {
                        Image("coffee")
                            .resizable()
                            .scaledToFill()
                            .frame(width: context.width, height: context.backgroundHeight)
                            .clipped()
                    }
                },
                content: {
                    ForEach(Tab.allCases) { tab in
                        MaterialTabsScroll(tab: tab) { _ in
                            rows(tab: tab)
                        }
                        .materialTabItem(tab: tab, label: .primary(tab.rawValue))
                    }
                }
            )
    }

    private var nativeEffectEnabled: Bool { layout == .materialTabs }

    private func rows(tab: Tab) -> some View {
        LazyVStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(testTitle)
                    .font(.title2.bold())
                Text("Compare the checkerboard at rest, while scrolling, and after returning to the top. Change layouts in the settings menu.")
                    .foregroundStyle(.secondary)
                Text("Scroll-edge style: \(edgeStyle.rawValue)")
                    .font(.caption.monospaced())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)

            ForEach(1...replayRowCount, id: \.self) { index in
                testRow(index, tab: tab)
                    .id(index)
            }
        }
        .padding(.vertical, 16)
        .scrollTargetLayout()
        #if DEBUG
        .modifier(TabContentLifecycleProbe(tab: tab.rawValue, selection: selectedTab.rawValue))
        #endif
    }

    private var testBackdrop: some View {
        Canvas { context, size in
            let cell: CGFloat = 24
            for row in 0..<Int(ceil(size.height / cell)) {
                for column in 0..<Int(ceil(size.width / cell)) {
                    let rect = CGRect(
                        x: CGFloat(column) * cell,
                        y: CGFloat(row) * cell,
                        width: cell,
                        height: cell
                    )
                    let color: Color = (row + column).isMultiple(of: 2) ? .cyan : .yellow
                    context.fill(Path(rect), with: .color(color.opacity(0.65)))
                }
            }
        }
        .background(Color(.systemBackground))
        .accessibilityHidden(true)
    }

    private func testRow(_ index: Int, tab: Tab) -> some View {
        let colors: [Color] = [.cyan, .pink, .yellow, .mint, .orange, .purple]
        let tabOffset = Tab.allCases.firstIndex(of: tab) ?? 0
        let color = colors[(index - 1 + tabOffset) % colors.count]

        return HStack(spacing: 20) {
            Text(String(format: "%02d", index))
                .font(.system(size: 56, weight: .black, design: .rounded))
                .monospacedDigit()
            VStack(alignment: .leading, spacing: 8) {
                Text(tab.rawValue)
                    .font(.title2.bold())
                Text("Row \(index)")
                    .font(.headline)
                Rectangle()
                    .frame(height: 4)
                Rectangle()
                    .frame(width: 90, height: 4)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.black)
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(color, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}

/// Query-free port of the legacy onScrollPhaseChange-driven selection test.
@available(iOS 18.0, *)
struct FlickRegressionView: View {
    private enum Tab: String, CaseIterable, Identifiable {
        case overview = "Overview", activity = "Activity", notes = "Notes"
        var id: Self { self }
    }
    @State private var selection: Tab = .activity
    @State private var hasSwitched = false
    private var switchOnDeceleration: Bool { ProcessInfo.processInfo.environment["SUIMT_PHASE_SWITCH"] == "1" }
    @ViewBuilder private var styledTabs: some View {
        if #available(iOS 26.0, *) {
            tabs.materialTabsScrollEdgeEffect(ProcessInfo.processInfo.environment["SUIMT_NATIVE_EDGE"] == "1")
        } else { tabs }
    }
    var body: some View {
        NavigationStack {
            styledTabs
                .navigationTitle("Flick regression")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { Button("Top", systemImage: "arrow.up.to.line") {} }
                    ToolbarItem(placement: .topBarTrailing) { Button("Settings", systemImage: "slider.horizontal.3") {} }
                }
        }
    }
    private var tabs: some View {
        MaterialTabs(selectedTab: $selection, headerTitle: { context in
            Text(context.selectedTab.rawValue).font(.largeTitle.bold())
                .frame(maxWidth: .infinity).frame(height: 150)
                .headerStyle(OffsetHeaderStyle<Tab>(fade: true), context: context)
        }, headerTabBar: { context in
            MaterialTabBar(selectedTab: $selection, sizing: .equalWidth, spacing: 0,
                           fillAvailableSpace: true, context: context)
                .overlay(alignment: .topTrailing) {
                    if ProcessInfo.processInfo.environment["SUIMT_FLICK_CONTEXT_READOUT"] == "1" {
                        Text("Context: \(context.contentOffset, specifier: "%.1f")")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.black).background(.white)
                            .allowsHitTesting(false)
                    }
                }
        }, content: {
            ForEach(Tab.allCases) { tab in
                MaterialTabsScroll(tab: tab) { _ in
                    LazyVStack(spacing: 16) {
                        ForEach(0..<30) { row in
                            Text("\(tab.rawValue) — Row \(row)").font(.title.bold())
                                .frame(maxWidth: .infinity).frame(height: 160)
                                .background(tab == .activity ? Color.orange : tab == .overview ? Color.cyan : Color.mint)
                                .id(row)
                        }
                    }
                    .scrollTargetLayout()
                    #if DEBUG
                    .modifier(TabContentLifecycleProbe(tab: tab.rawValue, selection: selection.rawValue))
                    #endif
                }
                .onScrollPhaseChange { _, phase in
                    #if DEBUG
                    MaterialTabsTrace.scrollPhase(tab: tab.rawValue.lowercased(),
                                                  phase: phase == .decelerating ? "decelerating" : String(describing: phase))
                    #endif
                    if switchOnDeceleration && !hasSwitched && tab == .activity && phase == .decelerating {
                        #if DEBUG
                        NativeScrollSnapshot.captureForExport()
                        #endif
                        hasSwitched = true
                        selection = .overview
                    }
                }
                .materialTabItem(tab: tab, label: .primary(tab.rawValue))
            }
        })
    }
}

/// Separate fixture so external-binding coverage does not change the ordinary
/// demo's page hierarchy or replace its internal scroll-position bindings.
struct ExternalScrollRegressionView: View {
    private enum Tab: String, CaseIterable, Identifiable {
        case overview = "Overview", activity = "Activity", notes = "Notes"
        var id: Self { self }
    }
    @State private var selectedTab: Tab = .activity
    @State private var positions: [Tab: ScrollPosition] = [:]
    @State private var unitPoints: [Tab: UnitPoint] = [:]

    @ViewBuilder private var styledTabs: some View {
        if #available(iOS 26.0, *) {
            tabs.materialTabsScrollEdgeEffect(ProcessInfo.processInfo.environment["SUIMT_NATIVE_EDGE"] == "1")
        } else {
            tabs
        }
    }

    var body: some View {
        NavigationStack {
            styledTabs
                .navigationTitle("External position")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Top") { request(0) }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Row 10") { request(10) }
                    }
                }
        }
    }

    private func request(_ row: Int) {
        #if DEBUG
        ManualInteractionTrace.recordExternalRequest(tab: selectedTab.rawValue.lowercased(), row: row)
        #endif
        unitPoints[selectedTab] = .top
        positions[selectedTab, default: ScrollPosition()].scrollTo(id: row, anchor: .top)
    }

    private var tabs: some View {
        MaterialTabs(selectedTab: $selectedTab, headerTitle: { context in
            Text(context.selectedTab.rawValue)
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .headerStyle(OffsetHeaderStyle<Tab>(fade: true), context: context)
        }, headerTabBar: { context in
            MaterialTabBar(selectedTab: $selectedTab, sizing: .equalWidth,
                           spacing: 0, fillAvailableSpace: true, context: context)
        }, content: {
            ForEach(Tab.allCases) { tab in
                MaterialTabsScroll(tab: tab,
                    scrollPosition: Binding(get: { positions[tab] ?? ScrollPosition() }, set: { positions[tab] = $0 }),
                    anchor: Binding(get: { unitPoints[tab] }, set: { unitPoints[tab] = $0 })) { _ in
                    LazyVStack(spacing: 16) {
                        ForEach(0..<30) { row in
                            Text("\(tab.rawValue) — Row \(row)")
                                .font(.title.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .background(tab == .overview ? Color.cyan : tab == .activity ? Color.orange : Color.mint)
                                #if DEBUG
                                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                                    ManualInteractionTrace.recordRowFrame(tab: tab.rawValue.lowercased(), row: row, frame: frame)
                                }
                                .onDisappear {
                                    ManualInteractionTrace.recordRowFrame(tab: tab.rawValue.lowercased(), row: row, frame: nil)
                                }
                                #endif
                                .id(row)
                        }
                    }
                    .scrollTargetLayout()
                    #if DEBUG
                    .modifier(TabContentLifecycleProbe(tab: tab.rawValue, selection: selectedTab.rawValue))
                    #endif
                }
                .materialTabItem(tab: tab, label: .primary(tab.rawValue))
            }
        })
    }
}

#if DEBUG
/// Root content state, not a lazily realized row. This deliberately observes
/// both State and StateObject storage, independently of SUIMT's scroll model.
private struct TabContentLifecycleProbe: ViewModifier {
    final class Lifetime: ObservableObject {
        let id = UUID().uuidString
        var visits = 0
    }
    let tab: String
    let selection: String
    @State private var stateID = UUID().uuidString
    @StateObject private var lifetime = Lifetime()
    @Environment(\.materialTabsTraceRegistration) private var registration

    func body(content: Content) -> some View {
        if ProcessInfo.processInfo.environment["SUIMT_LAUNCH_PROBE"] == "1" {
            // Observe evaluation without reading/initializing the probe's state objects.
            MaterialTabsTrace.contentBody(tab: tab, registration: registration)
        }
        return content.onAppear {
            guard ProcessInfo.processInfo.environment["SUIMT_LIFECYCLE_PROBE"] == "1" else { return }
            lifetime.visits += 1
            report("appear")
        }
        .onDisappear {
            guard ProcessInfo.processInfo.environment["SUIMT_LIFECYCLE_PROBE"] == "1" else { return }
            report("disappear")
        }
        .onChange(of: selection, initial: true) {
            guard selection == tab,
                  ProcessInfo.processInfo.environment["SUIMT_LIFECYCLE_PROBE"] == "1" else { return }
            report("selected")
        }
    }

    private func report(_ phase: String) {
        MaterialTabsTrace.contentLifecycle(tab: tab, phase: phase, stateID: stateID,
                                           objectID: lifetime.id, visits: lifetime.visits,
                                           registration: registration)
    }
}
#endif
