#import "NCCurrentUser.h"

@interface NCCurrentUser ()

@property (strong, nonatomic) NSURLCredential *credential;

@end

@implementation NCCurrentUser

+ (void)logInWithEmail:(NSString *)email andPassword:(NSString *)password completion:(UserLoginCompletion)completion
{
    NCCurrentUser *user = nil;
    NSError *error = [[NSError alloc] init];

    if (completion) { completion(user, error); }
}

- (instancetype)initWithDictionary:(NSDictionary *)userDict
{
    if (!userDict) { @throw @"User dictionary not supplied."; }
    if (self = [super init]) {
        self.name = [userDict objectForKey:@"name"];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password
{
    self.credential = [NSURLCredential credentialWithUser:email
                                                 password:password
                                              persistence:NSURLCredentialPersistencePermanent];
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"localhost"
                                                                                  port:3000
                                                                              protocol:@"http"
                                                                                 realm:nil
                                                                  authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:self.credential
                                                        forProtectionSpace:protectionSpace];

    return YES;
}

@end
