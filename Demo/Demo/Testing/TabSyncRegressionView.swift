import SwiftUI
@_spi(Testing) import SwiftUIMaterialTabs

/// Deterministic UI-test fixture. No timers, automatic scrolling, or state resets.
@available(iOS 26.0, *)
struct TabSyncRegressionView: View {
    private let environment = ProcessInfo.processInfo.environment
    @State private var selectedTab = 0
    @State private var scrollItems: [Int: Int] = [:]
    @State private var switchDuringDeceleration = false
    @State private var pageOffsets: [Int: CGFloat] = [:]
    @State private var referenceOffset: CGFloat = 0

    init() {
        _selectedTab = State(initialValue: Int(ProcessInfo.processInfo.environment["SUIMT_INITIAL_TAB"] ?? "0") ?? 0)
    }

    private var native: Bool { environment["SUIMT_NATIVE_EDGE"] == "1" }
    private var titleHeight: CGFloat { CGFloat(Double(environment["SUIMT_TITLE_HEIGHT"] ?? "150") ?? 150) }
    private var minimumTitleHeight: CGFloat { CGFloat(Double(environment["SUIMT_MIN_TITLE_HEIGHT"] ?? "0") ?? 0) }
    private var rowCount: Int { Int(environment["SUIMT_ROW_COUNT"] ?? "40") ?? 40 }
    private var externalPosition: Bool { environment["SUIMT_EXTERNAL_POSITION"] == "1" }
    private var visualPattern: Bool { environment["SUIMT_VISUAL_PATTERN"] == "1" }

    private struct ObservedScrollGeometry: Equatable {
        let offset: CGFloat
        let maximum: CGFloat
        let viewport: CGFloat
    }

    private var config: MaterialTabsConfig {
        switch environment["SUIMT_SYNC_MODE"] {
        case "preserve": .init(crossTabSyncMode: .preserveScrollPosition)
        case "resetPosition": .init(crossTabSyncMode: .resetScrollPosition)
        default: .init(crossTabSyncMode: .resetTitleOnScroll())
        }
    }

    var body: some View {
        if environment["SUIMT_NATIVE_REFERENCE"] == "1" {
            nativeReference
        } else {
            materialTabsFixture
        }
    }

