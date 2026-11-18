# SalesPro: appointment scroll moves on tab switches

Observed 2026-11-17 on an iPhone 17 Pro Simulator running iOS 26.5, using SalesPro Stage in demo mode. SalesPro was built from `work/sp-408-409-complete-offers-impl` at `fcf73110` (build 133); its SwiftUIMaterialTabs submodule was `e3111322094bdeef70e37249d083e6e7ad49b785`. This is not necessarily the current checkout of this repository.

The remote revision removes the customer screen's custom pull-to-refresh and fixed-on-pull header style. A Simulator-only debug launch flag in the scratch build bypassed Salesforce login and enabled the existing demo store. The original SalesPro checkout was not modified.

## Steps

1. Open the New Nancy appointment from Pipeline, without scrolling.
2. Tap Offers, then Appointment.
3. Repeat the round trip.

Expected: the appointment scroll position stays unchanged. Actual: the content and shared header move upward, indicating the appointment scroll advances on each round trip.

## Measurements

Accessibility frames in points on a 402 × 874-point screen, taken after each return to Appointment:

| Round trips | Appointment tab top | Sales Presentation button top |
| ---: | ---: | ---: |
| 0 | 320 | 397 |
| 1 | 309 | 386 |
| 2 | 298 | 375 |
| 3 | 289 | 366 |
| 4 | 280 | 357 |
| 5 | 271 | 348 |

The table is from the scratch build with both customer and Pipeline view-model-observing tab-label wrappers bypassed. The latest remote build with those wrappers intact also reproduced the movement: the tab top moved from 320 to 263 after six valid round trips. Thus the observation does not depend on bypassing the wrappers. These are UI accessibility frame measurements, not direct scroll-offset measurements.

## Follow-up: viewport height

On iOS 27, removing the Appointment scroll's `.safeAreaPadding(.bottom, 35)` in a scratch-only experiment stopped the drift for four round trips. The matching SUIMT-only padded-scroll UI test failed on the original implementation: after three round trips the tab top was 281.26 points instead of 304. The test host reported a 643-point scroll viewport while the anchor calculation used the parent-derived 678 points. Using the scroll's actual `ScrollGeometry.containerSize.height` for the anchor calculation made the focused test pass. In SalesPro, with its original 35-point padding restored and this SUIMT change applied, the tab top stayed at 320 and the Sales Presentation row at 397 across four round trips.

The partial-collapse jitter remains observable with this change; it must not be treated as fixed by the viewport correction.

Scratch checkout: `/tmp/skai/salespro-latest/source`. Build output: `/tmp/skai/salespro-latest/both-bypass-build-output.txt`. The dedicated Simulator is named `SalesPro SUIMT Investigation`. The scratch checkout and `/tmp` evidence are temporary; the original SalesPro working tree contains pre-existing changes and was left intact.
