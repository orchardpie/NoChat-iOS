#import "NCMessage.h"
#import "NoChat.h"

@implementation NCMessage

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.time_saved = dictionary[@"time_saved"];
    }
    return self;
}

- (void)saveWithSuccess:(void(^)())success
          serverFailure:(WebServiceInvalid)serverFailure
         networkFailure:(WebServiceError)networkFailure
{
    NSDictionary *parameters = @{ @"message" : @{
                                          @"receiver_email" : self.receiver_email,
                                          @"body" : self.body } };

    [noChat.webService POST:@"/messages" parameters:parameters
                    completion:success
                    invalid:serverFailure
                    error:networkFailure];
}

@end
