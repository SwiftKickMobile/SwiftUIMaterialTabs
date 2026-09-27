#if DEBUG
import SwiftUI
import UIKit
@_spi(Testing) import SwiftUIMaterialTabs

/// Test harness only. Observes natural UI updates without requesting additional
/// frames, changing latency policy, or flushing Core Animation transactions.
@available(iOS 18.0, *)
struct ContextUpdateBoundaryObserver: UIViewRepresentable {
    final class ObserverView: UIView {
        private var updateLink: UIUpdateLink?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            stop()
            guard window != nil else { return }
            let link = UIUpdateLink(view: self)
            link.addAction(to: .afterUpdateComplete) { _, info in
                MaterialTabsTrace.updateCompleted(
                    modelTime: info.modelTime,
                    completionDeadline: info.completionDeadlineTime,
                    estimatedPresentationTime: info.estimatedPresentationTime)
            }
            // Leave requiresContinuousUpdates and all latency/frame-rate settings
            // at their passive defaults. Merely enable observation.
            link.isEnabled = true
            updateLink = link
        }

        func stop() {
            updateLink?.isEnabled = false
            updateLink = nil
        }
    }

    func makeUIView(context: Context) -> ObserverView {
        let view = ObserverView()
        view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: ObserverView, context: Context) {}

    static func dismantleUIView(_ uiView: ObserverView, coordinator: ()) {
        uiView.stop()
    }
}
#endif
