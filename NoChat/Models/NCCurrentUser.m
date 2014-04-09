#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCWebService.h"
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
           serverFailure:(WebServiceServerFailure)serverFailure
          networkFailure:(WebServiceNetworkFailure)networkFailure
{
    [noChat.webService GET:@"/" parameters:nil success:^(id responseBody) {
        [self setMessagesFromResponse:responseBody];
        if (success) { success(self); }

    } serverFailure:serverFailure networkFailure:networkFailure];
}

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void(^)())success
          serverFailure:(WebServiceServerFailure)serverFailure
         networkFailure:(WebServiceNetworkFailure)networkFailure
{
    NSDictionary *parameters = @{ @"user":@{ EMAIL_KEY : email,
                                             PASSWORD_KEY : password,
                                             PASSWORD_CONFIRMATION_KEY : password } };

    [noChat.webService POST:@"/users" parameters:parameters success:^(id responseBody) {
        [noChat.webService saveCredentialWithEmail:email password:password];

        [self setMessagesFromResponse:responseBody];
        if (success) { success(self); }

    } serverFailure:serverFailure networkFailure:networkFailure];
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
