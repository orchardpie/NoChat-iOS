#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCMessage.h"
#import "NCMessagesCollection.h"

static NSString const *EMAIL_KEY                    = @"email";
static NSString const *PASSWORD_KEY                 = @"password";
static NSString const *PASSWORD_CONFIRMATION_KEY    = @"password_confirmation";

@implementation NCCurrentUser

- (BOOL)saveCredentialWithEmail:(NSString *)email password:(NSString *)password
{
    [noChat.webService saveCredentialWithEmail:email password:password];

    return YES;
}

- (void)fetchWithSuccess:(void(^)())success
                 failure:(void(^)(NSError *error))failure
{
    [noChat.webService GET:@"/" parameters:nil completion:^(id responseBody) {
        [self setMessagesFromResponse:responseBody];
        if (success) { success(); }

    } invalid:nil error:failure];
}

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void(^)())success
                failure:(void(^)(NSError *error))failure
{
    NSDictionary *parameters = @{ @"user":@{ EMAIL_KEY : email,
                                             PASSWORD_KEY : password,
                                             PASSWORD_CONFIRMATION_KEY : password } };

    [noChat.webService POST:@"/users" parameters:parameters completion:^(id responseBody) {
        [noChat.webService saveCredentialWithEmail:email password:password];

        [self setMessagesFromResponse:responseBody];
        if (success) { success(); }

    } invalid:^(id responseBody) {
        if (failure) {
            NSDictionary *responseDict = (NSDictionary *)responseBody;
            NSDictionary *errors = responseDict[@"errors"];
            NSString *errorMessage = errors[errors.allKeys[0]][0];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorMessage};
            NSError *error = [NSError errorWithDomain:@"com.nochat.mobile" code:0 userInfo:userInfo];

            failure(error);
        }
    } error:failure];
}

- (void)setMessagesFromResponse:(id)responseObject
{
    NSDictionary *responseDict = (NSDictionary *)responseObject;
    NSArray *responseMessages = responseDict[@"messages"][@"resource"];

    if (responseMessages && responseMessages.count > 0) {
        NSMutableArray *messages = [NSMutableArray array];

        for (NSDictionary *messageDict in responseMessages) {
            [messages addObject:[[NCMessage alloc] initWithDictionary:messageDict]];
        }

        self.messages = [[NCMessagesCollection alloc] initWithLocation:@"/messages" messages:messages];
    }
}

@end
