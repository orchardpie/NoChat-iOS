#import <Foundation/Foundation.h>

@interface NCAnalytics : NSObject

- (void)sendAction:(NSString *)action
      withCategory:(NSString *)category;

@end
