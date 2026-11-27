@import XCTest;

@interface ValueTraceSmokeTests : XCTestCase
@end

@implementation ValueTraceSmokeTests

- (void)testEqualDisplayValuesKeepTheirOwnSourceAndRule {
    XCUIApplication *app = [XCUIApplication new];
    [app launch];

    XCUIElement *first = app.buttons[@"fixture.capacity"];
    XCTAssertTrue([first waitForExistenceWithTimeout:10]);
    XCTAssertEqualObjects(first.label, @"75%");
    [first tap];
    XCTAssertTrue([app.staticTexts[@"demo.snapshot.capacity"] exists]);
    XCTAssertTrue([app.staticTexts[@"round(used / total * 100)"] exists]);

    XCUIElement *second = app.buttons[@"fixture.score"];
    XCTAssertEqualObjects(second.label, @"75%");
    [second tap];
    XCTAssertTrue([app.staticTexts[@"demo.snapshot.score"] exists]);
    XCTAssertTrue([app.staticTexts[@"round(score * 100)"] exists]);
    XCTAssertFalse([app.staticTexts[@"demo.snapshot.capacity"] exists]);
}

- (void)keepScreenshot:(NSString *)name {
    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = name;
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

- (void)testSyntheticBlockCaptureIsOptInAndDoesNotReplayCallback {
    XCUIApplication *app = [XCUIApplication new];
    [app launch];
    XCTAssertTrue([app.buttons[@"fixture.capacity"] waitForExistenceWithTimeout:10]);
    XCUIElement *run = app.buttons[@"synthetic.run"];
#if VT_PUBLIC_BLOCK_DEMO
    XCTAssertTrue([run waitForExistenceWithTimeout:5]);
    XCUIElement *toggle = app.buttons[@"synthetic.capture"];
    XCUIElement *result = app.staticTexts[@"synthetic.result"];
    XCUIElement *evidence = app.staticTexts[@"synthetic.evidence"];
    [run tap];
    XCTAssertEqualObjects(result.label, @"result=12 calls=1");
    XCTAssertEqualObjects(evidence.label, @"events=0");
    [self keepScreenshot:@"01-default-off"];

    [toggle tap];
    [run tap];
    XCTAssertEqualObjects(result.label, @"result=14 calls=2");
    XCTAssertEqualObjects(evidence.label, @"events=1 input=7 cache=NO");
    [run tap];
    XCTAssertEqualObjects(result.label, @"result=17 calls=3");
    XCTAssertEqualObjects(evidence.label, @"events=2 input=8 cache=YES");
    [self keepScreenshot:@"02-two-captured-events"];

    [toggle tap];
    [run tap];
    XCTAssertEqualObjects(result.label, @"result=18 calls=4");
    XCTAssertEqualObjects(evidence.label, @"events=2 input=8 cache=YES");
    [self keepScreenshot:@"03-disabled-no-new-event"];
#else
    XCTAssertFalse(run.exists);
    XCTAssertFalse(app.buttons[@"synthetic.capture"].exists);
    [self keepScreenshot:@"release-no-probe-controls"];
#endif
}
@end
