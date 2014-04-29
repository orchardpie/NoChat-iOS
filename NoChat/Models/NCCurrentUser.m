#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCMessage.h"
#import "NCMessagesCollection.h"

static NSString const *EMAIL_KEY                    = @"email";
static NSString const *PASSWORD_KEY                 = @"password";
static NSString const *PASSWORD_CONFIRMATION_KEY    = @"password_confirmation";

@interface NCCurrentUser ()
@property (nonatomic, strong, readwrite) NCMessagesCollection *messages;
@end

@implementation NCCurrentUser

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.messages = [decoder decodeObjectForKey:@"messages"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.messages forKey:@"messages"];
}

- (BOOL)saveCredentialWithEmail:(NSString *)email password:(NSString *)password
{
    [noChat.webService saveCredentialWithEmail:email password:password];

    return YES;
}

- (void)fetchWithSuccess:(void(^)())success
                 failure:(void(^)(NSError *error))failure
{
    [noChat.webService GET:@"/" parameters:nil completion:^(id responseBody) {
        NSDictionary *currentUserDict = (NSDictionary *)responseBody;
        self.messages = [[NCMessagesCollection alloc] initWithMessagesDict:currentUserDict[@"data"][@"messages"]];
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
        NSDictionary *currentUserDict = (NSDictionary *)responseBody;
        self.messages = [[NCMessagesCollection alloc] initWithMessagesDict:currentUserDict[@"data"][@"messages"]];
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

@end
