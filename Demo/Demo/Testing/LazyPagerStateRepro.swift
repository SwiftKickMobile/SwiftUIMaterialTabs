import SwiftUI

// Standalone selection-binding diagnosis. No SUIMT models, header, navigation,
// activation callbacks, or vertical scrolling participate in this experiment.
struct PagerBindingRepro: View {
    let variant: String
    @State private var selection: Int? = 0
    @State private var writes: [String] = []

    @ViewBuilder var body: some View {
        if variant.hasPrefix("initial-") {
            InitialPageBindingRepro(variant: variant)
        } else if variant.hasPrefix("target-") {
            PerPageTargetRepro(variant: variant)
        } else if variant.hasPrefix("singleton-") || variant == "removed-static" {
            SingletonIdentityRepro(variant: variant)
        } else if variant.hasPrefix("identity-") {
            PagerIdentityRepro(variant: variant)
        } else if variant.hasPrefix("minimal") {
            MinimalEagerBindingRepro(variant: variant)
        } else {
            experimentalBody
        }
    }

    private var experimentalBody: some View {
        VStack {
            Text("\(variant) | selected=\(selection.map(String.init) ?? "nil") | writes=\(writes.joined(separator: ","))")
                .accessibilityIdentifier("pager-diagnostic")
            ScrollView(.horizontal) {
                if variant == "lazy-inner" {
                    LazyHStack(spacing: 0) { pages }
                        .scrollTargetLayout()
                } else {
                    HStack(spacing: 0) { pages }
                        .scrollTargetLayout()
                }
            }
            .scrollPosition(id: Binding(get: { selection }, set: { value in
                writes.append(value.map(String.init) ?? "nil")
                selection = value
            }), anchor: .center)
            .scrollTargetBehavior(.paging)
        }
    }

    @ViewBuilder private var pages: some View {
        ForEach(0..<3) { index in
            if variant == "direct" {
                Text("Page \(index)")
                    .frame(maxHeight: .infinity)
                    .containerRelativeFrame(.horizontal)
                    .background(index == 0 ? Color.cyan : Color.orange)
                    .id(index)
            } else if variant == "custom-outer" {
                BindingReproPage(index: index)
                    .id(index)
            } else {
                BindingReproPage(index: index)
            }
        }
    }
}

/// Launch-only control: fixed-size pages and a non-first initial scroll ID.
/// No SUIMT models, deferred content, navigation, observers, or selection writes.
private struct InitialPageBindingRepro: View {
    let variant: String
    @State private var selection: Int? = 1

    var body: some View {
        ScrollView(.horizontal) {
            if variant == "initial-lazy-explicit" {
                LazyHStack(spacing: 0) {
                    ForEach(0..<3) { index in page(index).id(index) }
                }.scrollTargetLayout()
            } else if variant == "initial-eager-implicit" {
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in page(index) }
                }.scrollTargetLayout()
            } else {
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in page(index).id(index) }
                }.scrollTargetLayout()
            }
        }
        .scrollPosition(id: $selection, anchor: .center)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }

    private func page(_ index: Int) -> some View {
        Text("Page \(index)")
            .font(.largeTitle.bold())
            .frame(maxHeight: .infinity)
            .containerRelativeFrame(.horizontal)
            .background([Color.cyan, .orange, .mint][index])
    }
}

// Register targets inside each page instead of on the caller's outer layout.
// This experiment tests whether caller ForEach IDs can then remain independent.
private struct PerPageTargetIdentity: ViewModifier {
    let index: Int
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            ForEach([index], id: \.self) { _ in ZStack { content } }
        }
        .scrollTargetLayout()
    }
}

