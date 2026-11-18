# SalesPro: Signed tab count may remain stale after viewing offers

User-reported behavior: in Pipeline, select Signed, scroll to the November 14 card, open its offers, and tap Back. Expected Signed count: 2. Reported actual: 3; scrolling the tab row or waiting can update it to 2. The developer's tab-label wrapper workaround addresses this behavior. It may be related to an earlier SUIMT update issue; the cause and relationship are unverified.

## Attempt on 2026-11-17

- SalesPro Stage `work/sp-408-409-complete-offers-impl` at `fcf73110` (build 133), SUIMT submodule `e3111322094bdeef70e37249d083e6e7ad49b785`.
- iPhone 17 Pro Simulator, iOS 26.5, existing seeded demo data. Scratch build bypasses both customer and Pipeline view-model-observing tab-label wrappers and uses a Simulator-only demo login entry.
- On Signed, the November 14 card was **Lakeview Ranch**, with an accepted offer. The Signed button's accessibility label was `Signed, 3` before opening it.
- Opened the card, verified the Lakeview Ranch offers screen, then tapped Back. The next accessibility inspection reported `Signed, 2`.
- The tool interaction and inspection took several seconds, so this does not rule out a shorter-lived stale count. The issue did not persist until the first inspection in this single attempt. No iOS 27 result or SUIMT-only reproduction has yet been established.
- On a later iOS 27.0 attempt on `SUIMT Oracle Audit iOS 27`, the user accepted the first-launch agreement and the automation agent was available. With both wrappers bypassed and fresh demo data, Signed displayed 3 before opening the November 14 Lakeview Ranch card. Immediately after returning from its accepted offer, the first accessibility inspection still reported `Signed, 3`, and a subsequent inspection also reported 3. Scrolling the horizontal tab row away and back then changed the label to `Signed, 2`. This reproduces the reported stale count and redraw behavior on iOS 27; it does not establish whether the defect belongs to SUIMT or SalesPro.
- During the subsequent SUIMT investigation, an experimental custom-label fixture did not find its updated label after returning from a detail screen, but XCTest stalled collecting the failure snapshot. The fixture did not independently verify that its source model changed, so this is inconclusive; the experiment was removed from the test plan. `TabBarModel.register` retains the initial label closure and is a lead to investigate, not a confirmed cause.

The Simulator's previously viewed demo offers and interaction history can affect the count. Use fresh demo data for any subsequent attempt; avoid clearing a user's existing store without authorization. The scratch checkout is `/tmp/skai/salespro-latest/source`; its contents are temporary. The original SalesPro checkout was not changed.
