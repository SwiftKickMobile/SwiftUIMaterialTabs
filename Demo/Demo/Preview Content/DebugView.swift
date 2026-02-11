//
//  DebugView.swift
//  SwiftUIMaterialTabs
//
//  Debug views for diagnosing @Query re-evaluation during scroll churn.
//
//  ============================================================================
//  PROBLEM
//  ============================================================================
//
//  GenericPipelineStageView (in SalesPro) gets constant `body` re-evaluations
//  while the user scrolls. `Self._printChanges()` reports "@self changed" on
//  every frame. The view is hosted inside MaterialTabsScroll, which lives
//  inside MaterialTabs.
//
//  Root cause: GenericPipelineStageView uses SwiftData's @Query property
//  wrapper. @Query causes the view struct's byte representation to differ on
//  every reconstruction, defeating SwiftUI's default struct-diffing
//  optimization. Normally this wouldn't matter because SwiftUI only
//  reconstructs a child when the parent's body re-evaluates. But the parent
//  (MaterialTabsScroll / MaterialTabs) was using ObservableObject models that
//  publish on every scroll offset change, causing the entire tree to
//  re-evaluate — including the @Query child.
//
//  In short: ObservableObject publishes broadly → parent body re-evaluates →
//  child struct is reconstructed → @Query makes the struct bytes differ →
//  SwiftUI sees "@self changed" → child body re-evaluates. Every frame.
//
//  ============================================================================
//  SOLUTIONS CONSIDERED
//  ============================================================================
//
//  1. Equatable ContentWrapperView (REJECTED)
//     Wrapped the content in a view conforming to Equatable that compared a
//     "constant" context. Successfully blocked scroll churn, BUT also blocked
//     legitimate data updates from view models / @Query — content never
//     refreshed when real data changed.
//
//  2. StableContainer with explicit Equatable input (WORKS — see DebugView3)
//     Wrapped the @Query child in a generic Equatable container that compares
//     an explicit `Input` value. Only re-evaluates the child when `Input`
//     changes. Successfully blocks scroll churn while allowing data updates.
//     REJECTED for practical reasons: requires the developer to manually
//     bundle ALL inputs into a single Equatable type. Fragile — a missed
//     input silently breaks updates. Not viable as a library-level solution.
//
//  3. @Observable refactor (VALIDATED — see DebugView + DebugView4)
//     Convert HeaderContext from a struct to an @Observable class, and convert
//     HeaderModel / ScrollModel / TabBarModel from ObservableObject to
//     @Observable. This gives property-level observation tracking:
//       - Views that read `offset` (header) re-evaluate on scroll (correct)
//       - Views that only read layout properties (e.g. `maxOffset`) do NOT
//         re-evaluate on scroll
//       - Content views that read NO context properties are completely
//         invisible to scroll changes — no reconstruction, no @Query churn
//     Uses "bridge views" (HeaderBridgeView, ContentBridgeView) to scope
//     property reads: the header closure executes inside the bridge's body,
//     so offset tracking is attributed to the bridge, not the parent.
//     This is the chosen solution.
//
//  ============================================================================
//  DEBUG VIEW ITERATIONS
//  ============================================================================
//
//  DebugView  — Tests @Observable HeaderContext in the environment. Parent
//               reads only layout props, header reads offset, content reads
//               nothing. Validates property-level tracking.
//
//  DebugView2 — Minimal repro of the BROKEN behavior. Uses ObservableObject
//               Driver that publishes every tick. Child has @Query. Shows
//               "@self changed" on every tick.
//
//  DebugView3 — StableContainer workaround. Wraps child in Equatable gate
//               keyed on explicit input. Works but impractical (see above).
//
//  DebugView4 — Tests @Observable passed via init + closure (mirrors the
//               actual library API shape). Uses HeaderBridge to scope reads.
//               Content closure receives no context. Validates that the
//               closure-based API preserves property-level tracking.
//
//  ============================================================================

import SwiftUI
import SwiftData

@Model
private class DemoItem {
    var name: String
    init(name: String) { self.name = name }
}

// MARK: - DebugView — @Observable context in environment

