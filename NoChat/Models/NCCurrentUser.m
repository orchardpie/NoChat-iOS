#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCMessage.h"

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
           serverFailure:(WebServiceInvalid)serverFailure
          networkFailure:(WebServiceError)networkFailure
{
    [noChat.webService GET:@"/" parameters:nil completion:^(id responseBody) {
        [self setMessagesFromResponse:responseBody];
        if (success) { success(); }

    } invalid:serverFailure error:networkFailure];
}

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void(^)())success
          serverFailure:(WebServiceInvalid)serverFailure
         networkFailure:(WebServiceError)networkFailure
{
    NSDictionary *parameters = @{ @"user":@{ EMAIL_KEY : email,
                                             PASSWORD_KEY : password,
                                             PASSWORD_CONFIRMATION_KEY : password } };

    [noChat.webService POST:@"/users" parameters:parameters completion:^(id responseBody) {
        [noChat.webService saveCredentialWithEmail:email password:password];

        [self setMessagesFromResponse:responseBody];
        if (success) { success(); }

    } invalid:serverFailure error:networkFailure];
}

- (void)setMessagesFromResponse:(id)responseObject
{
    NSDictionary *responseDict = (NSDictionary *)responseObject;
    NSArray *responseMessages = responseDict[@"messages"];

    if (responseMessages && responseMessages.count > 0) {
        NSMutableArray *messages = [NSMutableArray array];

        for (NSDictionary *messageDict in responseMessages) {
            [messages addObject:[[NCMessage alloc] initWithDictionary:messageDict]];
        }

        self.messages = messages;
    }
}

@end
