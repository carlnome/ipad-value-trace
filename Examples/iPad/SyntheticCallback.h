#import <Foundation/Foundation.h>
#if VT_PUBLIC_BLOCK_DEMO
typedef void (^VTDemoSyntheticCapture)(NSInteger input, BOOL fromCache);
NSInteger VTDemoRunSyntheticCallback(NSInteger input, BOOL fromCache, NSUInteger *calls, VTDemoSyntheticCapture capture);
#endif
