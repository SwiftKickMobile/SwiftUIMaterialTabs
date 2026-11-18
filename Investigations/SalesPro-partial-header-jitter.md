# SalesPro: header jitters when switching from Offers to Appointment

Reproduced 2026-11-17 on iOS 27.0, iPhone 18 Pro Simulator (`SUIMT Oracle Audit iOS 27`). SalesPro Stage came from `work/sp-408-409-complete-offers-impl` at `fcf73110` (build 133), with SwiftUIMaterialTabs submodule `e3111322094bdeef70e37249d083e6e7ad49b785`. The scratch build bypasses both view-model-observing tab-label wrappers and uses a Simulator-only demo login entry. The latest branch has removed the custom customer pull-to-refresh. The original SalesPro checkout was not modified.

## Steps

1. Open New Nancy's appointment.
2. Tap Offers.
3. Scroll the Offers page upward until the header is partially collapsed. In this run the Appointment tab top was approximately y=240 points, versus y=320 expanded and approximately y=140 collapsed.
4. Tap Appointment.

Expected: the header remains stationary during the switch. Actual: the header visibly jumps upward and then partially returns. Its settled tab top was approximately y=233 points.

## Evidence and measurement

Simulator screen video: `/tmp/skai/salespro-latest/header-jitter-ios27.mp4` (temporary). Extracted frames around the switch are in the same directory. A pixel scan of the left tab button's background at approximately 30 samples/second measured its top at 720 pixels (240 points at 3×), then approximately 662 pixels (221 points), followed by 701 pixels (234 points) at rest. The transient is therefore approximately 19 points upward followed by a 13-point return. These are screen-pixel estimates from one recording; animation and thresholding can affect exact values. The before/after accessibility frames independently measured approximately 240 and 233 points but cannot capture the transient.

The video establishes visible movement during the tab switch, not its cause. It is not yet a SUIMT-only reproduction or a regression test. Compare with the separately documented cumulative drift: `SalesPro-tab-switch-scroll.md`.

After the viewport-height correction for cumulative drift, a second SalesPro recording still showed a brief upward displacement and return during the switch. The settled accessibility position was 240 points before and after, but stable endpoints do not establish that the transient jitter was fixed. The second recording is `/tmp/skai/salespro-latest/header-after-fix.mp4` (temporary).

## SUIMT reproduction and correction

On 2026-11-18, the `HeaderJitterUITests` test reproduced the problem in an isolated SUIMT test host on iOS 27. With the Offers page partially collapsed, the tab-bar presentation-layer probe measured approximately 22.4 points of movement when tapping Appointment. The test uses display-link samples throughout the switch and verifies that the header is partially collapsed and that sampling actually occurred; it does not rely only on settled accessibility frames.

SUIMT's existing context trace showed the destination page's internal alignment animating across multiple frames. Its 50 ms synchronization guard expired before that animation completed, so subsequent programmatic position changes were processed as user scrolling and moved the header. Disabling animation only for the internal anchor and scroll-position mutations removed the reproduced motion; the targeted jitter and safe-area-padding tests passed together.

The Core test plan passed on iOS 27 after both changes. The SalesPro scratch build with both SUIMT changes, both label wrappers bypassed, and its normal bottom padding also showed a stable header through the partial-collapse switch: an accessibility check remained at y=250 points, and 30 Hz samples of the recorded tab-row boundary remained at 750 pixels (3×). The latter is a single real-app check, not proof of every jitter scenario. Recording: `/tmp/skai/salespro-latest/header-transaction-fix.mp4` (temporary). The stale Signed-count issue remains separate and unresolved.
