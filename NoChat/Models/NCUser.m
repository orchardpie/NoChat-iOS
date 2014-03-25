#import "NCUser.h"

@implementation NCUser

+ (void)logInWithEmail:(NSString *)email andPassword:(NSString *)password completion:(UserLoginCompletion)completion
{
    NCUser *user = nil;
    NSError *error = [[NSError alloc] init];

    if (completion) { completion(user, error); }
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)userDict
{
    if (!userDict) { @throw @"User dictionary not supplied."; }
    if (self = [super init]) {
        self.name = [userDict objectForKey:@"name"];
    }
    return self;
}

@end
