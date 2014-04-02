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

- (void)fetch:(UserFetchSuccessBlock)success failure:(UserFetchFailureBlock)failure
{
    [noChat.webService GET:@"/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self setMessagesFromResponse:responseObject];
        if (success) { success(self); }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) { failure(error); }
    }];
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
