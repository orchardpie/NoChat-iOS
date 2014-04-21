#import "NCMessage.h"
#import "NoChat.h"

@implementation NCMessage

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.timeSaved = dictionary[@"time_saved"];
    }
    return self;
}

- (void)saveWithSuccess:(void(^)())success
         failure:(void(^)(NSError *))failure
{
    NSDictionary *parameters = @{ @"message" : @{
                                          @"receiver_email" : self.receiverEmail,
                                          @"body" : self.body } };

    [noChat.webService POST:@"/messages" parameters:parameters
                    completion:success
                    invalid:[self invalidWithFailure:failure]
                    error:failure];
}

- (WebServiceInvalid)invalidWithFailure:(void(^)(NSError *))failure
{
    return ^(id responseBody) {
        if (failure) {
            NSDictionary *responseDict = (NSDictionary *)responseBody;
            NSDictionary *errors = responseDict[@"errors"];
            NSString *errorMessage = [NSString stringWithFormat:@"%@ %@", errors.allKeys[0], errors[errors.allKeys[0]][0]];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorMessage};
            NSError *error = [NSError errorWithDomain:@"com.nochat.mobile" code:0 userInfo:userInfo];

            failure(error);
        }
    };
}

@end
