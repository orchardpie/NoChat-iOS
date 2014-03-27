#import "NCMessage.h"

@implementation NCMessage

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.time_saved = dictionary[@"time_saved"];
        self.disposition = dictionary[@"disposition"];
    }
    return self;
}

@end
