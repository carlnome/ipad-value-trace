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

@end
