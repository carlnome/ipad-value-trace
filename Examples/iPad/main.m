#import <UIKit/UIKit.h>
#import <ValueTraceKit/ValueTraceKit.h>
#import <math.h>
#if VT_PUBLIC_BLOCK_DEMO
#import "SyntheticCallback.h"
#endif

@interface ValueTraceExampleController : UIViewController
@end

@implementation ValueTraceExampleController {
    NSArray<VTValueEvidence *> *_evidence;
    UILabel *_sourceLabel;
    UILabel *_ruleLabel;
#if VT_PUBLIC_BLOCK_DEMO
    UILabel *_callbackResult;
    UILabel *_callbackEvidence;
    NSMutableArray<VTValueEvidence *> *_callbackEvents;
    NSInteger _callbackInput;
    NSUInteger _callbackCalls;
    BOOL _captureEnabled;
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    const double used = 3.0, total = 4.0, score = 0.75;
    _evidence = @[
        [[VTValueEvidence alloc] initWithFieldID:@"fixture.capacity"
                                  displayValue:[NSString stringWithFormat:@"%ld%%", lround(used / total * 100.0)]
                                        source:@"demo.snapshot.capacity"
                                          rule:@"round(used / total * 100)"],
        [[VTValueEvidence alloc] initWithFieldID:@"fixture.score"
                                  displayValue:[NSString stringWithFormat:@"%ld%%", lround(score * 100.0)]
                                        source:@"demo.snapshot.score"
                                          rule:@"round(score * 100)"]
    ];

    UILabel *title = [UILabel new];
    title.text = @"Value Trace";
    title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    UILabel *instruction = [UILabel new];
    instruction.text = @"Select either value to see its recorded source and rule.";
    instruction.numberOfLines = 0;
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[title, instruction]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [stack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:24]
    ]];

    [_evidence enumerateObjectsUsingBlock:^(VTValueEvidence *record, NSUInteger index, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:record.displayValue forState:UIControlStateNormal];
        button.accessibilityIdentifier = record.fieldID;
        button.tag = (NSInteger)index;
        [button addTarget:self action:@selector(showEvidence:) forControlEvents:UIControlEventTouchUpInside];
        [button.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
        [stack addArrangedSubview:button];
    }];

    _sourceLabel = [UILabel new];
    _ruleLabel = [UILabel new];
    _sourceLabel.numberOfLines = 0;
    _ruleLabel.numberOfLines = 0;
    [stack addArrangedSubview:_sourceLabel];
    [stack addArrangedSubview:_ruleLabel];
#if VT_PUBLIC_BLOCK_DEMO
    _callbackInput = 6;
    _callbackEvents = [NSMutableArray new];
    UIButton *toggle = [UIButton buttonWithType:UIButtonTypeSystem];
    toggle.accessibilityIdentifier = @"synthetic.capture";
    [toggle setTitle:@"Enable capture" forState:UIControlStateNormal];
    [toggle addTarget:self action:@selector(toggleCapture:) forControlEvents:UIControlEventTouchUpInside];
    [toggle.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    [stack addArrangedSubview:toggle];

    UIButton *run = [UIButton buttonWithType:UIButtonTypeSystem];
    run.accessibilityIdentifier = @"synthetic.run";
    [run setTitle:@"Run callback" forState:UIControlStateNormal];
    [run addTarget:self action:@selector(runCallback) forControlEvents:UIControlEventTouchUpInside];
    [run.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    [stack addArrangedSubview:run];

    _callbackResult = [UILabel new];
    _callbackResult.text = @"calls=0";
    _callbackResult.accessibilityIdentifier = @"synthetic.result";
    _callbackEvidence = [UILabel new];
    _callbackEvidence.text = @"events=0";
    _callbackEvidence.accessibilityIdentifier = @"synthetic.evidence";
    [stack addArrangedSubview:_callbackResult];
    [stack addArrangedSubview:_callbackEvidence];
#endif
}

#if VT_PUBLIC_BLOCK_DEMO
- (void)toggleCapture:(UIButton *)sender {
    _captureEnabled = !_captureEnabled;
    [sender setTitle:_captureEnabled ? @"Disable capture" : @"Enable capture" forState:UIControlStateNormal];
}

- (void)runCallback {
    NSInteger input = _callbackInput++;
    NSMutableArray<VTValueEvidence *> *events = _callbackEvents;
    VTDemoSyntheticCapture capture = nil;
    if (_captureEnabled) capture = ^(NSInteger capturedValue, BOOL fromCache) {
            NSString *value = [NSString stringWithFormat:@"input=%ld cache=%@", (long)capturedValue, fromCache ? @"YES" : @"NO"];
            [events addObject:[[VTValueEvidence alloc] initWithFieldID:@"synthetic.callback"
               displayValue:value source:@"synthetic.callback.entry" rule:@"input*2 + cache"]];
    };
    NSInteger result = VTDemoRunSyntheticCallback(input, input == 8, &_callbackCalls, capture);
    _callbackResult.text = [NSString stringWithFormat:@"result=%ld calls=%lu",
                            (long)result, (unsigned long)_callbackCalls];
    _callbackEvidence.text = events.count == 0 ? @"events=0" :
        [NSString stringWithFormat:@"events=%lu %@", (unsigned long)events.count, events.lastObject.displayValue];
}
#endif

- (void)showEvidence:(UIButton *)sender {
    VTValueEvidence *record = _evidence[(NSUInteger)sender.tag];
    _sourceLabel.text = record.source;
    _ruleLabel.text = record.rule;
}
@end

@interface ValueTraceSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation ValueTraceSceneDelegate
- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) { return; }
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = [ValueTraceExampleController new];
    [self.window makeKeyAndVisible];
}
@end

@interface ValueTraceAppDelegate : UIResponder <UIApplicationDelegate>
@end

@implementation ValueTraceAppDelegate
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(ValueTraceAppDelegate.class));
    }
}