    private var nativeReference: some View {
        NavigationStack {
            ScrollView { rows(0) }
                .scrollClipDisabled()
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { _, offset in referenceOffset = offset }
                .safeAreaBar(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Shared header")
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: titleHeight)
                        HStack(spacing: 0) {
                            ForEach(["A", "B", "C"], id: \.self) { title in
                                Button {} label: {
                                    Text(title)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, minHeight: 46)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("sync-header")
                        .accessibilityValue(Text(verbatim: "tab=0;offset=0;content=\(referenceOffset);max=0;height=\(titleHeight + 46)"))
                    }
                    #if DEBUG
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                        ManualInteractionTrace.recordRowFrame(tab: "native-header", row: -1, frame: frame)
                    }
                    #endif
                }
                .background { if visualPattern { checkerboard.ignoresSafeArea() } }
                .navigationTitle("Native reference")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var materialTabsFixture: some View {
        NavigationStack {
            MaterialTabs(
                selectedTab: $selectedTab,
                config: config,
                headerTitle: { context in
                    Text("Shared header")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: titleHeight)
                        .minTitleHeight(.absolute(minimumTitleHeight))
                        .headerStyle(OffsetHeaderStyle<Int>(fade: true), context: context)
                },
                headerTabBar: { context in
                    MaterialTabBar<Int>(
                        selectedTab: $selectedTab,
                        sizing: .equalWidth,
                        spacing: 0,
                        fillAvailableSpace: true,
                        context: context
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("sync-header")
                    .accessibilityValue(Text(verbatim: "tab=\(context.selectedTab);offset=\(context.offset);content=\(context.contentOffset);max=\(context.maxOffset);height=\(context.height);page0=\(pageOffsets[0] ?? 0);page1=\(pageOffsets[1] ?? 0);page2=\(pageOffsets[2] ?? 0)"))
                },
                content: {
                    ForEach(0..<3) { tab in
                        page(tab)
                            .onScrollGeometryChange(for: ObservedScrollGeometry.self) { geometry in
                                ObservedScrollGeometry(
                                    offset: geometry.contentOffset.y + geometry.contentInsets.top,
                                    maximum: max(0, geometry.contentSize.height - geometry.containerSize.height
                                                 + geometry.contentInsets.top + geometry.contentInsets.bottom),
                                    viewport: geometry.containerSize.height)
                            } action: { _, geometry in
                                #if DEBUG
                                MaterialTabsTrace.scrollRange(tab: String(tab), offset: Double(geometry.offset),
                                                              maximum: Double(geometry.maximum), viewport: Double(geometry.viewport))
                                #endif
                                // Read-only test instrumentation; never drives a scroll.
                                if environment["SUIMT_DECELERATION_SWITCH"] == "1" {
                                    pageOffsets[tab] = geometry.offset
                                }
                            }
                            .onScrollPhaseChange { _, phase in
                                #if DEBUG
                                MaterialTabsTrace.scrollPhase(tab: String(tab), phase: String(describing: phase))
                                #endif
                                // Deterministically exercise selection while the old
                                // page is still moving, without a timing-based sleep.
                                if phase == .decelerating, switchDuringDeceleration, selectedTab == tab {
                                    switchDuringDeceleration = false
                                    selectedTab = (tab + 1) % 3
                                }
                            }
                            .materialTabItem(tab: tab, label: .primary(["A", "B", "C"][tab]))
                    }
                }
            )
            .materialTabsScrollEdgeEffect(native)
            .background {
                if visualPattern { checkerboard.ignoresSafeArea() }
            }
            .navigationTitle("Tab Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if environment["SUIMT_DECELERATION_SWITCH"] == "1" {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Switch on fling") { switchDuringDeceleration = true }
                            .accessibilityIdentifier("arm-fling-switch")
                    }
                }
                if externalPosition {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Top") { scrollItems[selectedTab] = 0 }
                            .accessibilityIdentifier("jump-top")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Row 10") { scrollItems[selectedTab] = 10 }
                            .accessibilityIdentifier("jump-10")
                    }
                }
            }
        }
    }

    @ViewBuilder private func page(_ tab: Int) -> some View {
        if externalPosition {
            MaterialTabsScroll(
                tab: tab,
                reservedItem: -1,
                scrollItem: Binding(get: { scrollItems[tab] }, set: { scrollItems[tab] = $0 }),
                scrollUnitPoint: .constant(.top)
            ) { _ in
                rows(tab)
            }
            .accessibilityIdentifier("scroll-\(tab)")
        } else {
            MaterialTabsScroll(tab: tab) { _ in
                rows(tab)
            }
            .accessibilityIdentifier("scroll-\(tab)")
        }
    }

    private func rows(_ tab: Int) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { row in
                VStack(spacing: 0) {
                    Text("\(["A", "B", "C"][tab]) — Row \(row)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Divider()
                }
                .frame(height: 100)
                .background {
                    if visualPattern {
                        checkerboard
                    } else {
                        [Color.cyan, .orange, .mint][tab].opacity(row.isMultiple(of: 2) ? 0.2 : 0.4)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("row-\(tab)-\(row)")
                .id(row)
            }
        }
        .scrollTargetLayout()
    }

    private var checkerboard: some View {
        Canvas { context, size in
            let side: CGFloat = 16
            for row in 0..<Int(ceil(size.height / side)) {
                for column in 0..<Int(ceil(size.width / side)) {
                    context.fill(
                        Path(CGRect(x: CGFloat(column) * side, y: CGFloat(row) * side,
                                    width: side, height: side)),
                        with: .color((row + column).isMultiple(of: 2) ? .cyan : .yellow)
                    )
                }
            }
        }
    }
}
