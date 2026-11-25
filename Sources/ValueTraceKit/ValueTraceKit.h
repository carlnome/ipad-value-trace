#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Explicit evidence supplied at the binding site, not inferred from view text.
@interface VTValueEvidence : NSObject
@property (nonatomic, copy, readonly) NSString *fieldID;
@property (nonatomic, copy, readonly) NSString *displayValue;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy, readonly) NSString *rule;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithFieldID:(NSString *)fieldID
                   displayValue:(NSString *)displayValue
                         source:(NSString *)source
                           rule:(NSString *)rule NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
