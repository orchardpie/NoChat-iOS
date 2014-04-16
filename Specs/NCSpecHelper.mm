#import <Cedar/SpecHelper.h>
#import "NoChat.h"

using namespace Cedar::Doubles;

NoChat *noChat;

@interface NCSpecHelper : NSObject; @end

@implementation NCSpecHelper

+ (void)beforeEach {
    noChat = [[NoChat alloc] initWithDelegate:nil];
    spy_on(noChat);
}

@end
