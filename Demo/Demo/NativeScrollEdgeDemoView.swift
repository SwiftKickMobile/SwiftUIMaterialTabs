import SwiftUI
import SwiftUIMaterialTabs
#if DEBUG
@_spi(Testing) import SwiftUIMaterialTabs
#endif

/// Temporary harness for the native navigation/tab-bar scroll-edge prototype.
@available(iOS 17.0, *)
struct NativeScrollEdgeDemoView: View {
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

    private enum Layout: String, CaseIterable, Identifiable {
        case plain = "Plain ScrollView"
        case safeAreaBar = "ScrollView + safeAreaBar"
        case geometry = "Native + GeometryReader"
        case pager = "Native + horizontal pager"
        case nested = "Nested scroll views only"
        case nestedInnerEffect = "Nested: inner effect only"
        case nestedBarInside = "Nested: bar on vertical scroll"
        case systemPager = "Native + page TabView"
        case systemPagerInsets = "Page TabView + insets"
        case nativeProxyHard = "Persistent overlay + hard edge"
        case nativeProxyLabel = "Persistent overlay + native marker"
        case materialTabs = "SUIMT + safeAreaBar"
        case overlay = "SUIMT overlay"

        var id: Self { self }
    }

    @State private var selectedTab: Tab = .activity
    @State private var layout: Layout = .materialTabs
    @State private var selectedPage: Tab? = .activity
    @State private var edgeStyle: EdgeStyle = .automatic
    @State private var resetID = 0
    @State private var showOriginalDemo = false

