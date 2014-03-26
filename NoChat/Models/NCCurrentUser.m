#import "NCCurrentUser.h"

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

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password
{
    return YES;
}

@end