// Theory: Make the context itself @Observable and place it in the environment.
// Each view reads only the properties it needs. @Observable tracks property-level
// access, so:
//   - A "header" view that reads `offset` re-evaluates on scroll (correct)
//   - A "layout" parent that reads `maxOffset` (derived from heights) does NOT
//     re-evaluate on scroll
//   - A content view (with @Query) that reads NO context properties is completely
//     invisible to scroll changes
//
// This mirrors the proposed library change: HeaderContext becomes @Observable,
// placed in the environment. No split state, no bridge views, no Equatable gates.

@Observable
private class MockHeaderContext {
    // Scroll-driven — changes every 0.5s (simulates offset)
    var offset: CGFloat = 0

    // Layout-driven — changes every 2s (simulates header height changes)
    var titleHeight: CGFloat = 100

    // Derived layout property (doesn't depend on offset)
    var maxOffset: CGFloat { titleHeight - 44 }
}

// Simulates a header view that reads offset for visual effects.
// SHOULD re-evaluate on every scroll tick.
private struct MockHeaderView: View {
    @Environment(MockHeaderContext.self) private var context

    var body: some View {
        let _ = Self._printChanges()
        let _ = print("⚡ MockHeaderView offset=\(context.offset)")
        Text("Header offset=\(String(format: "%.0f", context.offset))")
            .opacity(1.0 - Double(context.offset / max(context.maxOffset, 1)))
    }
}

// Simulates MaterialTabs.body — reads only layout properties from context.
// Should NOT re-evaluate when offset changes.
private struct MockMaterialTabs<Content: View>: View {
    @Environment(MockHeaderContext.self) private var context
    @ViewBuilder let content: () -> Content

    var body: some View {
        let _ = Self._printChanges()
        let _ = print("⚡ MockMaterialTabs maxOffset=\(context.maxOffset)")
        VStack(spacing: 0) {
            MockHeaderView()
            content()
                .padding(.top, context.maxOffset) // only reads layout
        }
    }
}

// Content view with @Query — reads NO context properties.
// Should NEVER re-evaluate due to scroll.
private struct ContentViewObservable: View {
    @Query private var items: [DemoItem]

    var body: some View {
        let _ = Self._printChanges()
        let _ = print("⚡ ContentViewObservable evaluated")
        Text("Content (items: \(items.count))")
    }
}

struct DebugView: View {
    @State private var context = MockHeaderContext()

    var body: some View {
        MockMaterialTabs {
            ContentViewObservable()
        }
        .environment(context)
        .modelContainer(for: DemoItem.self, inMemory: true)
        .onAppear {
            // Fast tick: simulates scroll offset churn (every 0.5s)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                Task { @MainActor in context.offset += 1 }
            }
            // Slow tick: simulates layout change (every 2s)
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                Task { @MainActor in context.titleHeight += 10 }
            }
        }
    }
}

// MARK: - DebugView2 — Minimal @Query repro WITHOUT fix

// Demonstrates the problem: ObservableObject Driver publishes on every tick.
// ParentView2 re-evaluates → ChildView2 (with @Query) is reconstructed →
// @self changed on every tick.

@Observable
private class Driver {
    @Published var tick: Int = 0
}

private class Driver: ObservableObject {
    @Published var tick: Int = 0
}

private class SlowDriver: ObservableObject {
    @Published var value: Int = 0
}

private struct ChildView2: View {
    let externalValue: Int
    @Query private var items: [DemoItem]

    var body: some View {
        let _ = Self._printChanges()
        let _ = print("⚡ ChildView2 externalValue=\(externalValue)")
        Text("Child2 externalValue=\(externalValue)")
    }
}

private struct ParentView2: View {
    @EnvironmentObject private var driver: Driver
    @EnvironmentObject private var slowDriver: SlowDriver

    var body: some View {
        let _ = driver.tick
        ChildView2(externalValue: slowDriver.value)
    }
}

struct DebugView2: View {
    @StateObject private var driver = Driver()
    @StateObject private var slowDriver = SlowDriver()

    var body: some View {
        ParentView2()
            .environmentObject(driver)
            .environmentObject(slowDriver)
            .modelContainer(for: DemoItem.self, inMemory: true)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    driver.tick += 1
                }
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    slowDriver.value += 1
                }
            }
    }
}

// MARK: - DebugView3 — StableContainer workaround (Equatable gate)

