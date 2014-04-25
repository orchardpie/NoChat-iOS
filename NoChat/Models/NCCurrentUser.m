#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCMessage.h"
#import "NCMessagesCollection.h"

static NSString const *EMAIL_KEY                    = @"email";
static NSString const *PASSWORD_KEY                 = @"password";
static NSString const *PASSWORD_CONFIRMATION_KEY    = @"password_confirmation";

@implementation NCCurrentUser

- (id)init
{
    if (self = [super init]) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];
        if (data.length) {
            [self unarchiveWithData:data];
        }
    }
    return self;
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

- (void)unarchiveWithData:(NSData *)data
{
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.messages = [decoder decodeObjectForKey:@"messages"];
    [decoder finishDecoding];
}

- (void)archive
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [encoder encodeObject:self.messages forKey:@"messages"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [encoder finishEncoding];

    [userDefaults setObject:data forKey:@"currentUser"];
    [userDefaults synchronize];
}

@end
