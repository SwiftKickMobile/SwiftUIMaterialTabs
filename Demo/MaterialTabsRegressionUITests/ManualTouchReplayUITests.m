#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "MaterialTabsRegressionUITests-Swift.h"

// Test-runner-only XCTest event interfaces. They are NOT linked into the demo
// or library. Runtime availability is checked; there is no silent fallback to
// a different gesture or to element.tap(). Reference declarations:
// github.com/appium/WebDriverAgent/tree/master/PrivateHeaders/XCTest
@interface NSObject (SUIMTRecordedEventInterfaces)
- (instancetype)initForTouchAtPoint:(CGPoint)point offset:(double)offset;
- (void)moveToPoint:(CGPoint)point atOffset:(double)offset;
- (void)liftUpAtOffset:(double)offset;
- (instancetype)initWithName:(NSString *)name interfaceOrientation:(NSInteger)orientation;
- (void)addPointerEventPath:(id)path;
- (void)synthesizeEvent:(id)event completion:(void (^)(BOOL, NSError *))completion;
@end

@interface XCUIDevice (SUIMTRecordedEventInterfaces)
@property (readonly) id eventSynthesizer;
@end

@interface ManualTouchReplayUITests : XCTestCase
@end

static void SUIMTTraceSaved(CFNotificationCenterRef center, void *observer, CFStringRef name,
                           const void *object, CFDictionaryRef userInfo) {
    [(__bridge XCTestExpectation *)observer fulfill];
}

