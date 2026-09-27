# 2.1.0 verification record

## Current Xcode validation

- Shared scheme: MaterialTabs Tests; plans: Core and Extended.
- Core passed on iOS 27: 11 UI scenarios, 52 model tests, and 102 validator/catalog
  checks. All 15 screenshots were inspected. Result: `/tmp/suimt-core-xctest-27.xcresult`.
- Extended's first attempt stopped after 30 UI passes at
  `testMatrixColdSwipe12CollapsedOff`. The four saved screenshots showed the
  first swipe still in progress when the next input began. Both the old and
  Swift validators rejected the same recording; this was not a port discrepancy.
  Result: `/tmp/suimt-extended-xctest-27.xcresult`.
- Ten isolated repeats passed before the sequencing fix; all 40 screenshots were
  inspected. Result: `/tmp/suimt-coldswipe27-repeat10.xcresult`.
- The driver now waits for native horizontal tracking/dragging/deceleration to
  stop after a planned swipe. It requires fresh passive evidence and has a
  bounded timeout. It never waits for the expected tab or offset, issues an
  accessibility query, or discards context samples. Position assertions are
  unchanged. Vertical flick scenarios do not use this horizontal wait.
- Ten post-fix repeats and the three new readiness controls passed; all 40
  screenshots were inspected. Result: `/tmp/suimt-pager-readiness27.xcresult`.
- The full Extended rerun passed: **102 UI scenarios, 0 failures, 0 skips**.
  Its 52 model tests, 102 validator/catalog checks, and 3 readiness controls also
  passed (259 XCTest results total). Log: `/tmp/suimt-extended-xctest-27-v2.log`;
  result: `/tmp/suimt-extended-xctest-27-v2.xcresult`.
- All 681 saved screenshot checkpoints were inspected in
  `/tmp/suimt-extended27-compact-review/` (57 contact sheets). Original images and
  traces remain in the result bundle and exported attachments. This checks saved
  states, not every presented animation frame. The audit Simulator was shut down.

The public scroll-edge modifier now handles availability internally, with a
false environment value before iOS 26. Its iOS 26/27 value and modified-view type
are unchanged. The unguarded-call compile check passed with an iOS 17 deployment
target, including both default-enabled and explicitly disabled calls. The
post-cleanup, from-scratch Extended test build also passed with signing disabled:
`/tmp/suimt-release21-clean-build.log`. This build includes the simplified public
modifier and reorganized files; it is not an additional older-OS runtime run.

| iOS | Pending | Passed | Failed | Total | Total % |
| --- | ---: | ---: | ---: | ---: | ---: |
| 27 — Extended UI | 0 | 102 | 0 | 102 | 100% |

## Earlier implementation validation

These results predate the Xcode-plan migration; they are not additional runs of
the current Extended plan.

| iOS | Scope | UI cases passed |
| --- | --- | ---: |
| 17.5 | Focused only | 11 |
| 18.6 | Complete applicable catalog | 101 |
| 26.5 | Complete catalog | 102 |
| 27.0 | Complete catalog | 102 |

The verified production iOS 26 baseline supplied the behavioral contract.
Broad iOS 17 was intentionally excluded. Native safeAreaBar comparison applies
only to iOS 26+. Screenshots were inspected; this is not frame-by-frame compositor
verification. Release demo/library build passed before the test-plan migration.

## Validator migration evidence

The Swift validator matches all 125 frozen calls from 91 positive/negative
controls, including failure/inconclusive classifications and helper results.
Eleven catalog checks verify plan membership and entry points. Saved real passing
and failing traces were also compared. Runtime observer calibration diagnostics
are retained separately from the release plans.

## Deferred issue

[External scroll-item alignment #27](https://github.com/SwiftKickMobile/SwiftUIMaterialTabs/issues/27)
is excluded from release clearance. Reproduction: in the external-position
fixture, tap Overview, then Row 10. Production iOS 26 placed row 10 about 115pt
below the content top. The internal hidden-item anchor can be reused when the
external item changes but its external anchor does not. Tim deferred this issue;
no fix is included here. Its fixture and targeted cases are retained.

## Cleanup recovery

Superseded scripts, legacy test implementations, and detailed investigation logs
were archived before cleanup at:

`/Users/tim/.codex/visualizations/2026/09/24/01a0d3e7-6d2e-7ee2-9ba4-b509b886acbb/suimt-cleanup.h237Nh/pre-cleanup.tgz`

The archive is a local recovery copy, not a dependency of the test plans.
The obsolete script tree and generated Python caches were removed. Active
validation support, test plans, and retained observer diagnostics are grouped
separately; demo-only instrumentation/reproductions are under `Demo/Testing`.
No release commit, tag, or publication was created by this work.