private struct PerPageTargetRepro: View {
    let variant: String
    @State private var selection: Int? = 0
    var body: some View {
        VStack {
            Text("\(variant) | selected=\(selection ?? -1)")
                .accessibilityIdentifier("pager-diagnostic")
                .frame(height: 80)
                .contentShape(Rectangle())
                .onTapGesture { selection = selection == 2 ? 0 : 2 }
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    if variant == "target-outer" {
                        ForEach(100..<103, id: \.self) { callerID in
                            SingletonStatePage(index: callerID - 100)
                                .modifier(PerPageTargetIdentity(index: callerID - 100))
                        }
                    } else if variant == "target-matching" {
                        ForEach(0..<3, id: \.self) { index in
                            SingletonStatePage(index: index).modifier(PerPageTargetIdentity(index: index))
                        }
                    } else if variant == "target-inner-id" {
                        SingletonStatePage(index: 0).id("caller-zero").modifier(PerPageTargetIdentity(index: 0))
                        SingletonStatePage(index: 1).id("caller-one").modifier(PerPageTargetIdentity(index: 1))
                        SingletonStatePage(index: 2).id("caller-two").modifier(PerPageTargetIdentity(index: 2))
                    } else {
                        SingletonStatePage(index: 0).modifier(PerPageTargetIdentity(index: 0))
                        SingletonStatePage(index: 1).modifier(PerPageTargetIdentity(index: 1))
                        SingletonStatePage(index: 2).modifier(PerPageTargetIdentity(index: 2))
                    }
                }
            }
            .scrollPosition(id: $selection, anchor: .center)
            .scrollTargetBehavior(.paging)
        }
    }
}

// A candidate identity carrier, not a production modifier. One stable ForEach
// element replaces explicit .id; ZStack exposes a concrete layout for iOS 17.
private struct SingletonPageIdentity: ViewModifier {
    let index: Int
    func body(content: Content) -> some View {
        ForEach([index], id: \.self) { _ in
            ZStack { content }
        }
    }
}

private struct SingletonOuterPageIdentity: ViewModifier {
    let index: Int
    func body(content: Content) -> some View {
        ZStack {
            ForEach([index], id: \.self) { _ in ZStack { content } }
        }
    }
}

private struct SingletonIdentityRepro: View {
    let variant: String
    @State private var selection: Int? = 0
    var body: some View {
        VStack {
            Text("\(variant) | selected=\(selection ?? -1)")
                .accessibilityIdentifier("pager-diagnostic")
                .frame(height: 80)
                .contentShape(Rectangle())
                .onTapGesture { selection = selection == 2 ? 0 : 2 }
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    if variant == "removed-static" {
                        SingletonStatePage(index: 0)
                        SingletonStatePage(index: 1)
                        SingletonStatePage(index: 2)
                    } else if variant == "singleton-matching" {
                        ForEach(0..<3, id: \.self) { index in
                            SingletonStatePage(index: index)
                                .modifier(SingletonPageIdentity(index: index))
                        }
                    } else if variant == "singleton-outer-layout" {
                        ForEach(100..<103, id: \.self) { callerID in
                            SingletonStatePage(index: callerID - 100)
                                .modifier(SingletonOuterPageIdentity(index: callerID - 100))
                        }
                    } else if variant == "singleton-static-layout" {
                        SingletonStatePage(index: 0).modifier(SingletonOuterPageIdentity(index: 0))
                        SingletonStatePage(index: 1).modifier(SingletonOuterPageIdentity(index: 1))
                        SingletonStatePage(index: 2).modifier(SingletonOuterPageIdentity(index: 2))
                    } else if variant == "singleton-outer" {
                        ForEach(100..<103, id: \.self) { callerID in
                            SingletonStatePage(index: callerID - 100)
                                .modifier(SingletonPageIdentity(index: callerID - 100))
                        }
                    } else if variant == "singleton-inner-id" {
                        SingletonStatePage(index: 0).id("caller-zero")
                            .modifier(SingletonPageIdentity(index: 0))
                        SingletonStatePage(index: 1).id("caller-one")
                            .modifier(SingletonPageIdentity(index: 1))
                        SingletonStatePage(index: 2).id("caller-two")
                            .modifier(SingletonPageIdentity(index: 2))
                    } else {
                        SingletonStatePage(index: 0).modifier(SingletonPageIdentity(index: 0))
                        SingletonStatePage(index: 1).modifier(SingletonPageIdentity(index: 1))
                        SingletonStatePage(index: 2).modifier(SingletonPageIdentity(index: 2))
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $selection, anchor: .center)
            .scrollTargetBehavior(.paging)
        }
    }
}

