#import "NCMessage.h"
#import "NoChat.h"

@interface NCMessage () <NSCoding>

@end

@implementation NCMessage

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.messageId = dictionary[@"id"];
        self.createdAt = dictionary[@"created_at"];
        self.timeSavedDescription = dictionary[@"time_saved_description"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.messageId = [decoder decodeObjectForKey:@"messageId"];
    self.createdAt = [decoder decodeObjectForKey:@"createdAt"];
    self.timeSavedDescription = [decoder decodeObjectForKey:@"timeSavedDescription"];
    self.body = [decoder decodeObjectForKey:@"body"];
    self.receiverEmail = [decoder decodeObjectForKey:@"receiverEmail"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.messageId forKey:@"messageId"];
    [encoder encodeObject:self.createdAt forKey:@"createdAt"];
    [encoder encodeObject:self.timeSavedDescription forKey:@"timeSavedDescription"];
    [encoder encodeObject:self.body forKey:@"body"];
    [encoder encodeObject:self.receiverEmail forKey:@"receiverEmail"];
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
            NSString *errorMessage = errors[errors.allKeys[0]][0];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorMessage};
            NSError *error = [NSError errorWithDomain:@"com.nochat.mobile" code:0 userInfo:userInfo];

            failure(error);
        }
    };
}

@end
