#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCWebService.h"
#import "NCMessage.h"

@interface NCCurrentUser ()

@end

@implementation NCCurrentUser

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password
{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:email
                                                 password:password
                                              persistence:NSURLCredentialPersistencePermanent];
    [noChat.webService setCredential:credential];

    return YES;
}

- (void)fetch:(UserFetchSuccess)success
serverFailure:(WebServiceServerFailure)serverFailure
networkFailure:(WebServiceNetworkFailure)networkFailure
{
    [noChat.webService GET:@"/" parameters:nil success:^(id responseBody) {
        [self setMessagesFromResponse:responseBody];
        if (success) { success(self); }

    } serverFailure:serverFailure networkFailure:networkFailure];
}

- (void)setMessagesFromResponse:(id)responseObject
{
    NSMutableArray *messagesArray = [NSMutableArray array];
    for (NSDictionary *messageDict in (NSArray *)responseObject) {
        [messagesArray addObject:[[NCMessage alloc] initWithDictionary:messageDict]];
    }

    self.messages = messagesArray;
}

@end
