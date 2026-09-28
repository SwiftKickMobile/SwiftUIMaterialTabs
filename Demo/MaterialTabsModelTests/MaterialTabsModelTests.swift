import Foundation
import XCTest
@testable import SwiftUIMaterialTabs
import SwiftUI

/// Compiled with the actual production model source files (not reimplementations).
/// No app, Simulator, accessibility query, or render loop is involved.
@MainActor
struct ScrollLifecycleChecks {
    struct Failure: Error, CustomStringConvertible {
        let description: String
    }

    static func equal(_ actual: CGFloat, _ expected: CGFloat, _ message: String) throws {
        if abs(actual - expected) > 0.0001 {
            throw Failure(description: "\(message): expected \(expected), got \(actual)")
        }
    }

    static func header(selected: Int, mode: MaterialTabsConfig.CrossTabSyncMode) async throws -> HeaderModel<Int> {
        let header = HeaderModel<Int>(selectedTab: selected)
        header.configChanged(.init(crossTabSyncMode: mode))
        header.titleHeightChanged(150)
        header.tabBarHeightChanged(46)
        header.sizeChanged(CGSize(width: 402, height: 874))
        header.onTabsRegistered()
        for _ in 0..<100 {
            if header.tabsRegistered { return header }
            await Task.yield()
        }
        throw Failure(description: "Registration fixture did not initialize")
    }

    static func coldReturn(mode: MaterialTabsConfig.CrossTabSyncMode, collapse: CGFloat) async throws {
        let header = try await header(selected: 1, mode: mode)
        let incoming = ScrollModel<Int>(tab: 0)
        incoming.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        incoming.disappeared()
        header.scrolled(tab: 1, contentOffset: collapse, deltaContentOffset: collapse)
        try equal(header.headerContext.offset, collapse, "Setup header")
        header.selected(tab: 0)
        incoming.selectedTabChanged()
        incoming.contentOffsetChanged(0) // Captured ordering: geometry BEFORE appearance.
        try equal(header.headerContext.offset, collapse, "Pre-appearance callback moved header")
        incoming.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try equal(header.headerContext.offset, collapse, "Appearance moved header")
        try equal(incoming.contentOffset, collapse, "Incoming content did not align")
    }

    static func scrolledReturn(mode: MaterialTabsConfig.CrossTabSyncMode, resets: Bool,
                               firstUserScrollHeader: CGFloat) async throws {
        let header = try await header(selected: 0, mode: mode)
        let page = ScrollModel<Int>(tab: 0)
        page.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        page.contentOffsetChanged(-500)
        page.contentOffsetChanged(-500)
        try equal(header.headerContext.offset, 150, "Scrolled setup")
        header.selected(tab: 1)
        page.selectedTabChanged()
        page.disappeared()
        header.scrolled(tab: 1, contentOffset: 0, deltaContentOffset: -150)
        try equal(header.headerContext.offset, 0, "Expanded other tab")
        header.selected(tab: 0)
        page.selectedTabChanged()
        page.contentOffsetChanged(-500)
        try equal(header.headerContext.offset, 0, "Returning page collapsed header prematurely")
        page.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        let restored: CGFloat = resets ? 0 : 350
        try equal(page.contentOffset, restored, "Restored content")
        try equal(header.headerContext.offset, 0, "Return header")
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        page.contentOffsetChanged(-(restored + 20))
        try equal(header.headerContext.offset, firstUserScrollHeader, "Visible user scrolling was suppressed")
    }

    static func inactiveDecelerationRemainsAvailable() async throws {
        let header = try await header(selected: 0, mode: .preserveScrollPosition)
        let page = ScrollModel<Int>(tab: 0)
        page.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        page.contentOffsetChanged(-500)
        header.selected(tab: 1)
        page.selectedTabChanged()
        page.disappeared()
        header.scrolled(tab: 1, contentOffset: 0, deltaContentOffset: -150)
        page.contentOffsetChanged(-480)
        // The unselected page can still finish decelerating. This is different
        // from initial layout arriving after it has been selected for return.
        try equal(page.contentOffset, 480, "Unselected page's final position was discarded")
        try equal(header.headerContext.offset, 0, "Inactive page moved shared header")
        header.selected(tab: 0)
        page.selectedTabChanged()
        page.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try equal(page.contentOffset, 330, "Final parked position was not preserved")
    }