// Wraps the @Query child in an Equatable container that compares `input`.
// Prevents reconstruction during scroll churn, but requires the caller to
// explicitly route all meaningful inputs through the container — fragile
// because a missed input silently breaks updates.

private struct StableContainer<Input: Equatable, Content: View>: View, Equatable {
    let input: Input
    @ViewBuilder let content: (Input) -> Content

    var body: some View {
        let _ = Self._printChanges()
        content(input)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.input == rhs.input
    }
}

private struct ChildView3: View {
    let externalValue: Int
    @Query private var items: [DemoItem]

    var body: some View {
        let _ = Self._printChanges()
        let _ = print("⚡ ChildView3 externalValue=\(externalValue)")
        Text("Child3 externalValue=\(externalValue)")
    }
}

private struct ParentView3: View {
    @EnvironmentObject private var driver: Driver
    @EnvironmentObject private var slowDriver: SlowDriver

    var body: some View {
        let _ = driver.tick
        StableContainer(input: slowDriver.value) { externalValue in
            ChildView3(externalValue: externalValue)
        }
    }
}

struct DebugView3: View {
    @StateObject private var driver = Driver()
    @StateObject private var slowDriver = SlowDriver()

    var body: some View {
        ParentView3()
            .environmentObject(driver)
            .environmentObject(slowDriver)
            .modelContainer(for: DemoItem.self, inMemory: true)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    driver.tick += 1
                }
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    slowDriver.value += 1
                }
            }
    }
}

// MARK: - DebugView4 — @Observable passed via init + closure (preserving current API shape)

// Tests whether the current public API pattern can be preserved:
//   - Parent passes @Observable context through a closure parameter (like header builders)
//   - A "bridge" child view invokes the closure, so property reads are scoped to the bridge
//   - Content closure receives no context (like the no-context initializers)
//
// Key question: does passing the @Observable object through init/closure parameters
// still give property-level tracking? Or does the parent track something just by
// passing the reference?

// Bridge view that invokes the header closure — property reads from the closure
// are tracked in THIS view's scope, not the parent's.
private struct HeaderBridge<HeaderContent: View>: View {
    let context: MockHeaderContext
    @ViewBuilder let headerBuilder: (MockHeaderContext) -> HeaderContent

    var body: some View {
        let _ = Self._printChanges()
        let _ = print("⚡ HeaderBridge evaluated")
        headerBuilder(context)
    }
}

// Simulates MaterialTabs.body with closure-based API.
// Passes context to the header via a bridge view.
// Calls content() directly — no context involved.
// Should NOT re-evaluate when offset changes.
private struct MockMaterialTabsClosureAPI<HeaderContent: View, Content: View>: View {
    @Environment(MockHeaderContext.self) private var context
    @ViewBuilder let header: (MockHeaderContext) -> HeaderContent
    @ViewBuilder let content: () -> Content

    var body: some View {
        let _ = Self._printChanges()
        let _ = print("⚡ MockMaterialTabsClosureAPI maxOffset=\(context.maxOffset)")
        VStack(spacing: 0) {
            // Header goes through a bridge — closure reads are scoped to the bridge
            HeaderBridge(context: context, headerBuilder: header)
            // Content has no context dependency
            content()
                .padding(.top, context.maxOffset) // reads layout, same as DebugView
        }
    }
}

struct DebugView4: View {
    @State private var context = MockHeaderContext()

    var body: some View {
        MockMaterialTabsClosureAPI(
            header: { ctx in
                // Consumer header code — reads offset for effects
                let _ = print("⚡ Header closure offset=\(ctx.offset)")
                Text("Header offset=\(String(format: "%.0f", ctx.offset))")
                    .opacity(1.0 - Double(ctx.offset / max(ctx.maxOffset, 1)))
            },
            content: {
                ContentViewObservable()
            }
        )
        .environment(context)
        .modelContainer(for: DemoItem.self, inMemory: true)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                Task { @MainActor in context.offset += 1 }
            }
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                Task { @MainActor in context.titleHeight += 10 }
            }
        }
    }
}

// MARK: - Previews

#Preview("@Observable in environment") {
    DebugView()
}

#Preview("ObservableObject — broken") {
    DebugView2()
}

#Preview("StableContainer workaround") {
    DebugView3()
}

#Preview("@Observable via init + closure") {
    DebugView4()
}
