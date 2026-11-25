#import "ValueTraceKit.h"

@implementation VTValueEvidence
- (instancetype)initWithFieldID:(NSString *)fieldID
                   displayValue:(NSString *)displayValue
                         source:(NSString *)source
                           rule:(NSString *)rule {
    self = [super init];
    if (self) {
        _fieldID = [fieldID copy];
        _displayValue = [displayValue copy];
        _source = [source copy];
        _rule = [rule copy];
    }
    return self;
}
@end
