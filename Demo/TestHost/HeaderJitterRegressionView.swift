import SwiftUI
import Combine
import UIKit
import SwiftUIMaterialTabs

// Samples the presented tab-bar position while a selection transition is in flight.
@MainActor private final class HeaderMotionMeter: ObservableObject {
    @Published var result = "Motion pending"
    var latest: CGFloat?
    private var baseline: CGFloat?
    private var maximum: CGFloat = 0
    private var samples = 0

    func sample(_ y: CGFloat) {
        latest = y
        guard let baseline else { return }
        samples += 1
        maximum = max(maximum, abs(y - baseline))
    }

    func start() {
        baseline = latest
        maximum = 0
        samples = 0
        result = "Motion recording"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            result = "Motion \(maximum) samples \(samples)"
            baseline = nil
        }
    }
}

private struct HeaderPresentationProbe: UIViewRepresentable {
    let meter: HeaderMotionMeter
    func makeUIView(context: Context) -> Probe {
        let view = Probe()
        view.meter = meter
        return view
    }
    func updateUIView(_ view: Probe, context: Context) { view.meter = meter }
    final class Probe: UIView {
        weak var meter: HeaderMotionMeter?
        private var displayLink: CADisplayLink?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            displayLink?.invalidate()
            guard window != nil else { return }
            let link = CADisplayLink(target: self, selector: #selector(tick))
            link.add(to: .main, forMode: .common)
            displayLink = link
        }
        @objc private func tick() {
            guard let window else { return }
            let source = layer.presentation() ?? layer
            let destination = window.layer.presentation() ?? window.layer
            meter?.sample(source.convert(.zero, to: destination).y)
        }
    }
}

struct JitterRegressionView: View {
    private enum Tab: Hashable { case appointment, offers }
    @State private var selected: Tab = .appointment
    @State private var position = ScrollPosition()
    @State private var anchor: UnitPoint?
    @StateObject private var meter = HeaderMotionMeter()

    var body: some View {
        NavigationStack {
            MaterialTabs(selectedTab: $selected, headerTitle: { _ in
                Text("Customer header").frame(maxWidth: .infinity).frame(height: 180)
            }, headerTabBar: { context in
                MaterialTabBar(selectedTab: $selected, sizing: .equalWidth, context: context)
                    .background(HeaderPresentationProbe(meter: meter).allowsHitTesting(false))
            }, content: {
                MaterialTabsScroll(tab: Tab.appointment, scrollPosition: $position, anchor: $anchor) { _ in
                    LazyVStack {
                        ForEach(0..<30) { row in
                            Text("Appointment row \(row)").frame(maxWidth: .infinity).frame(height: 100).id(row)
                        }
                    }.scrollTargetLayout()
                }
                .safeAreaPadding(.bottom, 35)
                .materialTabItem(tab: Tab.appointment) { _, _, tapped in
                    Button("Appointment") { meter.start(); tapped() }
                }
                MaterialTabsScroll(tab: Tab.offers) { context in
                    Text("No offers")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(0, context.safeHeight - context.headerContext.maxOffset - 60))
                        .padding(.vertical, 30)
                }
                .materialTabItem(tab: Tab.offers) { _, _, tapped in
                    Button("Offers", action: tapped)
                }
            })
            .overlay(alignment: .bottom) { Text(meter.result).accessibilityIdentifier("motionResult") }
            .navigationTitle("Customer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
