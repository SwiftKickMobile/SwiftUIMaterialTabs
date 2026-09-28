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
// Header configurations, scroll modes, and state-preserving tab transitions.
- (void)testHeaderFixedOff { [self replayVariant:@"planned" label:@"header-fixed-off"]; }
- (void)testHeaderRetainedOff { [self replayVariant:@"planned" label:@"header-retained-off"]; }
- (void)testHeaderTitlelessOff { [self replayVariant:@"planned" label:@"header-titleless-off"]; }
- (void)testHeaderFixedOn { [self replayVariant:@"planned" label:@"header-fixed-on"]; }
- (void)testHeaderRetainedOn { [self replayVariant:@"planned" label:@"header-retained-on"]; }
- (void)testHeaderTitlelessOn { [self replayVariant:@"planned" label:@"header-titleless-on"]; }
- (void)testResetPositionOff { [self replayVariant:@"planned" label:@"reset-position-off"]; }
- (void)testResetPositionOn { [self replayVariant:@"planned" label:@"reset-position-on"]; }
- (void)testShortContentOff { [self replayVariant:@"planned" label:@"short-content-off"]; }
- (void)testShortContentOn { [self replayVariant:@"planned" label:@"short-content-on"]; }
- (void)testVisualExpandedHeader { [self replayVariant:@"planned" label:@"visual-expanded-header"]; }
- (void)testVisualNativeReference {
    XCTSkipIf(NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 26, @"Native safeAreaBar reference requires iOS 26+");
    [self replayVariant:@"planned" label:@"visual-native-reference"];
}
- (void)testIssue27ExternalPositionOff { [self replayVariant:@"planned" label:@"issue27-external-position-off"]; }
- (void)testIssue27ExternalPositionOn { [self replayVariant:@"planned" label:@"issue27-external-position-on"]; }
- (void)testFlickSettledOff { [self replayVariant:@"planned" label:@"flick-settled-off"]; }
- (void)testFlickSettledOn { [self replayVariant:@"planned" label:@"flick-settled-on"]; }
- (void)testFlickSwitchOff { [self replayVariant:@"planned" label:@"flick-switch-off"]; }
- (void)testFlickSwitchOn { [self replayVariant:@"planned" label:@"flick-switch-on"]; }
- (void)testMatrixColdTap10ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-expanded-off"]; }
- (void)testMatrixColdTap10PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-partial-off"]; }
- (void)testMatrixColdTap10CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-collapsed-off"]; }
- (void)testMatrixColdTap12ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-expanded-off"]; }
- (void)testMatrixColdTap12PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-partial-off"]; }
- (void)testMatrixColdTap12CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-collapsed-off"]; }
- (void)testMatrixColdTap02ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-expanded-off"]; }
- (void)testMatrixColdTap02PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-partial-off"]; }
- (void)testMatrixColdTap02CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-collapsed-off"]; }
- (void)testMatrixColdTap20ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-expanded-off"]; }
- (void)testMatrixColdTap20PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-partial-off"]; }
- (void)testMatrixColdTap20CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-collapsed-off"]; }
- (void)testMatrixRelativeResettitleTapOff { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-tap-off"]; }
- (void)testMatrixRelativePreserveTapOff { [self replayVariant:@"planned" label:@"matrix-relative-preserve-tap-off"]; }
- (void)testMatrixBottom1TapOff { [self replayVariant:@"planned" label:@"matrix-bottom-1-tap-off"]; }
- (void)testMatrixBottom2TapOff { [self replayVariant:@"planned" label:@"matrix-bottom-2-tap-off"]; }
- (void)testMatrixColdSwipe10ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-expanded-off"]; }
- (void)testMatrixColdSwipe10PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-partial-off"]; }
- (void)testMatrixColdSwipe10CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-collapsed-off"]; }
- (void)testMatrixColdSwipe12ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-expanded-off"]; }
- (void)testMatrixColdSwipe12PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-partial-off"]; }
- (void)testMatrixColdSwipe12CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-collapsed-off"]; }
- (void)testMatrixColdSwipe02ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-expanded-off"]; }
- (void)testMatrixColdSwipe02PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-partial-off"]; }
- (void)testMatrixColdSwipe02CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-collapsed-off"]; }
- (void)testMatrixColdSwipe20ExpandedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-expanded-off"]; }
- (void)testMatrixColdSwipe20PartialOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-partial-off"]; }
- (void)testMatrixColdSwipe20CollapsedOff { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-collapsed-off"]; }
- (void)testMatrixRelativeResettitleSwipeOff { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-swipe-off"]; }
- (void)testMatrixRelativePreserveSwipeOff { [self replayVariant:@"planned" label:@"matrix-relative-preserve-swipe-off"]; }
- (void)testMatrixBottom1SwipeOff { [self replayVariant:@"planned" label:@"matrix-bottom-1-swipe-off"]; }
- (void)testMatrixBottom2SwipeOff { [self replayVariant:@"planned" label:@"matrix-bottom-2-swipe-off"]; }
- (void)testMatrixSeed20260925Off { [self replayVariant:@"planned" label:@"matrix-seed-20260925-off"]; }
- (void)testMatrixSeed927Off { [self replayVariant:@"planned" label:@"matrix-seed-927-off"]; }
- (void)testMatrixSmokeCollapsedTapOff { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-tap-off"]; }
- (void)testMatrixSmokeCollapsedSwipeOff { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-swipe-off"]; }
- (void)testMatrixSmokeReturningOff { [self replayVariant:@"planned" label:@"matrix-smoke-returning-off"]; }
- (void)testMatrixColdTap10ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-expanded-on"]; }
- (void)testMatrixColdTap10PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-partial-on"]; }
- (void)testMatrixColdTap10CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-0-collapsed-on"]; }
- (void)testMatrixColdTap12ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-expanded-on"]; }
- (void)testMatrixColdTap12PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-partial-on"]; }
- (void)testMatrixColdTap12CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-1-2-collapsed-on"]; }
- (void)testMatrixColdTap02ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-expanded-on"]; }
- (void)testMatrixColdTap02PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-partial-on"]; }
- (void)testMatrixColdTap02CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-0-2-collapsed-on"]; }
- (void)testMatrixColdTap20ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-expanded-on"]; }
- (void)testMatrixColdTap20PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-partial-on"]; }
- (void)testMatrixColdTap20CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-tap-2-0-collapsed-on"]; }
- (void)testMatrixRelativeResettitleTapOn { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-tap-on"]; }
- (void)testMatrixRelativePreserveTapOn { [self replayVariant:@"planned" label:@"matrix-relative-preserve-tap-on"]; }
- (void)testMatrixBottom1TapOn { [self replayVariant:@"planned" label:@"matrix-bottom-1-tap-on"]; }
- (void)testMatrixBottom2TapOn { [self replayVariant:@"planned" label:@"matrix-bottom-2-tap-on"]; }
- (void)testMatrixColdSwipe10ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-expanded-on"]; }
- (void)testMatrixColdSwipe10PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-partial-on"]; }
- (void)testMatrixColdSwipe10CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-0-collapsed-on"]; }
- (void)testMatrixColdSwipe12ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-expanded-on"]; }
- (void)testMatrixColdSwipe12PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-partial-on"]; }
- (void)testMatrixColdSwipe12CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-1-2-collapsed-on"]; }
- (void)testMatrixColdSwipe02ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-expanded-on"]; }
- (void)testMatrixColdSwipe02PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-partial-on"]; }
- (void)testMatrixColdSwipe02CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-0-2-collapsed-on"]; }
- (void)testMatrixColdSwipe20ExpandedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-expanded-on"]; }
- (void)testMatrixColdSwipe20PartialOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-partial-on"]; }
- (void)testMatrixColdSwipe20CollapsedOn { [self replayVariant:@"planned" label:@"matrix-cold-swipe-2-0-collapsed-on"]; }
- (void)testMatrixRelativeResettitleSwipeOn { [self replayVariant:@"planned" label:@"matrix-relative-resetTitle-swipe-on"]; }
- (void)testMatrixRelativePreserveSwipeOn { [self replayVariant:@"planned" label:@"matrix-relative-preserve-swipe-on"]; }
- (void)testMatrixBottom1SwipeOn { [self replayVariant:@"planned" label:@"matrix-bottom-1-swipe-on"]; }
- (void)testMatrixBottom2SwipeOn { [self replayVariant:@"planned" label:@"matrix-bottom-2-swipe-on"]; }
- (void)testMatrixSeed20260925On { [self replayVariant:@"planned" label:@"matrix-seed-20260925-on"]; }
- (void)testMatrixSeed927On { [self replayVariant:@"planned" label:@"matrix-seed-927-on"]; }
- (void)testMatrixSmokeCollapsedTapOn { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-tap-on"]; }
- (void)testMatrixSmokeCollapsedSwipeOn { [self replayVariant:@"planned" label:@"matrix-smoke-collapsed-swipe-on"]; }
- (void)testMatrixSmokeReturningOn { [self replayVariant:@"planned" label:@"matrix-smoke-returning-on"]; }
- (void)testNormalDemoLaunch {
    XCUIApplication *demo = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.swiftkickmobile.Demo"];
    demo.launchEnvironment = @{};
    [demo launch];
    XCTAssertTrue([demo.tabBars.buttons[@"Material Tabs"] waitForExistenceWithTimeout:5]);
    XCTAssertTrue(demo.tabBars.buttons[@"Sticky Header"].exists);
    [demo.tabBars.buttons[@"Sticky Header"] tap];
    XCTAssertTrue(demo.tabBars.buttons[@"Sticky Header"].selected);
    XCTAttachment *image = [XCTAttachment attachmentWithScreenshot:demo.screenshot];
    image.name = @"Normal demo — Sticky Header";
    image.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:image];
    [demo terminate];
}
- (void)testQueryFreeColdNotesTap {
    [self replayVariant:@"planned" label:@"cold-notes-tap"];
}
- (void)testQueryFreeNotesFourStep {
    [self replayVariant:@"planned" label:@"notes-four-step"];
}

- (void)testRecordedManualDragAndOverviewTap {
    [self replayVariant:@"none" label:@"recorded-reproduction"];
}

- (void)testRecordedAdjacentExpandedReturn {
    [self replayVariant:@"adjacentReturn" label:@"recorded-adjacent-return"];
}

- (void)testNotesExpansionWithoutOverscroll {
    [self replayVariant:@"nonAdjacentExactReturn" label:@"recorded-nonadjacent-exact-return"];
}

- (void)testQueryFreeExpandedTaps {
    [self replayVariant:@"planned" label:@"expanded-taps"];
}
- (void)testQueryFreePartialTaps {
    [self replayVariant:@"planned" label:@"partial-taps"];
}
- (void)testQueryFreeCollapsedTaps {
    [self replayVariant:@"planned" label:@"collapsed-taps"];
}
- (void)testQueryFreePartialSwipes {
    [self replayVariant:@"planned" label:@"partial-swipes"];
}
- (void)testQueryFreeCollapsedSwipes {
    [self replayVariant:@"planned" label:@"collapsed-swipes"];
}
- (void)testQueryFreeRepeatedHeaderChanges {
    [self replayVariant:@"planned" label:@"repeated-header-changes"];
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

- (void)waitUntilUptime:(double)deadline {
    double remaining = deadline - NSProcessInfo.processInfo.systemUptime;
    if (remaining > 0) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:remaining]];
}

- (void)savePassiveTrace {
    XCTestExpectation *saved = [self expectationWithDescription:@"Passive trace saved"];
    CFNotificationCenterRef notifications = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(notifications, (__bridge void *)saved, SUIMTTraceSaved,
        CFSTR("com.swiftkickmobile.TestHost.manualTraceSaved"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterPostNotification(notifications, CFSTR("com.swiftkickmobile.TestHost.saveManualTrace"), NULL, NULL, true);
    [self waitForExpectations:@[saved] timeout:5];
    CFNotificationCenterRemoveObserver(notifications, (__bridge void *)saved,
        CFSTR("com.swiftkickmobile.TestHost.manualTraceSaved"), NULL);
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

- (void)replayVariant:(NSString *)variant label:(NSString *)label {
    self.continueAfterFailure = NO;
    NSMutableArray *queries = [NSMutableArray array];
    NSMutableArray *dispatches = [NSMutableArray array];
    BOOL deadlineOverrun = NO;
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
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
    if ([variant isEqualToString:@"planned"]) {
        NSData *planData = [SUIMTRecordedTraceValidation scenarioDataAndReturnError:&error];
        XCTAssertNil(error);
        NSDictionary *plans = [NSJSONSerialization JSONObjectWithData:planData options:0 error:&error];
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

    // Fixed, independently calibrated viewport; never query cold tab content.
    NSInteger osMajor = NSProcessInfo.processInfo.operatingSystemVersion.majorVersion;
    CGFloat fixtureWidth = 402;
    CGFloat fixtureHeight = 874;
    CGFloat collapsedTop = osMajor == 18 ? 108.33333333333333 : 124;
    XCTAssertTrue(osMajor == 18 || osMajor == 26 || osMajor == 27);
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


    XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.swiftkickmobile.TestHost"];
    BOOL broad = replayPlan[@"fixture"] != nil;
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
                             @"SUIMT_CAPTURE_LABEL": label,
                             @"SUIMT_BOUNDARY_TRACE": @"1",
                             @"SUIMT_NATIVE_SCROLL_PROBE": @"1"} mutableCopy];
    if (replayPlan) {
        NSData *planData = [NSJSONSerialization dataWithJSONObject:replayPlan options:NSJSONWritingSortedKeys error:&error];
        XCTAssertNil(error);
        launchEnvironment[@"SUIMT_REPLAY_PLAN"] = [[NSString alloc] initWithData:planData encoding:NSUTF8StringEncoding];
    }
    if (broad) {
        NSDictionary *config = replayPlan[@"fixture"];
        launchEnvironment[@"SUIMT_BROAD_REPLAY"] = @"1";
        if ([replayPlan[@"family"] hasPrefix:@"flick"]) {
            launchEnvironment[@"SUIMT_TOUCH_ROUTING"] = @"1";
        }
        launchEnvironment[@"SUIMT_FLICK_FIXTURE"] = [config[@"flickFixture"] boolValue] ? @"1" : @"0";
        launchEnvironment[@"SUIMT_PHASE_SWITCH"] = [config[@"phaseSwitch"] boolValue] ? @"1" : @"0";
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
    double startupDeadline = NSProcessInfo.processInfo.systemUptime;
    [self waitUntilUptime:startupDeadline];
    XCTAssertTrue([XCUIDevice.sharedDevice respondsToSelector:@selector(eventSynthesizer)]);
    id synthesizer = XCUIDevice.sharedDevice.eventSynthesizer;
    XCTAssertTrue([synthesizer respondsToSelector:@selector(synthesizeEvent:completion:)]);
    double previousEnd = 0;
    NSUInteger segmentIndex = 0;
    for (NSDictionary *segment in segments) {
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
            if ([label hasPrefix:@"recorded-nonadjacent"] && segmentIndex == 3) {
                XCTAttachment *departure = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
                departure.name = @"Notes before leaving (screen-only capture)";
                departure.lifetime = XCTAttachmentLifetimeKeepAlways;
                [self addAttachment:departure];
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
        XCTestExpectation *finished = [self expectationWithDescription:@"Recorded input segment delivered"];
        __block BOOL successful = NO;
        __block NSError *synthesisError = nil;
        id inputRecord = segment[@"record"];
        NSDictionary *step = replayPlan ? replayPlan[@"steps"][segmentIndex] : nil;
        if (broad && [step[@"dynamicY"] boolValue]) {
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

    {
        [self savePassiveTrace];
        {
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
    BOOL nativeReference = [replayPlan[@"fixture"][@"nativeReference"] boolValue];
    // A native-only control has no SUIMT selector. Its own measured header
    // geometry and actual scroll offsets are checked by XCTest.
    CGFloat top = nativeReference ? 0 : app.buttons[@"Overview"].frame.origin.y;
    NSDictionary *result = @{@"label": label, @"variant": variant,
                             @"deadlineOverrun": @(deadlineOverrun), @"queries": queries, @"dispatches": dispatches,
                             @"overviewTop": @(top), @"expectedTop": @(expectedTop)};
    NSData *resultData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingSortedKeys error:nil];
    NSLog(@"REPLAY_METADATA %@", [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
    XCTAttachment *metadata = [XCTAttachment attachmentWithData:resultData uniformTypeIdentifier:@"public.json"];
    metadata.name = [@"replay-metadata-" stringByAppendingString:label];
    metadata.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:metadata];
    NSLog(@"MANUAL_REPLAY points=%lu duration=%.6f overviewTop=%.3f expected=%.3f",
          (unsigned long)samples.count, previousTime, top, expectedTop);
    if (!nativeReference) {
        XCTAssertEqualWithAccuracy(top, expectedTop, expectedTopTolerance, @"Tab selection must preserve the shared header position");
    }
    {
        NSData *traceData = [NSData dataWithContentsOfFile:passiveTracePath];
        XCTAssertNotNil(traceData, @"Missing completed trace: validation must not be skipped");
        if ([label hasPrefix:@"issue27-"]) {
            // Check BOTH requested rows independently, even when continuity fails
            // earlier in the sequence. Never hide absent/malformed evidence.
            XCTExpectedFailureOptions *options = [XCTExpectedFailureOptions nonStrictOptions];
            options.issueMatcher = ^BOOL(XCTIssue *issue) {
                return [issue.compactDescription containsString:@"issue27-external-position-"]
                    && [issue.compactDescription containsString:@": FAILURE:"];
            };
            XCTExpectFailureWithOptionsInBlock(@"#27: external-position alignment/context continuity; deferred by maintainer", options, ^{
                NSString *commands = [SUIMTRecordedTraceValidation validateExternalCommandsInData:traceData label:label];
                XCTAssertNil(commands, @"%@", commands);
                NSString *failure = [SUIMTRecordedTraceValidation validateData:traceData label:label];
                XCTAssertNil(failure, @"%@", failure);
            });
        } else {
            NSString *failure = [SUIMTRecordedTraceValidation validateData:traceData label:label];
            XCTAssertNil(failure, @"%@", failure);
        }
    }
    // The validated snapshot is attached to the Xcode result; teardown removes
    // only this test's uniquely named temporary handoff file.
}
@end