    init() {
        let env = ProcessInfo.processInfo.environment
        if env["SUIMT_BROAD_REPLAY"] == "1" {
            let initial = Tab.allCases.first { $0.rawValue.lowercased() == env["SUIMT_INITIAL_TAB"] } ?? .activity
            _selectedTab = State(initialValue: initial)
            _selectedPage = State(initialValue: initial)
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
    #if DEBUG
    @State private var lifecycleOffset: CGFloat = 0
    private var lifecycleLayout: String { ProcessInfo.processInfo.environment["SUIMT_LIFECYCLE_LAYOUT"] ?? "" }
    #endif

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
                        Picker("Test layout", selection: $layout) {
                            ForEach(Layout.allCases) { layout in
                                Text(layout.rawValue).tag(layout)
                            }
                        }
                        Picker("Scroll-edge style", selection: $edgeStyle) {
                            ForEach(EdgeStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        Divider()
                        }
                        Button("Original demo") {
                            showOriginalDemo = true
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Prototype settings")
                }
            }
            .onChange(of: layout) { resetID += 1 }
            .onChange(of: selectedTab) { selectedPage = selectedTab }
            .onChange(of: selectedPage) {
                if let selectedPage { selectedTab = selectedPage }
            }
            .onChange(of: edgeStyle) { resetID += 1 }
            .sheet(isPresented: $showOriginalDemo) {
                DemoView()
            }
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

    @ViewBuilder
    private var testContent: some View {
        if #available(iOS 26.0, *) {
        #if DEBUG
        if lifecycleLayout.hasPrefix("plain-lazy") {
            lifecyclePager(eager: false)
        } else if lifecycleLayout.hasPrefix("plain-eager") {
            lifecyclePager(eager: true)
        } else {
            configuredTestContent
        }
        #else
        configuredTestContent
        #endif
        } else {
            materialTabsContent
        }
    }

    #if DEBUG
    @available(iOS 26.0, *)
    private func lifecyclePager(eager: Bool) -> some View {
        ScrollView(.horizontal) {
            Group {
                if eager {
                    HStack(spacing: 0) { lifecyclePages }
                } else {
                    LazyHStack(spacing: 0) { lifecyclePages }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $selectedPage, anchor: .center)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.never)
        .safeAreaBar(edge: .top, spacing: 0) { nativeTabSelectors }
    }

    @available(iOS 26.0, *)
    private var lifecyclePages: some View {
        ForEach(Tab.allCases) { tab in
            ScrollView { rows(tab: tab) }
                .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, offset in
                    if lifecycleLayout.hasSuffix("updates") { lifecycleOffset = offset }
                }
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                .id(tab)
        }
    }
    #endif

    @ViewBuilder
    @available(iOS 26.0, *)
    private var configuredTestContent: some View {
        switch layout {
        case .plain:
            ScrollView {
                rows(tab: .overview)
            }
        case .safeAreaBar:
            ScrollView {
                rows(tab: selectedTab)
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                nativeTabSelectors
            }
        case .geometry:
            GeometryReader { _ in
                ScrollView {
                    rows(tab: selectedTab)
                }
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                nativeTabSelectors
            }
        case .pager:
            GeometryReader { _ in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(Tab.allCases) { tab in
                            ScrollView {
                                rows(tab: tab)
                            }
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $selectedPage, anchor: .center)
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.never)
                .scrollBounceBehavior(.basedOnSize)
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                nativeTabSelectors
            }
        case .nested, .nestedInnerEffect:
            GeometryReader { _ in
                ScrollView(.horizontal) {
                    ScrollView {
                        rows(tab: .overview)
                    }
                    .scrollEdgeEffectHidden(false, for: .top)
                    .onScrollGeometryChange(for: String.self) { geometry in
                        scrollMetrics(geometry)
                    } action: { _, metrics in
                        print("[EdgeBisect] \(layout.rawValue) vertical: \(metrics)")
                    }
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                }
                .scrollEdgeEffectHidden(layout == .nestedInnerEffect, for: .top)
                .onScrollGeometryChange(for: String.self) { geometry in
                    scrollMetrics(geometry)
                } action: { _, metrics in
                    print("[EdgeBisect] \(layout.rawValue) horizontal: \(metrics)")
                }
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                nativeTabSelectors
            }
        case .nestedBarInside:
            GeometryReader { _ in
                ScrollView(.horizontal) {
                    ScrollView {
                        rows(tab: .overview)
                    }
                    .safeAreaBar(edge: .top, spacing: 0) {
                        nativeTabSelectors
                    }
                    .scrollEdgeEffectHidden(false, for: .top)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                }
                .scrollEdgeEffectHidden(true, for: .top)
            }
        case .systemPager:
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    ScrollView {
                        rows(tab: tab)
                    }
                    .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .safeAreaBar(edge: .top, spacing: 0) {
                nativeTabSelectors
            }
        case .systemPagerInsets:
            GeometryReader { proxy in
                TabView(selection: $selectedTab) {
                    ForEach(Tab.allCases) { tab in
                        ScrollView {
                            rows(tab: tab)
                        }
                        .scrollClipDisabled()
                        .safeAreaPadding(proxy.safeAreaInsets)
                        .tag(tab)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                nativeTabSelectors
            }
        case .nativeProxyHard, .nativeProxyLabel:
            ZStack(alignment: .top) {
                ScrollView(.horizontal) {
                    ScrollView {
                        rows(tab: .overview)
                    }
                    .safeAreaBar(edge: .top, spacing: 0) {
                        if layout == .nativeProxyLabel {
                            Text("Scroll edge")
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .foregroundStyle(.clear)
                                .accessibilityHidden(true)
                                .allowsHitTesting(false)
                        } else {
                            Color.clear.frame(height: 44)
                        }
                    }
                    .scrollEdgeEffectStyle(layout == .nativeProxyHard ? .hard : .automatic, for: .top)
                    .scrollEdgeEffectHidden(false, for: .top)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                }
                .scrollEdgeEffectHidden(true, for: .top)
                nativeTabSelectors
            }
        case .materialTabs, .overlay:
            materialTabsContent
        }
    }

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
                        Image(.coffee)
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

    private var nativeEffectEnabled: Bool {
        #if DEBUG
        if lifecycleLayout == "suimt-overlay" { return false }
        #endif
        return layout == .materialTabs
    }

    @available(iOS 18.0, *)
    private func scrollMetrics(_ geometry: ScrollGeometry) -> String {
        "offset=\(geometry.contentOffset), insets=\(geometry.contentInsets), viewport=\(geometry.containerSize), content=\(geometry.contentSize)"
    }

    private var nativeTabSelectors: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(selectedTab == tab ? Color.primary : Color.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .overlay(alignment: .bottom) {
                            if selectedTab == tab {
                                Capsule()
                                    .frame(height: 3)
                                    .padding(.horizontal, 16)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

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
        .overlay(alignment: .bottomLeading) {
            if lifecycleLayout.hasSuffix("updates") {
                Text("Diagnostic shared offset: \(lifecycleOffset)")
            }
        }
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

/// Diagnostic control: native registration plus persistent buttons, no SUIMT.
@available(iOS 26.0, *)
struct NativeFlickRoutingControl: View {
    @State private var selection = "Activity"
    private var headerScrolls: Bool { ProcessInfo.processInfo.environment["SUIMT_NATIVE_FLICK_HEADER_SCROLL"] == "1" }
    private var selectors: some View {
        HStack(spacing: 0) {
            ForEach(["Overview", "Activity", "Notes"], id: \.self) { tab in
                Button { selection = tab } label: {
                    Text(tab).font(.headline)
                        .foregroundStyle(selection == tab ? Color.black : Color.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                }
                .buttonStyle(.plain)
            }
        }
    }
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<30) { row in
                            Text("Row \(row)")
                                .font(.largeTitle.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .background(row.isMultiple(of: 2) ? Color.cyan : Color.orange)
                        }
                    }
                }
                .safeAreaBar(edge: .top, spacing: 0) {
                    Group {
                        if ProcessInfo.processInfo.environment["SUIMT_NATIVE_FLICK_SCALED"] == "1" {
                            // Match the library's marker on the calibrated 402pt fixture.
                            Text("Scroll edge")
                                .font(.system(size: 1))
                                .fixedSize()
                                .visualEffect { content, geometry in
                                    content.scaleEffect(x: 402 / geometry.size.width,
                                                        y: 46 / geometry.size.height,
                                                        anchor: .topLeading)
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        } else {
                            Text("Scroll edge").frame(maxWidth: .infinity)
                        }
                    }
                        .frame(height: 46)
                        .foregroundStyle(.clear)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
                if headerScrolls {
                    ScrollView(.horizontal) { selectors.frame(width: 402) }
                        .frame(height: 46)
                        .scrollIndicators(.never)
                        .scrollBounceBehavior(.basedOnSize)
                        .scrollEdgeEffectHidden(true, for: .top)
                } else {
                    selectors
                }
            }
            .navigationTitle("Selected: \(selection)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Top", systemImage: "arrow.up.to.line") {} }
                ToolbarItem(placement: .topBarTrailing) { Button("Settings", systemImage: "slider.horizontal.3") {} }
            }
        }
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
    @State private var items: [Tab: Int] = [:]
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
        items[selectedTab] = row
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
                MaterialTabsScroll(tab: tab, reservedItem: -1,
                    scrollItem: Binding(get: { items[tab] }, set: { items[tab] = $0 }),
                    scrollUnitPoint: Binding(get: { unitPoints[tab] ?? .top }, set: { unitPoints[tab] = $0 })) { _ in
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
