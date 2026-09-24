import SwiftUI
import SwiftUIMaterialTabs

/// Temporary harness for the native navigation/tab-bar scroll-edge prototype.
@available(iOS 26.0, *)
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

    var body: some View {
        NavigationStack {
            testContent
            .scrollEdgeEffectStyle(edgeStyle == .automatic ? nil : edgeStyle.style, for: .top)
            .id(resetID)
            .background {
                testBackdrop
                    .ignoresSafeArea()
            }
            .navigationTitle(layout.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back to top", systemImage: "arrow.up.to.line") {
                        resetID += 1
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
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
    private var testContent: some View {
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
            MaterialTabs(
                selectedTab: $selectedTab,
                headerTitle: { context in
                    VStack(spacing: 8) {
                        Text(context.selectedTab.rawValue)
                            .font(.largeTitle.bold())
                        Text("Collapsible header")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .headerStyle(OffsetHeaderStyle<Tab>(fade: true), context: context)
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
            .materialTabsScrollEdgeEffect(layout == .materialTabs)
        }
    }

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
                Text(layout.rawValue)
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

            ForEach(1...30, id: \.self) { index in
                testRow(index, tab: tab)
                    .id(index)
            }
        }
        .padding(.vertical, 16)
        .scrollTargetLayout()
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
