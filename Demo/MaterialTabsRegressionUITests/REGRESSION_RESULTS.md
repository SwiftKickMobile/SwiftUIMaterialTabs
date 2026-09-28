# 3.0.0 integration verification — work in progress

PR #26 is merged into main and incorporated into this branch. Its observable
header context and ScrollPosition API are retained alongside Liquid Glass.

## Focused UI scenarios

The original 11 scenarios passed on iOS 18.6, 26.5, and 27.0 after integration.
All 15 saved screenshots per runtime were inspected. Each run also passed
52 model tests and 105 validator/catalog tests. These runs preceded the
TestHost separation; the final cleaned build still needs full validation.

## Issue #27 regression

Two new cases cover Overview → Row 10 → Activity → Overview → Top, using the
new ScrollPosition API with Liquid Glass off/on. Row positions are measured
independently of the context and screenshots are saved after each action.

The first off case on iOS 26 failed a header-continuity assertion during the
Overview → Activity transition (150 expected, 17.667 observed). The on case
was skipped by fail-fast. Classification is pending trace/screenshot review.
Issue #27 remains open. Per Tim's direction, failures of these two cases are
to be documented as known failures, not fixed as part of this release effort.

## Remaining verification

- Document the two new cases on iOS 18, 26, and 27.
- Run Extended on the cleaned TestHost build for all three supported versions.
- Verify normal Demo launch separately. iOS 17 is no longer supported by #26.
