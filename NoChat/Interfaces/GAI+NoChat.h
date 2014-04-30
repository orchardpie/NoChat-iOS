#import "GAI.h"

@interface GAI (NoChat)

- (void)initializeGAI;
- (void)sendAction:(NSString *)action
      withCategory:(NSString *)category;

@end
