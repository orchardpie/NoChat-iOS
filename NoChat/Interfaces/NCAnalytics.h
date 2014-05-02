#import <Foundation/Foundation.h>

@interface NCAnalytics : NSObject

- (void)sendAction:(NSString *)action
      withCategory:(NSString *)category
          andError:(NSError *)error;

- (void)sendAction:(NSString *)action
      withCategory:(NSString *)category;

@end