@implementation ManualTouchReplayUITests
- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    [SUIMTRegressionRunObserver install];
    XCTSkipIf(SUIMTRegressionRunObserver.precedingFailure != nil,
              @"Stopped after earlier failure: %@", SUIMTRegressionRunObserver.precedingFailure);
}
// Header-configuration migration, separate from the frozen 75-case matrix.
- (void)testHeaderFixedOff { [self replayVariant:@"planned" label:@"header-fixed-off" experiment:NO]; }
- (void)testHeaderRetainedOff { [self replayVariant:@"planned" label:@"header-retained-off" experiment:NO]; }
- (void)testHeaderTitlelessOff { [self replayVariant:@"planned" label:@"header-titleless-off" experiment:NO]; }
- (void)testHeaderFixedOn { [self replayVariant:@"planned" label:@"header-fixed-on" experiment:NO]; }
- (void)testHeaderRetainedOn { [self replayVariant:@"planned" label:@"header-retained-on" experiment:NO]; }
- (void)testHeaderTitlelessOn { [self replayVariant:@"planned" label:@"header-titleless-on" experiment:NO]; }
- (void)testResetPositionOff { [self replayVariant:@"planned" label:@"reset-position-off" experiment:NO]; }
- (void)testResetPositionOn { [self replayVariant:@"planned" label:@"reset-position-on" experiment:NO]; }
- (void)testShortContentOff { [self replayVariant:@"planned" label:@"short-content-off" experiment:NO]; }
- (void)testShortContentOn { [self replayVariant:@"planned" label:@"short-content-on" experiment:NO]; }
- (void)testVisualExpandedHeader { [self replayVariant:@"planned" label:@"visual-expanded-header" experiment:NO]; }
- (void)testVisualNativeReference {
    XCTSkipIf(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 26, @"Native safeAreaBar reference requires iOS 26+");
    [self replayVariant:@"planned" label:@"visual-native-reference" experiment:NO];
}
- (void)testExternalPositionOff { [self replayVariant:@"planned" label:@"external-position-off" experiment:NO]; }
- (void)testExternalPositionOn { [self replayVariant:@"planned" label:@"external-position-on" experiment:NO]; }
- (void)testFlickSettledOff { [self replayVariant:@"planned" label:@"flick-settled-off" experiment:NO]; }
- (void)testFlickSettledOn { [self replayVariant:@"planned" label:@"flick-settled-on" experiment:NO]; }
- (void)testFlickSwitchOff { [self replayVariant:@"planned" label:@"flick-switch-off" experiment:NO]; }
- (void)testFlickSwitchOn { [self replayVariant:@"planned" label:@"flick-switch-on" experiment:NO]; }
- (void)testNativeFlickRoutingControl { [self replayVariant:@"nativeFlickControl" label:@"flick-touch-probe" experiment:YES]; }
- (void)testNativeFlickScaledRoutingControl { [self replayVariant:@"nativeFlickScaledControl" label:@"flick-touch-probe" experiment:YES]; }
- (void)testNativeFlickHeaderScrollControl { [self replayVariant:@"nativeFlickHeaderScrollControl" label:@"flick-touch-probe" experiment:YES]; }
- (void)testFlickPairedRouting { [self replayVariant:@"pairedFlick" label:@"flick-touch-probe" experiment:NO]; }
- (void)testFlickTouchProbe { [self replayVariant:@"planned" label:@"flick-touch-probe" experiment:NO]; }
// Generated matrix entry points. Plans are in Fixtures/query-free-cases.json.
- (void)testMatrixColdTap10ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-expanded-off" experiment:NO]; }
- (void)testMatrixColdTap10PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-partial-off" experiment:NO]; }
- (void)testMatrixColdTap10CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-collapsed-off" experiment:NO]; }
- (void)testMatrixColdTap12ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-expanded-off" experiment:NO]; }
- (void)testMatrixColdTap12PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-partial-off" experiment:NO]; }
- (void)testMatrixColdTap12CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-collapsed-off" experiment:NO]; }
- (void)testMatrixColdTap02ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-expanded-off" experiment:NO]; }
- (void)testMatrixColdTap02PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-partial-off" experiment:NO]; }
- (void)testMatrixColdTap02CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-collapsed-off" experiment:NO]; }
- (void)testMatrixColdTap20ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-expanded-off" experiment:NO]; }
- (void)testMatrixColdTap20PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-partial-off" experiment:NO]; }
- (void)testMatrixColdTap20CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-collapsed-off" experiment:NO]; }
- (void)testMatrixRelativeResettitleTapOff { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-tap-off" experiment:NO]; }
- (void)testMatrixRelativePreserveTapOff { [self replayVariant:@"planned" label:@"matrix-relative-preserve-tap-off" experiment:NO]; }
- (void)testMatrixBottom1TapOff { [self replayVariant:@"planned" label:@"matrix-bottom-1-tap-off" experiment:NO]; }
- (void)testMatrixBottom2TapOff { [self replayVariant:@"planned" label:@"matrix-bottom-2-tap-off" experiment:NO]; }
- (void)testMatrixColdSwipe10ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-expanded-off" experiment:NO]; }
- (void)testMatrixColdSwipe10PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-partial-off" experiment:NO]; }
- (void)testMatrixColdSwipe10CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-collapsed-off" experiment:NO]; }
- (void)testMatrixColdSwipe12ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-expanded-off" experiment:NO]; }
- (void)testMatrixColdSwipe12PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-partial-off" experiment:NO]; }
- (void)testMatrixColdSwipe12CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-collapsed-off" experiment:NO]; }
- (void)testMatrixColdSwipe02ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-expanded-off" experiment:NO]; }
- (void)testMatrixColdSwipe02PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-partial-off" experiment:NO]; }
- (void)testMatrixColdSwipe02CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-collapsed-off" experiment:NO]; }
- (void)testMatrixColdSwipe20ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-expanded-off" experiment:NO]; }
- (void)testMatrixColdSwipe20PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-partial-off" experiment:NO]; }
- (void)testMatrixColdSwipe20CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-collapsed-off" experiment:NO]; }
- (void)testMatrixRelativeResettitleSwipeOff { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-swipe-off" experiment:NO]; }
- (void)testMatrixRelativePreserveSwipeOff { [self replayVariant:@"planned" label:@"matrix-relative-preserve-swipe-off" experiment:NO]; }
- (void)testMatrixBottom1SwipeOff { [self replayVariant:@"planned" label:@"matrix-bottom-1-swipe-off" experiment:NO]; }
- (void)testMatrixBottom2SwipeOff { [self replayVariant:@"planned" label:@"matrix-bottom-2-swipe-off" experiment:NO]; }
- (void)testMatrixSeed20260925Off { [self replayVariant:@"planned" label:@"matrix-seed-20260925-off" experiment:NO]; }
- (void)testMatrixSeed927Off { [self replayVariant:@"planned" label:@"matrix-seed-927-off" experiment:NO]; }
- (void)testMatrixSmokeCollapsedTapOff { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-tap-off" experiment:NO]; }
- (void)testMatrixSmokeCollapsedSwipeOff { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-swipe-off" experiment:NO]; }
- (void)testMatrixSmokeReturningOff { [self replayVariant:@"planned" label:@"matrix-smoke-returning-off" experiment:NO]; }
- (void)testMatrixColdTap10ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-expanded-on" experiment:NO]; }
- (void)testMatrixColdTap10PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-partial-on" experiment:NO]; }
- (void)testMatrixColdTap10CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-collapsed-on" experiment:NO]; }
- (void)testMatrixColdTap12ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-expanded-on" experiment:NO]; }
- (void)testMatrixColdTap12PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-partial-on" experiment:NO]; }
- (void)testMatrixColdTap12CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-collapsed-on" experiment:NO]; }
- (void)testMatrixColdTap02ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-expanded-on" experiment:NO]; }
- (void)testMatrixColdTap02PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-partial-on" experiment:NO]; }
- (void)testMatrixColdTap02CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-collapsed-on" experiment:NO]; }
- (void)testMatrixColdTap20ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-expanded-on" experiment:NO]; }
- (void)testMatrixColdTap20PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-partial-on" experiment:NO]; }
- (void)testMatrixColdTap20CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-collapsed-on" experiment:NO]; }
- (void)testMatrixRelativeResettitleTapOn { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-tap-on" experiment:NO]; }
- (void)testMatrixRelativePreserveTapOn { [self replayVariant:@"planned" label:@"matrix-relative-preserve-tap-on" experiment:NO]; }
- (void)testMatrixBottom1TapOn { [self replayVariant:@"planned" label:@"matrix-bottom-1-tap-on" experiment:NO]; }
- (void)testMatrixBottom2TapOn { [self replayVariant:@"planned" label:@"matrix-bottom-2-tap-on" experiment:NO]; }
- (void)testMatrixColdSwipe10ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-expanded-on" experiment:NO]; }
- (void)testMatrixColdSwipe10PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-partial-on" experiment:NO]; }
- (void)testMatrixColdSwipe10CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-collapsed-on" experiment:NO]; }
- (void)testMatrixColdSwipe12ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-expanded-on" experiment:NO]; }
- (void)testMatrixColdSwipe12PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-partial-on" experiment:NO]; }
- (void)testMatrixColdSwipe12CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-collapsed-on" experiment:NO]; }
- (void)testMatrixColdSwipe02ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-expanded-on" experiment:NO]; }
- (void)testMatrixColdSwipe02PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-partial-on" experiment:NO]; }
- (void)testMatrixColdSwipe02CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-collapsed-on" experiment:NO]; }
- (void)testMatrixColdSwipe20ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-expanded-on" experiment:NO]; }
- (void)testMatrixColdSwipe20PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-partial-on" experiment:NO]; }
- (void)testMatrixColdSwipe20CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-collapsed-on" experiment:NO]; }
- (void)testMatrixRelativeResettitleSwipeOn { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-swipe-on" experiment:NO]; }
- (void)testMatrixRelativePreserveSwipeOn { [self replayVariant:@"planned" label:@"matrix-relative-preserve-swipe-on" experiment:NO]; }
- (void)testMatrixBottom1SwipeOn { [self replayVariant:@"planned" label:@"matrix-bottom-1-swipe-on" experiment:NO]; }
- (void)testMatrixBottom2SwipeOn { [self replayVariant:@"planned" label:@"matrix-bottom-2-swipe-on" experiment:NO]; }
- (void)testMatrixSeed20260925On { [self replayVariant:@"planned" label:@"matrix-seed-20260925-on" experiment:NO]; }
- (void)testMatrixSeed927On { [self replayVariant:@"planned" label:@"matrix-seed-927-on" experiment:NO]; }
- (void)testMatrixSmokeCollapsedTapOn { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-tap-on" experiment:NO]; }
- (void)testMatrixSmokeCollapsedSwipeOn { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-swipe-on" experiment:NO]; }
- (void)testMatrixSmokeReturningOn { [self replayVariant:@"planned" label:@"matrix-smoke-returning-on" experiment:NO]; }
- (void)testMatrixSmokeNormalDemo { [self replayVariant:@"planned" label:@"matrix-smoke-normal-demo" experiment:NO]; }
- (void)testStandalonePagerBindingDiagnosis {
    [self diagnoseBindingVariants:@[@"direct", @"custom-outer", @"custom-inner", @"lazy-inner"]];
}
- (void)testMinimalEagerPagerBindingDiagnosis {
    [self diagnoseBindingVariants:@[@"minimal", @"minimal-raw"]];
}
- (void)testEagerPagerConfigurationDiagnosis {
    [self diagnoseBindingVariants:@[@"minimal-aligned", @"minimal-noanchor"]];
}
- (void)testEagerPagerProgrammaticDiagnosis {
    [self diagnoseBindingVariants:@[@"minimal-jump"]];
}
- (void)testEagerPagerIdentityDiagnosis {
    [self diagnoseBindingVariants:@[@"identity-explicit", @"identity-foreach", @"identity-explicit"]];
}
- (void)testSingletonPagerIdentityDiagnosis {
    [self diagnoseBindingVariants:@[@"removed-static", @"singleton-static", @"singleton-outer", @"singleton-inner-id"]];
}
- (void)testSingletonPagerStructureDiagnosis {
    [self diagnoseBindingVariants:@[@"singleton-static", @"singleton-matching", @"singleton-outer", @"singleton-static-layout", @"singleton-outer-layout"]];
}
- (void)testPerPageTargetDiagnosis {
    [self diagnoseBindingVariants:@[@"target-static", @"target-matching", @"target-outer", @"target-inner-id"]];
}
- (void)diagnoseBindingVariants:(NSArray<NSString *> *)variants {
    // Diagnostic experiment: log binding writes and capture the displayed page.
    // No accessibility query takes place until after the swipe and screenshot.
    for (NSString *variant in variants) {
        XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.swiftkickmobile.Demo"];
        app.launchEnvironment = @{@"SUIMT_BINDING_REPRO": variant};
        [app launch];
        [self waitUntilUptime:NSProcessInfo.processInfo.systemUptime + 1.0];
        id path = [[NSClassFromString(@"XCPointerEventPath") alloc] initForTouchAtPoint:CGPointMake(330, 430) offset:0];
        for (NSInteger step = 1; step <= 20; step++) {
            [path moveToPoint:CGPointMake(330 - 270.0 * step / 20, 430) atOffset:0.6 * step / 20];
        }
        [path liftUpAtOffset:0.65];
        id event = [[NSClassFromString(@"XCSynthesizedEventRecord") alloc] initWithName:@"Standalone pager swipe" interfaceOrientation:1];
        [event addPointerEventPath:path];
        XCTestExpectation *finished = [self expectationWithDescription:@"Standalone swipe delivered"];
        [XCUIDevice.sharedDevice.eventSynthesizer synthesizeEvent:event completion:^(BOOL success, NSError *error) {
            XCTAssertTrue(success, @"%@", error);
            [finished fulfill];
        }];
        [self waitForExpectations:@[finished] timeout:10];
        [self waitUntilUptime:NSProcessInfo.processInfo.systemUptime + 1.0];
        if ([variant isEqualToString:@"minimal-jump"]) {
            id tapPath = [[NSClassFromString(@"XCPointerEventPath") alloc] initForTouchAtPoint:CGPointMake(190, 110) offset:0];
            [tapPath liftUpAtOffset:0.08];
            id tapEvent = [[NSClassFromString(@"XCSynthesizedEventRecord") alloc] initWithName:@"Set selection to 2" interfaceOrientation:1];
            [tapEvent addPointerEventPath:tapPath];
            XCTestExpectation *tapDone = [self expectationWithDescription:@"Selection write delivered"];
            [XCUIDevice.sharedDevice.eventSynthesizer synthesizeEvent:tapEvent completion:^(BOOL success, NSError *error) {
                XCTAssertTrue(success, @"%@", error);
                [tapDone fulfill];
            }];
            [self waitForExpectations:@[tapDone] timeout:10];
            [self waitUntilUptime:NSProcessInfo.processInfo.systemUptime + 1.0];
        }
        XCTAttachment *screen = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
        screen.name = [@"Binding diagnosis - " stringByAppendingString:variant];
        screen.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:screen];
        NSLog(@"BINDING_DIAGNOSIS %@", app.staticTexts[@"pager-diagnostic"].label);
        [app terminate];
    }
}
- (void)testViewportCalibration {
    // Separate launch used ONLY for fixture calibration. Never query app/element
    // frames before or between gestures in a recorded interaction test.
    XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.swiftkickmobile.Demo"];
    app.launchEnvironment = @{@"SUIMT_UI_REGRESSION": @"0", @"SUIMT_CONTEXT_TRACE": @"0"};
    [app launch];
    XCTAssertTrue([app.buttons[@"Overview"] waitForExistenceWithTimeout:10]);
    CGRect viewport = app.frame;
    CGRect button = app.buttons[@"Overview"].frame;
    NSDictionary *profile = @{@"width": @(viewport.size.width), @"height": @(viewport.size.height),
                              @"collapsedTabTop": @(button.origin.y - 150),
                              @"buttonHeight": @(button.size.height),
                              @"os": NSProcessInfo.processInfo.operatingSystemVersionString};
    NSData *data = [NSJSONSerialization dataWithJSONObject:profile options:NSJSONWritingSortedKeys error:nil];
    NSLog(@"FIXTURE_CALIBRATION %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    XCTAttachment *screen = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    screen.name = @"Calibration only - not a regression result";
    screen.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:screen];
    [app terminate];
}
- (void)testQueryFreeColdNotesTap {
    [self replayVariant:@"planned" label:@"cold-notes-tap" experiment:NO];
}
- (void)testMinimalStateResetReproduction {
    [self replayVariant:@"minimal" label:@"minimal-state-reset" experiment:YES];
}
- (void)testLifecycleSUIMT {
    [self replayVariant:@"nonAdjacentExactReturn" label:@"lifecycle-suimt" experiment:YES];
}
- (void)testLifecyclePlainLazy {
    [self replayVariant:@"lifecycle-plain" label:@"lifecycle-plain-lazy" experiment:YES];
}
- (void)testLifecyclePlainEager {
    [self replayVariant:@"lifecycle-plain" label:@"lifecycle-plain-eager" experiment:YES];
}
- (void)testLifecyclePlainLazyLong {
    [self replayVariant:@"lifecycle-plain" label:@"lifecycle-plain-lazy-long" experiment:YES];
}
- (void)testLifecyclePlainLazyUpdates {
    [self replayVariant:@"lifecycle-plain" label:@"lifecycle-plain-lazy-updates" experiment:YES];
}
- (void)testLifecyclePlainEagerUpdates {
    [self replayVariant:@"lifecycle-plain" label:@"lifecycle-plain-eager-updates" experiment:YES];
}
- (void)testLifecycleSUIMTOverlay {
    [self replayVariant:@"nonAdjacentExactReturn" label:@"lifecycle-suimt-overlay" experiment:YES];
}
- (void)testQueryFreeNotesFourStep {
    [self replayVariant:@"planned" label:@"notes-four-step" experiment:NO];
}

- (void)testRecordedManualDragAndOverviewTap {
    [self replayVariant:@"none" label:@"recorded-reproduction" experiment:NO];
}

- (void)testRecordedAdjacentExpandedReturn {
    [self replayVariant:@"adjacentReturn" label:@"recorded-adjacent-return" experiment:NO];
}

- (void)testRecordedNonAdjacentExpandedReturn {
    [self replayVariant:@"nonAdjacentReturn" label:@"recorded-nonadjacent-return" experiment:NO];
}

- (void)testNotesExpansionWithoutOverscroll {
    [self replayVariant:@"nonAdjacentExactReturn" label:@"recorded-nonadjacent-exact-return" experiment:NO];
}

- (void)testNotesUninstrumented {
    [self replayVariant:@"nonAdjacentExactReturn" label:@"notes-uninstrumented" experiment:NO];
}

- (void)testNotesUninstrumentedAfterIdle {
    [self replayVariant:@"nonAdjacentExactReturn" label:@"notes-uninstrumented-idle" experiment:NO];
}

// Instrumentation ablation, not an assertion that content restoration passes.
// Same gestures, launch waits and app in every trial; only observation differs.
- (void)testNotesObserverAblation {
    for (NSInteger repetition = 0; repetition < 2; repetition++) {
        NSArray *labels = repetition == 0 ? @[@"notes-raw", @"notes-boundary", @"notes-native"]
                                          : @[@"notes-native", @"notes-boundary", @"notes-raw"];
        for (NSString *prefix in labels) {
            [self replayVariant:@"nonAdjacentReturn"
                          label:[NSString stringWithFormat:@"%@-%ld", prefix, (long)repetition]
                     experiment:NO];
        }
    }
}

- (void)testQueryFreeExpandedTaps {
    [self replayVariant:@"planned" label:@"expanded-taps" experiment:NO];
}
- (void)testQueryFreePartialTaps {
    [self replayVariant:@"planned" label:@"partial-taps" experiment:NO];
}
- (void)testQueryFreeCollapsedTaps {
    [self replayVariant:@"planned" label:@"collapsed-taps" experiment:NO];
}
- (void)testQueryFreePartialSwipes {
    [self replayVariant:@"planned" label:@"partial-swipes" experiment:NO];
}
- (void)testQueryFreeCollapsedSwipes {
    [self replayVariant:@"planned" label:@"collapsed-swipes" experiment:NO];
}
- (void)testQueryFreeRepeatedHeaderChanges {
    [self replayVariant:@"planned" label:@"repeated-header-changes" experiment:NO];
}

// Shared with the post-run checker: the requested selections and preconditions
// are explicit, rather than inferred from whichever tab happened to be selected.
- (NSArray<NSDictionary *> *)sequenceForPlan:(NSDictionary *)plan original:(NSArray<NSDictionary *> *)original {
    NSArray *drag = [original filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == 0"]];
    NSMutableArray *result = [NSMutableArray array];
    double cursor = 0;
    NSInteger identifier = 0;
    for (NSDictionary *step in plan[@"steps"]) {
        NSString *kind = step[@"kind"];
        if ([kind isEqualToString:@"flickUp"]) {
            double duration = [step[@"duration"] doubleValue];
            double originY = [step[@"startY"] doubleValue];
            double distance = [step[@"distance"] doubleValue];
            for (NSInteger point = 0; point <= 12; point++) {
                double fraction = point / 12.0;
                [result addObject:@{@"id": @(identifier), @"x": @260,
                    @"phase": point == 0 ? @"began" : point == 12 ? @"ended" : @"moved",
                    @"y": @(originY - fraction * distance), @"time": @(cursor + duration * fraction)}];
            }
            cursor += duration;
        } else if ([kind isEqualToString:@"up"] || [kind isEqualToString:@"down"]) {
            double scale = step[@"scale"] ? [step[@"scale"] doubleValue] : 1;
            double initialY = [drag.firstObject[@"y"] doubleValue];
            BOOL down = [kind isEqualToString:@"down"];
            double originY = step[@"startY"] ? [step[@"startY"] doubleValue] : (down ? 430 : initialY);
            for (NSDictionary *sample in drag) {
                NSMutableDictionary *value = sample.mutableCopy;
                value[@"id"] = @(identifier);
                value[@"time"] = @(cursor + [sample[@"time"] doubleValue]);
                double delta = ([sample[@"y"] doubleValue] - initialY) * scale;
                value[@"y"] = @(originY + (down ? -delta : delta));
                [result addObject:value];
            }
            cursor += [drag.lastObject[@"time"] doubleValue];
        } else if ([kind isEqualToString:@"tap"]) {
            [result addObject:@{@"id": @(identifier), @"phase": @"began", @"x": step[@"x"], @"y": step[@"y"], @"time": @(cursor)}];
            cursor += 0.05;
            [result addObject:@{@"id": @(identifier), @"phase": @"ended", @"x": step[@"x"], @"y": step[@"y"], @"time": @(cursor)}];
        } else {
            XCTAssertTrue([kind isEqualToString:@"left"] || [kind isEqualToString:@"right"]);
            BOOL right = [kind isEqualToString:@"right"];
            for (NSInteger point = 0; point <= 30; point++) {
                double fraction = point / 30.0;
                [result addObject:@{@"id": @(identifier),
                    @"phase": point == 0 ? @"began" : point == 30 ? @"ended" : @"moved",
                    @"x": @(right ? 65 + 270 * fraction : 335 - 270 * fraction),
                    @"y": @500, @"time": @(cursor + fraction * 0.6)}];
            }
            cursor += 0.6;
        }
        identifier++;
        cursor += step[@"pauseAfter"] ? [step[@"pauseAfter"] doubleValue] : 1.01;
    }
    return result;
}

// Extend the captured gesture shape without querying the app for coordinates.
- (NSArray<NSDictionary *> *)returnSequence:(NSArray<NSDictionary *> *)original nonAdjacent:(BOOL)nonAdjacent exactExpansion:(BOOL)exactExpansion {
    NSArray *drag = [original filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == 0"]];
    NSArray *tap = [original filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == 1"]];
    double dragDuration = [drag.lastObject[@"time"] doubleValue];
    double tapStart = [tap.firstObject[@"time"] doubleValue];
    double tapDuration = [tap.lastObject[@"time"] doubleValue] - tapStart;
    double gap = tapStart - dragDuration;
    NSMutableArray *result = [NSMutableArray array];
    __block double cursor = 0;
    __block NSInteger identifier = 0;
    void (^addTap)(double, double) = ^(double x, double y) {
        [result addObject:@{@"id": @(identifier), @"phase": @"began", @"x": @(x), @"y": @(y), @"time": @(cursor)}];
        [result addObject:@{@"id": @(identifier), @"phase": @"ended", @"x": @(x), @"y": @(y), @"time": @(cursor + tapDuration)}];
        identifier++;
        cursor += tapDuration + gap;
    };
    void (^addDrag)(BOOL) = ^(BOOL down) {
        double initialY = [drag.firstObject[@"y"] doubleValue];
        for (NSDictionary *sample in drag) {
            NSMutableDictionary *value = sample.mutableCopy;
            value[@"id"] = @(identifier);
            value[@"time"] = @(cursor + [sample[@"time"] doubleValue]);
            if (down) {
                double scale = exactExpansion ? 160.0 / (initialY - [drag.lastObject[@"y"] doubleValue]) : 1;
                value[@"y"] = @(430 + (initialY - [sample[@"y"] doubleValue]) * scale);
            }
            [result addObject:value];
        }
        identifier++;
        cursor += dragDuration + gap;
    };
    if (nonAdjacent) addTap(335, 292); // Notes, while expanded.
    addDrag(NO);
    if (nonAdjacent) addDrag(NO); // Leave a substantial relative offset, not just rounding-sized overlap.
    addTap(75.33333333333333, 142); // Overview, while collapsed.
    addDrag(YES);                  // Expand on Overview.
    addTap(nonAdjacent ? 335 : 201, 292); // Return without changing the header.
    return result;
}

// Diagnostic experiments, not assertions that the library is correct. Each
// trial starts a fresh app and keeps the gestures and timing budgets fixed.
- (void)testQueryPresenceAblation {
    for (NSInteger repetition = 0; repetition < 3; repetition++) {
        NSArray *order = repetition % 2 == 0 ? @[@"none", @"oldQueries"] : @[@"oldQueries", @"none"];
        for (NSString *variant in order) {
            [self replayVariant:variant label:[NSString stringWithFormat:@"presence-%@-%ld", variant, (long)repetition] experiment:YES];
        }
    }
}

- (void)testQueryLocationAblation {
    for (NSInteger repetition = 0; repetition < 3; repetition++) {
        NSArray *order = repetition % 2 == 0
            ? @[@"none", @"before", @"between", @"screenshotBetween"]
            : @[@"screenshotBetween", @"between", @"before", @"none"];
        for (NSString *variant in order) {
            [self replayVariant:variant label:[NSString stringWithFormat:@"location-%@-%ld", variant, (long)repetition] experiment:YES];
        }
    }
}

- (void)testTapAndScreenCaptureAblation {
    for (NSInteger repetition = 0; repetition < 2; repetition++) {
        NSArray *order = repetition == 0 ? @[@"none", @"elementTap", @"screenScreenshotBetween"]
                                        : @[@"screenScreenshotBetween", @"elementTap", @"none"];
        for (NSString *variant in order) {
            [self replayVariant:variant label:[NSString stringWithFormat:@"tap-screen-%@-%ld", variant, (long)repetition] experiment:YES];
        }
    }
}

- (void)queryHeader:(XCUIApplication *)app phase:(NSString *)phase events:(NSMutableArray *)events {
    double start = NSProcessInfo.processInfo.systemUptime;
    CGRect frame = app.buttons[@"Overview"].frame;
    double end = NSProcessInfo.processInfo.systemUptime;
    [events addObject:@{@"kind": @"frame", @"phase": phase, @"start": @(start), @"end": @(end),
                       @"x": @(frame.origin.x), @"y": @(frame.origin.y),
                       @"width": @(frame.size.width), @"height": @(frame.size.height)}];
    XCTAssertFalse(CGRectIsEmpty(frame));
}

- (void)waitUntilUptime:(double)deadline {
    double remaining = deadline - NSProcessInfo.processInfo.systemUptime;
    if (remaining > 0) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:remaining]];
}

- (void)savePassiveTrace {
    XCTestExpectation *saved = [self expectationWithDescription:@"Passive trace saved"];
    CFNotificationCenterRef notifications = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(notifications, (__bridge void *)saved, SUIMTTraceSaved,
        CFSTR("com.swiftkickmobile.Demo.manualTraceSaved"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterPostNotification(notifications, CFSTR("com.swiftkickmobile.Demo.saveManualTrace"), NULL, NULL, true);
    [self waitForExpectations:@[saved] timeout:5];
    CFNotificationCenterRemoveObserver(notifications, (__bridge void *)saved,
        CFSTR("com.swiftkickmobile.Demo.manualTraceSaved"), NULL);
}

- (void)waitForHorizontalPagingAtPath:(NSString *)path events:(NSMutableArray *)events {
    // A synthesized swipe finishing does not imply its native deceleration
    // has finished. Wait only for motion to stop, NEVER for a desired selection
    // or offset. All context samples during this interval remain in the trace.
    double start = NSProcessInfo.processInfo.systemUptime;
    double deadline = start + 5.0;
    NSUInteger samples = 0;
    while (YES) {
        double requestedAt = NSProcessInfo.processInfo.systemUptime;
        [self savePassiveTrace];
        NSData *data = [NSData dataWithContentsOfFile:path];
        XCTAssertNotNil(data, @"Missing passive pager readiness snapshot");
        NSString *state = [SUIMTRecordedTraceValidation pagingStateInData:data after:requestedAt];
        samples++;
        XCTAssertTrue([state isEqualToString:@"idle"] || [state isEqualToString:@"moving"], @"%@", state);
        if ([state isEqualToString:@"idle"]) break;
        if (NSProcessInfo.processInfo.systemUptime >= deadline) {
            XCTAttachment *trace = [XCTAttachment attachmentWithData:data uniformTypeIdentifier:@"public.json"];
            trace.name = @"Pager did not stop before next input";
            trace.lifetime = XCTAttachmentLifetimeKeepAlways;
            [self addAttachment:trace];
            XCTFail(@"Horizontal pager was still moving after the bounded settling wait");
            return;
        }
        [self waitUntilUptime:MIN(deadline, NSProcessInfo.processInfo.systemUptime + 0.1)];
    }
    [events addObject:@{@"kind": @"passivePagerSettling", @"start": @(start),
                        @"end": @(NSProcessInfo.processInfo.systemUptime), @"samples": @(samples)}];
}

- (void)testResetPositionThenLaunchDiagnostic {
    // Recreate the preceding case's final Notes state before diagnosing launch.
    [self replayVariant:@"planned" label:@"reset-position-off" experiment:NO];
    [self testInitialPageLaunchDiagnostic];
}

- (void)testInitialPageLaunchDiagnostic {
    [self initialPageLaunchDiagnosticForFlick:NO bindingRepro:nil];
}

- (void)testFlickInitialPageLaunchDiagnostic {
    [self initialPageLaunchDiagnosticForFlick:YES bindingRepro:nil];
}

- (void)testInitialEagerBindingLaunchDiagnostic {
    [self initialPageLaunchDiagnosticForFlick:NO bindingRepro:@"initial-eager-explicit"];
}

- (void)testInitialLazyBindingLaunchDiagnostic {
    [self initialPageLaunchDiagnosticForFlick:NO bindingRepro:@"initial-lazy-explicit"];
}

- (void)testInitialImplicitBindingLaunchDiagnostic {
    [self initialPageLaunchDiagnosticForFlick:NO bindingRepro:@"initial-eager-implicit"];
}

- (void)initialPageLaunchDiagnosticForFlick:(BOOL)flick bindingRepro:(NSString *)bindingRepro {
    self.continueAfterFailure = NO;
    for (NSInteger trial = 1; trial <= 10; trial++) {
        NSString *tracePath = [NSTemporaryDirectory() stringByAppendingPathComponent:
            [NSString stringWithFormat:@"suimt-initial-%@.json", NSUUID.UUID.UUIDString]];
        XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.swiftkickmobile.Demo"];
        app.launchEnvironment = @{@"SUIMT_CONTEXT_TRACE": @"1", @"SUIMT_MANUAL_CAPTURE": @"1",
            @"SUIMT_LIFECYCLE_PROBE": @"1", @"SUIMT_BOUNDARY_TRACE": @"1", @"SUIMT_NATIVE_SCROLL_PROBE": @"1",
            @"SUIMT_UI_REGRESSION": @"0", @"SUIMT_BROAD_REPLAY": @"1", @"SUIMT_INITIAL_TAB": @"activity",
            @"SUIMT_SYNC_MODE": @"resetPosition", @"SUIMT_NATIVE_EDGE": @"1", @"SUIMT_ROW_COUNT": @"30",
            @"SUIMT_TITLE_HEIGHT": @"150", @"SUIMT_MIN_TITLE_HEIGHT": @"0",
            @"SUIMT_PASSIVE_TRACE_PATH": tracePath, @"SUIMT_CAPTURE_LABEL": @"initial-page-diagnostic"};
        if (flick) {
            NSMutableDictionary *environment = [app.launchEnvironment mutableCopy];
            environment[@"SUIMT_FLICK_FIXTURE"] = @"1";
            environment[@"SUIMT_PHASE_SWITCH"] = @"1";
            environment[@"SUIMT_NATIVE_EDGE"] = @"0";
            environment[@"SUIMT_SYNC_MODE"] = @"resetTitle";
            app.launchEnvironment = environment;
        }
        if (bindingRepro) {
            NSMutableDictionary *environment = [app.launchEnvironment mutableCopy];
            environment[@"SUIMT_BINDING_REPRO"] = bindingRepro;
            app.launchEnvironment = environment;
        }
        [app launch];
        // Same launch mechanism as replay, but no gestures or AX queries.
        // Export BEFORE screenshot so capture cannot repair the measured state.
        [self savePassiveTrace];
        NSData *data = [NSData dataWithContentsOfFile:tracePath];
        XCTAssertNotNil(data);
        XCTAttachment *trace = [XCTAttachment attachmentWithData:data uniformTypeIdentifier:@"public.json"];
        trace.name = [NSString stringWithFormat:@"Initial page trace %02ld", (long)trial];
        trace.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:trace];
        XCTAttachment *screen = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
        screen.name = [NSString stringWithFormat:@"Initial page screen %02ld", (long)trial];
        screen.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:screen];
        NSError *error = nil;
        NSDictionary *report = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        XCTAssertNil(error);
        XCTAssertEqual([report[@"touches"] count], 0u);
        NSDictionary *sample = [report[@"nativeScrollSnapshots"] lastObject];
        double width = [sample[@"windowWidth"] doubleValue];
        NSMutableArray *pagers = [NSMutableArray array];
        for (NSDictionary *scroll in sample[@"scrolls"]) {
            if (fabs([scroll[@"frameX"] doubleValue]) < 0.5 &&
                fabs([scroll[@"boundsWidth"] doubleValue] - width) < 0.5 &&
                fabs([scroll[@"contentWidth"] doubleValue] - 3 * width) < 0.5) [pagers addObject:scroll];
        }
        XCTAssertEqual(pagers.count, 1u, @"Need one physical pager before input");
        NSDictionary *pager = pagers.firstObject;
        XCTAssertEqualWithAccuracy([pager[@"offsetX"] doubleValue] + [pager[@"insetLeft"] doubleValue],
                                  width, 0.5, @"Launch %ld did not display requested Activity page; inspect screenshot", (long)trial);
        [app terminate];
    }
}

- (void)testFlickContextReadout {
    [self replayVariant:@"flickContextReadout" label:@"flick-switch-off" experiment:NO];
}

- (void)replayVariant:(NSString *)variant label:(NSString *)label experiment:(BOOL)experiment {
    self.continueAfterFailure = NO;
    NSMutableArray *queries = [NSMutableArray array];
    NSMutableArray<XCUIScreenshot *> *queryScreenshots = [NSMutableArray array];
    NSMutableArray *dispatches = [NSMutableArray array];
    BOOL deadlineOverrun = NO;
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSLog(@"REPLAY_BUNDLE dynamicClass=%@ dynamicPath=%@ declaredPath=%@ mainPath=%@",
          NSStringFromClass(self.class), bundle.bundlePath,
          [NSBundle bundleForClass:ManualTouchReplayUITests.class].bundlePath,
          NSBundle.mainBundle.bundlePath);
    NSURL *url = [bundle URLForResource:@"manual-collapse-overview" withExtension:@"json"];
    if (!url) url = [bundle URLForResource:@"manual-collapse-overview" withExtension:@"json" subdirectory:@"Fixtures"];
    XCTAssertNotNil(url, @"Recorded input fixture must be bundled");
    NSError *error = nil;
    NSDictionary *fixture = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url]
                                                          options:0 error:&error];
    XCTAssertNil(error);
    NSArray<NSDictionary *> *samples = fixture[@"samples"];
    XCTAssertEqual(samples.count, 113u);
    BOOL nonAdjacent = [variant hasPrefix:@"nonAdjacent"];
    BOOL roundTrip = [variant isEqualToString:@"adjacentReturn"] || nonAdjacent;
    if (roundTrip) samples = [self returnSequence:samples nonAdjacent:nonAdjacent
                                 exactExpansion:[variant isEqualToString:@"nonAdjacentExactReturn"]];
    double expectedTop = roundTrip ? 274 : [fixture[@"expectedCollapsedTabTop"] doubleValue];
    double expectedTopTolerance = 2;
    NSDictionary *replayPlan = nil;
    if ([variant isEqualToString:@"minimal"]) {
        replayPlan = @{@"steps": @[
            @{@"kind": @"tap", @"x": @201, @"y": @108},
            @{@"kind": @"tap", @"x": @211, @"y": @73, @"screenshotBefore": @"A count before leaving"},
            @{@"kind": @"up", @"scale": @1.5, @"startY": @650},
            @{@"kind": @"tap", @"x": @191, @"y": @73}
        ]};
        samples = [self sequenceForPlan:replayPlan original:samples];
    }
    if ([variant isEqualToString:@"lifecycle-plain"]) {
        replayPlan = @{@"steps": @[
            @{@"kind": @"tap", @"tab": @"notes", @"x": @335, @"y": @142, @"pauseAfter": @2.5},
            @{@"kind": @"up", @"scale": @1.5, @"startY": @650},
            @{@"kind": @"tap", @"tab": @"overview", @"x": @75, @"y": @142, @"screenshotBefore": @"Notes before leaving"},
            @{@"kind": @"tap", @"tab": @"notes", @"x": @335, @"y": @142}
        ]};
        if ([label hasSuffix:@"long"] || [label hasSuffix:@"updates"]) {
            NSMutableArray *steps = [replayPlan[@"steps"] mutableCopy];
            [steps insertObject:@{@"kind": @"up", @"scale": @1.0, @"startY": @650} atIndex:3];
            replayPlan = @{@"steps": steps};
        }
        samples = [self sequenceForPlan:replayPlan original:samples];
    }
    if ([variant isEqualToString:@"planned"] || [variant hasPrefix:@"nativeFlick"] || [variant isEqualToString:@"pairedFlick"] || [variant isEqualToString:@"flickContextReadout"]) {
        NSURL *planURL = [bundle URLForResource:@"query-free-cases" withExtension:@"json"];
        if (!planURL) planURL = [bundle URLForResource:@"query-free-cases" withExtension:@"json" subdirectory:@"Fixtures"];
        XCTAssertNotNil(planURL);
        NSDictionary *plans = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:planURL] options:0 error:&error];
        XCTAssertNil(error);
        NSDictionary *plan = plans[label];
        XCTAssertNotNil(plan);
        replayPlan = plan;
        samples = [self sequenceForPlan:plan original:samples];
        NSArray *range = plan[@"headerRange"];
        double titleHeight = plan[@"fixture"][@"titleHeight"] ? [plan[@"fixture"][@"titleHeight"] doubleValue] : 150;
        expectedTop = 124 + titleHeight - ([range[0] doubleValue] + [range[1] doubleValue]) / 2;
        expectedTopTolerance = ([range[1] doubleValue] - [range[0] doubleValue]) / 2 + 2;
    }

    // Calibrated in a SEPARATE app launch, never by querying this test's app.
    // Keep vertical drag distances unchanged across OS versions.
    // Scale horizontal positions for the 393pt iOS 17 device and translate tap
    // heights for the older navigation bar. Do not read UIScreen.bounds here:
    // the iOS 17 XCTest runner reports a 320pt compatibility viewport. The CLI
    // validates the device type and the reader validates the actual app bounds.
    NSInteger osMajor = NSProcessInfo.processInfo.operatingSystemVersion.majorVersion;
    CGFloat fixtureWidth = osMajor == 17 ? 393 : 402;
    CGFloat fixtureHeight = osMajor == 17 ? 852 : 874;
    CGFloat collapsedTop = osMajor == 17 ? 105.66666666666667 : osMajor == 18 ? 108.33333333333333 : 124;
    XCTAssertTrue(osMajor == 17 || osMajor == 18 || osMajor == 26 || osMajor == 27);
    CGFloat tapDeltaY = collapsedTop - 124;
    expectedTop += tapDeltaY;
    NSMutableDictionary *firstPoints = [NSMutableDictionary dictionary];
    NSMutableSet *movingPaths = [NSMutableSet set];
    for (NSDictionary *sample in samples) {
        NSNumber *key = sample[@"id"];
        if (!firstPoints[key]) firstPoints[key] = sample;
        NSDictionary *first = firstPoints[key];
        if (fabs([sample[@"x"] doubleValue] - [first[@"x"] doubleValue]) +
            fabs([sample[@"y"] doubleValue] - [first[@"y"] doubleValue]) > 1) [movingPaths addObject:key];
    }
    NSMutableArray *mappedSamples = [NSMutableArray array];
    for (NSDictionary *sample in samples) {
        NSMutableDictionary *mapped = sample.mutableCopy;
        mapped[@"x"] = @([sample[@"x"] doubleValue] * fixtureWidth / 402);
        mapped[@"y"] = @([sample[@"y"] doubleValue] + ([movingPaths containsObject:sample[@"id"]] ? 0 : tapDeltaY));
        [mappedSamples addObject:mapped];
    }
    samples = mappedSamples;
    NSDictionary *viewportProfile = @{@"osMajor": @(osMajor), @"width": @(fixtureWidth),
                                      @"height": @(fixtureHeight), @"collapsedTabTop": @(collapsedTop)};

    Class pathClass = NSClassFromString(@"XCPointerEventPath");
    Class recordClass = NSClassFromString(@"XCSynthesizedEventRecord");
    XCTAssertNotNil(pathClass);
    XCTAssertNotNil(recordClass);
    XCTAssertTrue([pathClass instancesRespondToSelector:@selector(initForTouchAtPoint:offset:)]);
    XCTAssertTrue([pathClass instancesRespondToSelector:@selector(moveToPoint:atOffset:)]);
    XCTAssertTrue([pathClass instancesRespondToSelector:@selector(liftUpAtOffset:)]);
    XCTAssertTrue([recordClass instancesRespondToSelector:@selector(initWithName:interfaceOrientation:)]);
    XCTAssertTrue([recordClass instancesRespondToSelector:@selector(addPointerEventPath:)]);

    NSMutableArray<NSDictionary *> *segments = [NSMutableArray array];
    NSMutableDictionary *paths = [NSMutableDictionary dictionary];
    double previousTime = -1;
    double segmentStart = 0;
    for (NSDictionary *sample in samples) {
        double time = [sample[@"time"] doubleValue];
        XCTAssertGreaterThanOrEqual(time, previousTime);
        previousTime = time;
        NSNumber *identifier = sample[@"id"];
        CGPoint point = CGPointMake([sample[@"x"] doubleValue], [sample[@"y"] doubleValue]);
        NSString *phase = sample[@"phase"];
        if ([phase isEqualToString:@"began"]) {
            XCTAssertEqual(paths.count, 0u, @"This recorded fixture has sequential single-finger gestures");
            XCTAssertNil(paths[identifier]);
            segmentStart = time;
            paths[identifier] = [[pathClass alloc] initForTouchAtPoint:point offset:0];
        } else if ([phase isEqualToString:@"moved"]) {
            XCTAssertNotNil(paths[identifier]);
            [paths[identifier] moveToPoint:point atOffset:time - segmentStart];
        } else if ([phase isEqualToString:@"ended"]) {
            id path = paths[identifier];
            XCTAssertNotNil(path);
            [path liftUpAtOffset:time - segmentStart];
            id record = [[recordClass alloc] initWithName:@"Recorded manual input segment"
                                   interfaceOrientation:UIInterfaceOrientationPortrait];
            [record addPointerEventPath:path];
            [segments addObject:@{@"record": record, @"start": @(segmentStart), @"end": @(time)}];
            [paths removeObjectForKey:identifier];
        } else {
            XCTFail(@"Unsupported recorded phase %@", phase);
        }
    }
    XCTAssertEqual(paths.count, 0u);

    if ([variant isEqualToString:@"pairedFlick"]) {
        // Diagnostic: schedule the first two pointer paths in one injection.
        // Input traces must still prove release, deceleration, and selection.
        XCTAssertGreaterThanOrEqual(segments.count, 2u);
        NSDictionary *first = segments[0], *second = segments[1];
        NSDictionary *tap = [samples filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == 1 AND phase == 'began'"]].firstObject;
        XCTAssertNotNil(tap);
        double origin = [first[@"start"] doubleValue];
        id path = [[pathClass alloc] initForTouchAtPoint:CGPointMake([tap[@"x"] doubleValue], [tap[@"y"] doubleValue])
                                                offset:[second[@"start"] doubleValue] - origin];
        [path liftUpAtOffset:[second[@"end"] doubleValue] - origin];
        [first[@"record"] addPointerEventPath:path];
        NSMutableDictionary *combined = first.mutableCopy;
        combined[@"end"] = second[@"end"];
        segments[0] = combined;
        NSMutableDictionary *consumed = second.mutableCopy;
        consumed[@"alreadySent"] = @YES;
        segments[1] = consumed;
    }

    XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.swiftkickmobile.Demo"];
    BOOL broad = [@[@"broad", @"extended"] containsObject:replayPlan[@"suite"] ?: @""];
    XCTSkipIf(osMajor == 17 && broad, @"iOS 17 is scoped to the Core plan; extended UI coverage is intentionally excluded");
    CGFloat titleHeight = replayPlan[@"fixture"][@"titleHeight"] ? [replayPlan[@"fixture"][@"titleHeight"] doubleValue] : 150;
    NSString *passiveTracePath = [NSTemporaryDirectory() stringByAppendingPathComponent:
        [NSString stringWithFormat:@"suimt-passive-%@.json", NSUUID.UUID.UUIDString]];
    [self addTeardownBlock:^{
        NSError *cleanupError = nil;
        if ([NSFileManager.defaultManager fileExistsAtPath:passiveTracePath]) {
            XCTAssertTrue([NSFileManager.defaultManager removeItemAtPath:passiveTracePath error:&cleanupError], @"%@", cleanupError);
        }
    }];
    NSMutableDictionary *launchEnvironment = [@{@"SUIMT_CONTEXT_TRACE": @"1", @"SUIMT_MANUAL_CAPTURE": @"1", @"SUIMT_LIFECYCLE_PROBE": @"1",
                             @"SUIMT_UI_REGRESSION": @"0", @"SUIMT_CAPTURE_LABEL": label,
                             @"SUIMT_BOUNDARY_TRACE": [label hasPrefix:@"notes-raw"] ? @"0" : @"1",
                             @"SUIMT_NATIVE_SCROLL_PROBE": ([label hasPrefix:@"notes-raw"] || [label hasPrefix:@"notes-boundary"]) ? @"0" : @"1"} mutableCopy];
    BOOL uninstrumented = [label hasPrefix:@"notes-uninstrumented"];
    if ([variant isEqualToString:@"minimal"]) {
        launchEnvironment[@"SUIMT_STANDALONE_REPRO"] = @"1";
    }
    if ([label hasPrefix:@"lifecycle-"]) {
        launchEnvironment[@"SUIMT_LIFECYCLE_PROBE"] = @"1";
        launchEnvironment[@"SUIMT_NATIVE_SCROLL_PROBE"] = @"1";
        launchEnvironment[@"SUIMT_LIFECYCLE_LAYOUT"] = [label substringFromIndex:10];
    }
    if (uninstrumented) {
        for (NSString *key in @[@"SUIMT_CONTEXT_TRACE", @"SUIMT_MANUAL_CAPTURE", @"SUIMT_BOUNDARY_TRACE", @"SUIMT_NATIVE_SCROLL_PROBE", @"SUIMT_LIFECYCLE_PROBE"]) {
            launchEnvironment[key] = @"0";
        }
    }
    if (replayPlan) {
        NSData *planData = [NSJSONSerialization dataWithJSONObject:replayPlan options:NSJSONWritingSortedKeys error:&error];
        XCTAssertNil(error);
        launchEnvironment[@"SUIMT_REPLAY_PLAN"] = [[NSString alloc] initWithData:planData encoding:NSUTF8StringEncoding];
    }
    if (broad) {
        NSDictionary *config = replayPlan[@"fixture"];
        launchEnvironment[@"SUIMT_BROAD_REPLAY"] = @"1";
        if ([variant hasPrefix:@"nativeFlick"]) {
            launchEnvironment[@"SUIMT_NATIVE_FLICK_CONTROL"] = @"1";
            launchEnvironment[@"SUIMT_NATIVE_FLICK_SCALED"] = [variant isEqualToString:@"nativeFlickControl"] ? @"0" : @"1";
            launchEnvironment[@"SUIMT_NATIVE_FLICK_HEADER_SCROLL"] = [variant isEqualToString:@"nativeFlickHeaderScrollControl"] ? @"1" : @"0";
        }
        if ([replayPlan[@"family"] hasPrefix:@"flick"]) {
            launchEnvironment[@"SUIMT_TOUCH_ROUTING"] = @"1";
        }
        launchEnvironment[@"SUIMT_FLICK_FIXTURE"] = [config[@"flickFixture"] boolValue] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_PHASE_SWITCH"] = [config[@"phaseSwitch"] boolValue] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_FLICK_CONTEXT_READOUT"] = [variant isEqualToString:@"flickContextReadout"] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_INITIAL_TAB"] = config[@"initialTab"];
        launchEnvironment[@"SUIMT_SYNC_MODE"] = config[@"mode"];
        launchEnvironment[@"SUIMT_NATIVE_EDGE"] = [config[@"native"] boolValue] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_ROW_COUNT"] = [config[@"rowCount"] stringValue];
        launchEnvironment[@"SUIMT_EXTERNAL_POSITION"] = [config[@"externalPosition"] boolValue] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_NATIVE_REFERENCE"] = [config[@"nativeReference"] boolValue] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_VISUAL_PATTERN"] = [replayPlan[@"family"] isEqualToString:@"visual"] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_TITLE_HEIGHT"] = [@(titleHeight) stringValue];
        launchEnvironment[@"SUIMT_MIN_TITLE_HEIGHT"] = [(config[@"minimumTitleHeight"] ?: @0) stringValue];
    }
    launchEnvironment[@"SUIMT_PASSIVE_TRACE_PATH"] = passiveTracePath;
    if ([NSProcessInfo.processInfo.environment[@"SUIMT_XCODE_PLAN"] isEqualToString:@"1"]) {
        launchEnvironment[@"SUIMT_HANDOFF_ONLY"] = @"1";
    }
    NSData *profileData = [NSJSONSerialization dataWithJSONObject:viewportProfile options:0 error:&error];
    XCTAssertNil(error);
    launchEnvironment[@"SUIMT_FIXTURE_VIEWPORT"] = [[NSString alloc] initWithData:profileData encoding:NSUTF8StringEncoding];
    app.launchEnvironment = launchEnvironment;
    [app launch];
    if ([replayPlan[@"captureInitial"] boolValue]) {
        XCTAttachment *initial = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
        initial.name = @"Initial page before first input";
        initial.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:initial];
    }
    // Query time is INSIDE fixed wait budgets, not added on top. The no-query
    // control waits equally long. Actual touch timing is checked from app logs.
    double startupDeadline = NSProcessInfo.processInfo.systemUptime + (experiment ? 2.0 : 0.0);
    if ([label isEqualToString:@"notes-uninstrumented-idle"]) startupDeadline += 5;
    if ([variant isEqualToString:@"oldQueries"]) {
        double start = NSProcessInfo.processInfo.systemUptime;
        BOOL exists = [app.buttons[@"Overview"] waitForExistenceWithTimeout:10];
        [queries addObject:@{@"kind": @"exists", @"phase": @"before", @"start": @(start),
                            @"end": @(NSProcessInfo.processInfo.systemUptime), @"exists": @(exists)}];
        XCTAssertTrue(exists);
    }
    if ([variant isEqualToString:@"before"] || [variant isEqualToString:@"oldQueries"]) {
        [self queryHeader:app phase:@"before" events:queries];
    }
    if (experiment && NSProcessInfo.processInfo.systemUptime > startupDeadline + 0.02) deadlineOverrun = YES;
    [self waitUntilUptime:startupDeadline];
    XCTAssertTrue([XCUIDevice.sharedDevice respondsToSelector:@selector(eventSynthesizer)]);
    id synthesizer = XCUIDevice.sharedDevice.eventSynthesizer;
    XCTAssertTrue([synthesizer respondsToSelector:@selector(synthesizeEvent:completion:)]);
    double previousEnd = 0;
    NSUInteger segmentIndex = 0;
    for (NSDictionary *segment in segments) {
        if ([segment[@"alreadySent"] boolValue]) {
            previousEnd = [segment[@"end"] doubleValue];
            segmentIndex++;
            continue;
        }
        double pause = [segment[@"start"] doubleValue] - previousEnd;
        if (pause > 0) {
            // XCTest compressed the idle gap between separate pointer paths in
            // one event record. Preserve it explicitly, without any UI query.
            NSLog(@"MANUAL_REPLAY requested inter-gesture pause=%.6f", pause);
            double deadline = NSProcessInfo.processInfo.systemUptime + pause;
            NSString *checkpoint = replayPlan ? replayPlan[@"steps"][segmentIndex][@"screenshotBefore"] : nil;
            if (checkpoint) {
                XCTAttachment *capture = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
                capture.name = checkpoint;
                capture.lifetime = XCTAttachmentLifetimeKeepAlways;
                [self addAttachment:capture];
            }
            if (([label hasPrefix:@"recorded-nonadjacent"] || uninstrumented) && segmentIndex == 3) {
                XCTAttachment *departure = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
                departure.name = @"Notes before leaving (screen-only capture)";
                departure.lifetime = XCTAttachmentLifetimeKeepAlways;
                [self addAttachment:departure];
            }
            if ([variant isEqualToString:@"between"] || [variant isEqualToString:@"oldQueries"]) {
                [self queryHeader:app phase:@"between" events:queries];
            }
            if ([variant isEqualToString:@"screenshotBetween"] || [variant isEqualToString:@"oldQueries"]
                || [variant isEqualToString:@"screenScreenshotBetween"]) {
                double start = NSProcessInfo.processInfo.systemUptime;
                BOOL screenOnly = [variant isEqualToString:@"screenScreenshotBetween"];
                [queryScreenshots addObject:screenOnly ? XCUIScreen.mainScreen.screenshot : app.screenshot];
                [queries addObject:@{@"kind": screenOnly ? @"screenScreenshot" : @"appScreenshot", @"phase": @"between", @"start": @(start),
                                    @"end": @(NSProcessInfo.processInfo.systemUptime)}];
            }
            if (broad && segmentIndex > 0 && ![replayPlan[@"steps"][segmentIndex - 1][@"skipCheckpointAfter"] boolValue]) {
                // Capture the preceding action AFTER settling, before another
                // input can mask it. Screen-only: never query the app hierarchy.
                // Use the existing idle budget and record capture timing so an
                // overrun is visible rather than silently changing the replay.
                NSDictionary *completedStep = replayPlan[@"steps"][segmentIndex - 1];
                double checkpointDelay = completedStep[@"checkpointDelay"] ? [completedStep[@"checkpointDelay"] doubleValue] : 0.5;
                [self waitUntilUptime:deadline - MAX(0, pause - checkpointDelay)];
                double captureStart = NSProcessInfo.processInfo.systemUptime;
                XCTAttachment *capture = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
                capture.name = [NSString stringWithFormat:@"After step %02lu %@ target %@ — %@",
                    (unsigned long)segmentIndex, completedStep[@"kind"], completedStep[@"tab"] ?: @"unchanged", label];
                capture.lifetime = XCTAttachmentLifetimeKeepAlways;
                [self addAttachment:capture];
                [queries addObject:@{@"kind": @"screenScreenshot", @"phase": @"checkpoint",
                    @"completedStep": @(segmentIndex), @"start": @(captureStart),
                    @"end": @(NSProcessInfo.processInfo.systemUptime), @"nextInputDeadline": @(deadline)}];
            }
            if (NSProcessInfo.processInfo.systemUptime > deadline + 0.02) deadlineOverrun = YES;
            [self waitUntilUptime:deadline];
        }
        if ([variant isEqualToString:@"elementTap"] && previousEnd > 0) {
            double start = NSProcessInfo.processInfo.systemUptime;
            [app.buttons[@"Overview"] tap];
            double end = NSProcessInfo.processInfo.systemUptime;
            [queries addObject:@{@"kind": @"elementTap", @"phase": @"tapResolution", @"start": @(start), @"end": @(end)}];
            [dispatches addObject:@{@"sentAt": @(start), @"completedAt": @(end)}];
            previousEnd = [segment[@"end"] doubleValue];
            continue;
        }
        XCTestExpectation *finished = [self expectationWithDescription:@"Recorded input segment delivered"];
        __block BOOL successful = NO;
        __block NSError *synthesisError = nil;
        id inputRecord = segment[@"record"];
        NSDictionary *step = replayPlan ? replayPlan[@"steps"][segmentIndex] : nil;
        if (broad && [step[@"dynamicY"] boolValue] && ![variant hasPrefix:@"nativeFlick"]) {
            // Only reads an already-observed context; no AX lookup, view
            // construction, forced layout, selection, or scroll command.
            [self savePassiveTrace];
            NSError *readError = nil;
            NSData *data = [NSData dataWithContentsOfFile:passiveTracePath];
            XCTAssertNotNil(data, @"Missing passive trace handoff");
            NSDictionary *report = [NSJSONSerialization JSONObjectWithData:data options:0 error:&readError];
            XCTAssertNil(readError);
            if (segmentIndex == 0) {
                // This handoff already occurs before a dynamic first tap. If
                // native startup geometry disagrees, capture BEFORE that tap
                // can change it. No extra query, wait, or save on valid runs.
                NSDictionary *sample = [report[@"nativeScrollSnapshots"] lastObject];
                double width = [sample[@"windowWidth"] doubleValue];
                NSMutableArray *pagers = [NSMutableArray array];
                for (NSDictionary *scroll in sample[@"scrolls"]) {
                    if (fabs([scroll[@"frameX"] doubleValue]) <= 0.5 &&
                        fabs([scroll[@"boundsWidth"] doubleValue] - width) <= 0.5 &&
                        fabs([scroll[@"contentWidth"] doubleValue] - 3 * width) <= 0.5) [pagers addObject:scroll];
                }
                NSUInteger initialIndex = [@[@"overview", @"activity", @"notes"] indexOfObject:replayPlan[@"fixture"][@"initialTab"]];
                NSDictionary *pager = pagers.firstObject;
                double observed = [pager[@"offsetX"] doubleValue] + [pager[@"insetLeft"] doubleValue];
                BOOL valid = width > 0 && initialIndex != NSNotFound && pagers.count == 1 &&
                    isfinite(observed) && fabs(observed - initialIndex * width) <= 0.5;
                if (!valid) {
                    XCTAttachment *trace = [XCTAttachment attachmentWithData:data uniformTypeIdentifier:@"public.json"];
                    trace.name = @"Initial page mismatch trace before any input";
                    trace.lifetime = XCTAttachmentLifetimeKeepAlways;
                    [self addAttachment:trace];
                    XCTAttachment *capture = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
                    capture.name = @"Initial page mismatch screen before any input";
                    capture.lifetime = XCTAttachmentLifetimeKeepAlways;
                    [self addAttachment:capture];
                    XCTFail(@"Initial native pager geometry disagrees with requested page before any input. Inspect saved screen before classifying behavior.");
                    return;
                }
            }
            NSDictionary *headerContext = nil;
            for (NSDictionary *value in [report[@"context"][@"events"] reverseObjectEnumerator]) {
                if ([value[@"kind"] isEqualToString:@"viewContext"] && [value[@"consumer"] isEqualToString:@"header"]) {
                    headerContext = value;
                    break;
                }
            }
            XCTAssertNotNil(headerContext, @"No observed header for gesture placement");
            CGFloat y = collapsedTop + titleHeight - [headerContext[@"headerOffset"] doubleValue] + 18;
            CGFloat x = [step[@"x"] doubleValue] * fixtureWidth / 402;
            XCTAssertTrue(isfinite(y) && y > 0 && y < fixtureHeight);
            id path = [[pathClass alloc] initForTouchAtPoint:CGPointMake(x, y) offset:0];
            [path liftUpAtOffset:0.05];
            inputRecord = [[recordClass alloc] initWithName:@"Trace-positioned tab tap" interfaceOrientation:UIInterfaceOrientationPortrait];
            [inputRecord addPointerEventPath:path];
        }
        double sentAt = NSProcessInfo.processInfo.systemUptime;
        [synthesizer synthesizeEvent:inputRecord completion:^(BOOL success, NSError *failure) {
            successful = success;
            synthesisError = failure;
            [finished fulfill];
        }];
        [self waitForExpectations:@[finished] timeout:20];
        [dispatches addObject:@{@"sentAt": @(sentAt), @"completedAt": @(NSProcessInfo.processInfo.systemUptime)}];
        XCTAssertTrue(successful, @"%@", synthesisError);
        if ([variant isEqualToString:@"planned"] &&
            ( [step[@"kind"] isEqualToString:@"left"] || [step[@"kind"] isEqualToString:@"right"] )) {
            [self waitForHorizontalPagingAtPath:passiveTracePath events:queries];
        }
        previousEnd = [segment[@"end"] doubleValue];
        segmentIndex++;
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

    if (!uninstrumented) {
        [self savePassiveTrace];
        if (!experiment) {
            NSData *traceData = [NSData dataWithContentsOfFile:passiveTracePath];
            XCTAssertNotNil(traceData);
            XCTAttachment *trace = [XCTAttachment attachmentWithData:traceData uniformTypeIdentifier:@"public.json"];
            trace.name = [@"Complete recorded trace " stringByAppendingString:label];
            trace.lifetime = XCTAttachmentLifetimeKeepAlways;
            [self addAttachment:trace];
        }
    }

    XCTAttachment *image = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    image.name = [@"After replay " stringByAppendingString:label];
    image.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:image];
    // First accessibility query occurs AFTER the whole input sequence.
    if ([variant isEqualToString:@"minimal"]) {
        // Diagnostic assertion: confirms the bug is reproducible, NOT correct behavior.
        XCTAssertTrue(app.buttons[@"Count: 0"].exists, @"The minimal iOS 27 reset was not reproduced");
        return;
    }
    BOOL nativeReference = [replayPlan[@"fixture"][@"nativeReference"] boolValue];
    // A native-only control has no SUIMT selector. Its own measured header
    // geometry and actual scroll offsets are checked by the offline reader.
    CGFloat top = nativeReference ? 0 : app.buttons[@"Overview"].frame.origin.y;
    NSDictionary *result = @{@"label": label, @"variant": variant, @"experiment": @(experiment),
                             @"deadlineOverrun": @(deadlineOverrun), @"queries": queries, @"dispatches": dispatches,
                             @"overviewTop": @(top), @"expectedTop": @(expectedTop)};
    NSData *resultData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingSortedKeys error:nil];
    NSLog(@"QUERY_ABLATION %@", [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
    XCTAttachment *metadata = [XCTAttachment attachmentWithData:resultData uniformTypeIdentifier:@"public.json"];
    metadata.name = [@"query-ablation-" stringByAppendingString:label];
    metadata.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:metadata];
    for (XCUIScreenshot *screenshot in queryScreenshots) {
        XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:screenshot];
        attachment.name = [@"between-gesture-" stringByAppendingString:label];
        attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:attachment];
    }
    NSLog(@"MANUAL_REPLAY points=%lu duration=%.6f overviewTop=%.3f expected=%.3f",
          (unsigned long)samples.count, previousTime, top, expectedTop);
    if (!experiment && !nativeReference) {
        XCTAssertEqualWithAccuracy(top, expectedTop, expectedTopTolerance, @"Tab selection must preserve the shared header position");
    }
    if (!experiment && !uninstrumented) {
        NSData *traceData = [NSData dataWithContentsOfFile:passiveTracePath];
        XCTAssertNotNil(traceData, @"Missing completed trace: validation must not be skipped");
        NSString *failure = [SUIMTRecordedTraceValidation validateData:traceData label:label];
        XCTAssertNil(failure, @"%@", failure);
    }
    // The validated snapshot is attached to the Xcode result; teardown removes
    // only this test's uniquely named temporary handoff file.
}
@end
