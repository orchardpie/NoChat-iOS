#import <Cedar/SpecHelper.h>
#import "NoChat.h"

using namespace Cedar::Doubles;

NoChat *noChat;

@interface NCSpecHelper : NSObject; @end

@implementation NCSpecHelper

+ (void)beforeEach {
    noChat = [[NoChat alloc] init];
    spy_on(noChat);
}

@end
