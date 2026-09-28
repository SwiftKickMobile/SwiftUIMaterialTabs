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

Both cases ran on all three runtimes with expected validation failures. All
30 saved screenshots show the requested settled Row 10 / Top destinations.
The failures concern context/native-offset agreement and transition samples;
they do not establish persistence of the original settled-row alignment bug.
Issue #27 records the results. Per Tim's direction, it remains deferred.
Only the two cases' validation failures are expected; launch/input failures
and missing evidence still fail normally.

## Observer correction

The first full iOS 27 run stopped after three UI passes when the deceleration
switch case had no completed restored-context sample. The view had consumed
offset 150, but its preference callback left the recorder at 351.667. Saved
screenshots showed the expected positions. Copying earlier did not repair the
missing callback. The DEBUG-only observer now captures immutable values when
consumed and samples them at the existing passive update boundary; it does not
drive scrolling or substitute a later model read. This check passed ten repeats,
and all 50 saved screenshots were inspected. The full suite is restarting.

The cleaned Extended plan contains 104 UI scenarios, 53 model tests, and
105 validator/catalog tests. These categories must be reported separately.

## Remaining verification

- Document the two new cases on iOS 18, 26, and 27.
- Run Extended on the cleaned TestHost build for all three supported versions.
- Verify normal Demo launch separately. iOS 17 is no longer supported by #26.