    static func returningInitialGeometry(mode: MaterialTabsConfig.CrossTabSyncMode, collapse: CGFloat,
                                         measured: CGFloat, resets: Bool) async throws {
        let header = try await header(selected: 0, mode: mode)
        let page = ScrollModel<Int>(tab: 0)
        page.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        page.contentOffsetChanged(-213)
        page.contentOffsetChanged(-213)
        header.selected(tab: 1)
        page.selectedTabChanged()
        page.disappeared()
        header.scrolled(tab: 1, contentOffset: collapse, deltaContentOffset: collapse - 150)
        header.selected(tab: 0)
        page.selectedTabChanged()
        page.contentOffsetChanged(-measured)
        try equal(header.headerContext.offset, collapse, "Early geometry moved header")
        page.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        let expected = resets && collapse < 150 ? collapse : 63 + collapse
        try equal(page.contentOffset, expected, "Early geometry erased remembered relative position")
        try equal(header.headerContext.offset, collapse, "Returning content moved header")
    }

    static func retainedPage(mode: MaterialTabsConfig.CrossTabSyncMode, collapse: CGFloat,
                              resets: Bool) async throws {
        let header = try await header(selected: 0, mode: mode)
        let original = ScrollModel<Int>(tab: 0)
        original.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        original.contentOffsetChanged(-426)
        original.contentOffsetChanged(-426)
        header.selected(tab: 1)
        original.selectedTabChanged()
        original.disappeared()
        header.scrolled(tab: 1, contentOffset: collapse, deltaContentOffset: collapse - 150)
        header.selected(tab: 0)
        // The view-level identity checks enforce retention. Here we verify
        // activation of that SAME model after another tab changed the header.
        original.selectedTabChanged()
        original.contentOffsetChanged(0)
        original.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        let expected = resets && collapse < 150 ? collapse : 276 + collapse
        try equal(original.contentOffset, expected, "Retained page lost its relative position")
        try equal(header.headerContext.offset, collapse, "Retained page moved shared header")
    }

    static func incomingPageCannotOverwriteSelectedContext() async throws {
        let header = try await header(selected: 0, mode: .preserveScrollPosition)
        let page = ScrollModel<Int>(tab: 0)
        page.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        page.contentOffsetChanged(-426)
        let incoming = ScrollModel<Int>(tab: 1)
        incoming.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try equal(incoming.contentOffset, 150, "Incoming page did not synchronize its own position")
        try equal(header.headerContext.contentOffset, 426, "Incoming page overwrote selected context")
    }

