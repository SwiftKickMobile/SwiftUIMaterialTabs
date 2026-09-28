#if DEBUG
import UIKit
@_spi(Testing) import SwiftUIMaterialTabs

/// Debug-only context and actual-position observation without adding a view.
/// Uses passive UIUpdateLink callbacks on 26+, explicitly labeled display ticks
/// on older runtimes. No accessibility queries, layout or scroll commands.
@MainActor
enum NativeScrollSnapshot {
    static let isEnabled = ProcessInfo.processInfo.environment["SUIMT_BOUNDARY_TRACE"] == "1"
    static let capturesNativeScrolls = ProcessInfo.processInfo.environment["SUIMT_NATIVE_SCROLL_PROBE"] == "1"

    struct Scroll: Codable {
        let id: String
        let frameX: Double
        let frameY: Double
        let frameWidth: Double
        let frameHeight: Double
        let boundsWidth: Double
        let boundsHeight: Double
        let contentWidth: Double
        let contentHeight: Double
        let offsetY: Double
        let offsetX: Double
        let insetTop: Double
        let insetBottom: Double
        let insetLeft: Double
        let insetRight: Double
        let scrollEnabled: Bool
        let panState: Int
        let panTranslationX: Double
        let panTranslationY: Double
        let normalizedOffset: Double
        let presentationOffset: Double?
        let tracking: Bool
        let dragging: Bool
        let decelerating: Bool
    }

    struct Sample: Codable {
        let uptime: Double
        let phase: String
        let windowWidth: Double
        let windowHeight: Double
        let scrolls: [Scroll]
        let parkedScrolls: [Scroll]
    }

    private(set) static var samples: [Sample] = []
    private(set) static var overflow = false
    private static weak var observedWindow: UIWindow?
    private static var stopObserver: (() -> Void)?
    // Only the flick fixture needs to observe motion after a lazy page detaches.
    // Weak membership must not keep a page or its content lifecycle alive.
    private static let knownScrolls = NSHashTable<UIScrollView>.weakObjects()
    private static let followsDepartedScrolls = ProcessInfo.processInfo.environment["SUIMT_FLICK_FIXTURE"] == "1"

    static var contextSampling: String {
        if #available(iOS 26.0, *) { return "UIUpdateLink.afterUpdateComplete" }
        return "CADisplayLink.callback"
    }

    static func observe(_ window: UIWindow) {
        guard isEnabled, observedWindow !== window, let scene = window.windowScene else { return }
        stopObserver?()
        observedWindow = window
        if #available(iOS 26.0, *) {
        let observer = UIUpdateLink(windowScene: scene)
        observer.addAction(to: .afterUpdateComplete) { [weak window] _, info in
            MaterialTabsTrace.updateCompleted(modelTime: info.modelTime,
                                             completionDeadline: info.completionDeadlineTime,
                                             estimatedPresentationTime: info.estimatedPresentationTime)
            guard let window else { return }
            if capturesNativeScrolls { capture(window, phase: "afterUpdateComplete") }
        }
        // Passive defaults: do not request continuous updates or change latency.
        observer.isEnabled = true
        stopObserver = { observer.isEnabled = false }
        } else {
            let target = DisplayObserver(window: window)
            let observer = CADisplayLink(target: target, selector: #selector(DisplayObserver.tick(_:)))
            observer.add(to: .main, forMode: .common)
            stopObserver = { observer.invalidate() }
        }
        if capturesNativeScrolls { capture(window, phase: "observerAttached") }
    }

    @MainActor private final class DisplayObserver: NSObject {
        weak var window: UIWindow?
        init(window: UIWindow) { self.window = window }
        @objc func tick(_ link: CADisplayLink) {
            MaterialTabsTrace.displaySampled(timestamp: link.timestamp, targetTimestamp: link.targetTimestamp)
            if let window, capturesNativeScrolls { capture(window, phase: "CADisplayLink.callback") }
        }
    }

    static func captureForExport() {
        guard isEnabled, capturesNativeScrolls, let window = observedWindow else { return }
        capture(window, phase: "export")
    }

    private static func capture(_ window: UIWindow, phase: String) {
        guard samples.count < 10_000 else { overflow = true; return }
        var scrolls: [Scroll] = []
        var visited = Set<ObjectIdentifier>()
        func snapshot(_ scroll: UIScrollView) -> Scroll {
            let frame = scroll.convert(scroll.bounds, to: window)
            let inset = scroll.adjustedContentInset.top
            return Scroll(
                id: String(describing: ObjectIdentifier(scroll)),
                frameX: frame.minX, frameY: frame.minY,
                frameWidth: frame.width, frameHeight: frame.height,
                boundsWidth: scroll.bounds.width, boundsHeight: scroll.bounds.height,
                contentWidth: scroll.contentSize.width, contentHeight: scroll.contentSize.height,
                offsetY: scroll.contentOffset.y, offsetX: scroll.contentOffset.x, insetTop: inset,
                insetBottom: scroll.adjustedContentInset.bottom,
                insetLeft: scroll.adjustedContentInset.left,
                insetRight: scroll.adjustedContentInset.right,
                scrollEnabled: scroll.isScrollEnabled,
                panState: scroll.panGestureRecognizer.state.rawValue,
                panTranslationX: scroll.panGestureRecognizer.translation(in: scroll).x,
                panTranslationY: scroll.panGestureRecognizer.translation(in: scroll).y,
                normalizedOffset: scroll.contentOffset.y + inset,
                presentationOffset: scroll.layer.presentation().map { $0.bounds.origin.y + inset },
                tracking: scroll.isTracking, dragging: scroll.isDragging,
                decelerating: scroll.isDecelerating)
        }
        func visit(_ view: UIView) {
            guard !view.isHidden, view.alpha > 0.001 else { return }
            if let scroll = view as? UIScrollView {
                let frame = scroll.convert(scroll.bounds, to: window)
                // Keep all full-size candidates, including offscreen pages and
                // the horizontal pager. The checker must prove a unique visible
                // vertical candidate; it may not just take the last scroll view.
                if frame.width > window.bounds.width * 0.8,
                   frame.height > window.bounds.height * 0.5 {
                    visited.insert(ObjectIdentifier(scroll))
                    if followsDepartedScrolls { knownScrolls.add(scroll) }
                    scrolls.append(snapshot(scroll))
                }
            }
            for child in view.subviews { visit(child) }
        }
        visit(window)
        let parked = followsDepartedScrolls ? knownScrolls.allObjects
            .filter { !visited.contains(ObjectIdentifier($0)) }.map(snapshot) : []
        samples.append(Sample(uptime: ProcessInfo.processInfo.systemUptime, phase: phase,
                              windowWidth: window.bounds.width, windowHeight: window.bounds.height,
                              scrolls: scrolls, parkedScrolls: parked))
    }
}
#endif
