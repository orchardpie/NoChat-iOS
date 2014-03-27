#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCWebService.h"

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

@end