    static func inactivePageCannotOverwriteSelectedContext() async throws {
        let header = try await header(selected: 0, mode: .preserveScrollPosition)
        let old = ScrollModel<Int>(tab: 0)
        old.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        old.contentOffsetChanged(-426)
        header.selected(tab: 1)
        old.selectedTabChanged()
        old.disappeared()
        let next = ScrollModel<Int>(tab: 1)
        next.appeared(headerModel: header, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        old.contentOffsetChanged(-900) // A departing page can still decelerate.
        try equal(old.contentOffset, 900, "Inactive page lost its latest position")
        try equal(header.headerContext.contentOffset, 150, "Inactive page overwrote selected context")
    }

    static func newContainerStartsFresh() async throws {
        let first = try await header(selected: 0, mode: .preserveScrollPosition)
        let page = ScrollModel<Int>(tab: 0)
        page.appeared(headerModel: first, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try await Task.sleep(for: .milliseconds(60)) // Let the internal sync suppression finish.
        page.contentOffsetChanged(-426)
        let second = try await header(selected: 0, mode: .preserveScrollPosition)
        let fresh = ScrollModel<Int>(tab: 0)
        fresh.appeared(headerModel: second, scrollPositionBinding: .constant(ScrollPosition()), anchorBinding: .constant(nil))
        try equal(fresh.contentOffset, 0, "Position leaked across MaterialTabs containers")
    }

}
final class MaterialTabsModelTests: XCTestCase {
    @MainActor func testColdReturnResetTitle0() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .resetTitleOnScroll(), collapse: 0) }
    @MainActor func testRetainedPageResetTitle0() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .resetTitleOnScroll(), collapse: 0, resets: false) }
    @MainActor func testInitialGeometryResetTitle0Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 0, measured: 0, resets: false) }
    @MainActor func testInitialGeometryResetTitle0Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 0, measured: 20, resets: false) }
    @MainActor func testInitialGeometryResetTitle0Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 0, measured: 213, resets: false) }
    @MainActor func testColdReturnResetTitle70() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .resetTitleOnScroll(), collapse: 70) }
    @MainActor func testRetainedPageResetTitle70() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .resetTitleOnScroll(), collapse: 70, resets: false) }
    @MainActor func testInitialGeometryResetTitle70Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 70, measured: 0, resets: false) }
    @MainActor func testInitialGeometryResetTitle70Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 70, measured: 20, resets: false) }
    @MainActor func testInitialGeometryResetTitle70Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 70, measured: 213, resets: false) }
    @MainActor func testColdReturnResetTitle150() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .resetTitleOnScroll(), collapse: 150) }
    @MainActor func testRetainedPageResetTitle150() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .resetTitleOnScroll(), collapse: 150, resets: false) }
    @MainActor func testInitialGeometryResetTitle150Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 150, measured: 0, resets: false) }
    @MainActor func testInitialGeometryResetTitle150Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 150, measured: 20, resets: false) }
    @MainActor func testInitialGeometryResetTitle150Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetTitleOnScroll(), collapse: 150, measured: 213, resets: false) }
    @MainActor func testScrolledReturnResetTitle() async throws { try await ScrollLifecycleChecks.scrolledReturn(mode: .resetTitleOnScroll(), resets: false, firstUserScrollHeader: 150) }
    @MainActor func testColdReturnPreserve0() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .preserveScrollPosition, collapse: 0) }
    @MainActor func testRetainedPagePreserve0() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .preserveScrollPosition, collapse: 0, resets: false) }
    @MainActor func testInitialGeometryPreserve0Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 0, measured: 0, resets: false) }
    @MainActor func testInitialGeometryPreserve0Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 0, measured: 20, resets: false) }
    @MainActor func testInitialGeometryPreserve0Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 0, measured: 213, resets: false) }
    @MainActor func testColdReturnPreserve70() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .preserveScrollPosition, collapse: 70) }
    @MainActor func testRetainedPagePreserve70() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .preserveScrollPosition, collapse: 70, resets: false) }
    @MainActor func testInitialGeometryPreserve70Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 70, measured: 0, resets: false) }
    @MainActor func testInitialGeometryPreserve70Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 70, measured: 20, resets: false) }
    @MainActor func testInitialGeometryPreserve70Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 70, measured: 213, resets: false) }
    @MainActor func testColdReturnPreserve150() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .preserveScrollPosition, collapse: 150) }
    @MainActor func testRetainedPagePreserve150() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .preserveScrollPosition, collapse: 150, resets: false) }
    @MainActor func testInitialGeometryPreserve150Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 150, measured: 0, resets: false) }
    @MainActor func testInitialGeometryPreserve150Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 150, measured: 20, resets: false) }
    @MainActor func testInitialGeometryPreserve150Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .preserveScrollPosition, collapse: 150, measured: 213, resets: false) }
    @MainActor func testScrolledReturnPreserve() async throws { try await ScrollLifecycleChecks.scrolledReturn(mode: .preserveScrollPosition, resets: false, firstUserScrollHeader: 20) }
    @MainActor func testColdReturnResetPosition0() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .resetScrollPosition, collapse: 0) }
    @MainActor func testRetainedPageResetPosition0() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .resetScrollPosition, collapse: 0, resets: true) }
    @MainActor func testInitialGeometryResetPosition0Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 0, measured: 0, resets: true) }
    @MainActor func testInitialGeometryResetPosition0Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 0, measured: 20, resets: true) }
    @MainActor func testInitialGeometryResetPosition0Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 0, measured: 213, resets: true) }
    @MainActor func testColdReturnResetPosition70() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .resetScrollPosition, collapse: 70) }
    @MainActor func testRetainedPageResetPosition70() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .resetScrollPosition, collapse: 70, resets: true) }
    @MainActor func testInitialGeometryResetPosition70Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 70, measured: 0, resets: true) }
    @MainActor func testInitialGeometryResetPosition70Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 70, measured: 20, resets: true) }
    @MainActor func testInitialGeometryResetPosition70Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 70, measured: 213, resets: true) }
    @MainActor func testColdReturnResetPosition150() async throws { try await ScrollLifecycleChecks.coldReturn(mode: .resetScrollPosition, collapse: 150) }
    @MainActor func testRetainedPageResetPosition150() async throws { try await ScrollLifecycleChecks.retainedPage(mode: .resetScrollPosition, collapse: 150, resets: true) }
    @MainActor func testInitialGeometryResetPosition150Measured0() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 150, measured: 0, resets: true) }
    @MainActor func testInitialGeometryResetPosition150Measured20() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 150, measured: 20, resets: true) }
    @MainActor func testInitialGeometryResetPosition150Measured213() async throws { try await ScrollLifecycleChecks.returningInitialGeometry(mode: .resetScrollPosition, collapse: 150, measured: 213, resets: true) }
    @MainActor func testScrolledReturnResetPosition() async throws { try await ScrollLifecycleChecks.scrolledReturn(mode: .resetScrollPosition, resets: true, firstUserScrollHeader: 20) }
    @MainActor func testInactiveDecelerationRemainsAvailable() async throws { try await ScrollLifecycleChecks.inactiveDecelerationRemainsAvailable() }
    @MainActor func testIncomingPageCannotOverwriteSelectedContext() async throws { try await ScrollLifecycleChecks.incomingPageCannotOverwriteSelectedContext() }
    @MainActor func testInactivePageCannotOverwriteSelectedContext() async throws { try await ScrollLifecycleChecks.inactivePageCannotOverwriteSelectedContext() }
    @MainActor func testNewContainerStartsFresh() async throws { try await ScrollLifecycleChecks.newContainerStartsFresh() }
}