private struct SingletonStatePage: View {
    let index: Int
    @State private var count = 0
    @State private var token = UUID()
    var body: some View {
        Text("Page \(index) | count=\(count) | token=\(token)")
            .accessibilityIdentifier("singleton-page-\(index)")
            .frame(maxHeight: .infinity)
            .containerRelativeFrame(.horizontal)
            .background(index == 0 ? Color.cyan : Color.orange)
            .contentShape(Rectangle())
            .onTapGesture { count += 1 }
    }
}

// Controlled comparison: both cases use the same ForEach identity. The only
// difference inside the page is the redundant explicit .id(index) modifier.
private struct PagerIdentityRepro: View {
    let variant: String
    @State private var selection: Int? = 0

    var body: some View {
        VStack {
            Text("\(variant) | selected=\(selection ?? -1)")
                .accessibilityIdentifier("pager-diagnostic")
                .frame(height: 80)
            ScrollView(.horizontal) {
                if variant == "identity-explicit" {
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { index in
                            Text("Page \(index)")
                                .frame(maxHeight: .infinity)
                                .containerRelativeFrame(.horizontal)
                                .background(index == 0 ? Color.cyan : Color.orange)
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                } else {
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { index in
                            Text("Page \(index)")
                                .frame(maxHeight: .infinity)
                                .containerRelativeFrame(.horizontal)
                                .background(index == 0 ? Color.cyan : Color.orange)
                        }
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollPosition(id: $selection, anchor: .center)
            .scrollTargetBehavior(.paging)
        }
    }
}

// Deliberately no conditional content, custom page views, or deferred loading.
private struct MinimalEagerBindingRepro: View {
    let variant: String
    @State private var selection: Int? = 0
    @State private var writes: [String] = []
    var body: some View {
        VStack {
            Text("\(variant) | selected=\(selection.map(String.init) ?? "nil") | writes=\(writes.joined(separator: ","))")
                .accessibilityIdentifier("pager-diagnostic")
                .frame(height: 80)
                .contentShape(Rectangle())
                .onTapGesture { if variant == "minimal-jump" { selection = 2 } }
            if variant == "minimal-aligned" {
                scroller.scrollTargetBehavior(.viewAligned)
            } else {
                scroller.scrollTargetBehavior(.paging)
            }
        }
    }

    private var scroller: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<3) { index in
                    Text("Page \(index)")
                        .frame(maxHeight: .infinity)
                        .containerRelativeFrame(.horizontal)
                        .background(index == 0 ? Color.cyan : Color.orange)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: variant == "minimal" ? Binding(get: { selection }, set: { value in
            writes.append(value.map(String.init) ?? "nil")
            selection = value
        }) : $selection, anchor: variant == "minimal-noanchor" ? nil : .center)
    }
}

private struct BindingReproPage: View {
    let index: Int
    var body: some View {
        Text("Page \(index)")
            .frame(maxHeight: .infinity)
            .containerRelativeFrame(.horizontal)
            .background(index == 0 ? Color.cyan : Color.orange)
            .id(index)
    }
}

@available(iOS 18.0, *)
struct LazyPagerStateRepro: View {
    @State private var selection: Int? = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack {
            HStack {
                Button("A") { selection = 0 }
                Button("B") { selection = 1 }
            }
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<2) { index in
                        ScrollView {
                            Page(offset: offset)
                        }
                        .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, value in
                            offset = value
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $selection, anchor: .center)
            .scrollTargetBehavior(.paging)
        }
    }

    private struct Page: View {
        let offset: CGFloat
        @State private var count = 0

        var body: some View {
            VStack {
                Button("Count: \(count)") { count += 1 }
                Text("\(offset)")
                Spacer().frame(height: 1500)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
