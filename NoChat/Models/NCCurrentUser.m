#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCMessage.h"
#import "NCMessagesCollection.h"
#import "NCErrors.h"
#import "NCAnalytics.h"

static NSString const *EMAIL_KEY                    = @"email";
static NSString const *PASSWORD_KEY                 = @"password";
static NSString const *PASSWORD_CONFIRMATION_KEY    = @"password_confirmation";

@interface NCCurrentUser ()
@property (nonatomic, strong, readwrite) NCMessagesCollection *messages;
@property (nonatomic, strong) NSString *deviceRegistrationsLocation;
@end

@implementation NCCurrentUser

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.messages = [decoder decodeObjectForKey:@"messages"];
        self.deviceRegistrationsLocation = [decoder decodeObjectForKey:@"deviceRegistrationsLocation"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.messages forKey:@"messages"];
    [encoder encodeObject:self.deviceRegistrationsLocation forKey:@"deviceRegistrationsLocation"];
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
        self.deviceRegistrationsLocation = currentUserDict[@"data"][@"device_registrations"][@"location"];
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
            NSError *error = [[NCErrors alloc] initWithJSONObject:responseBody].error;
            [noChat.analytics sendAction:@"Error Signup" withCategory:@"Account" andError:error];

            failure(error);
        }
    } error:failure];
}

- (void)registerDeviceToken:(NSData *)deviceToken
{
    if (!self.deviceRegistrationsLocation) {
        @throw @"Cannot register device with incomplete CurrentUser definition";
    }
    [noChat.webService POST:self.deviceRegistrationsLocation
                 parameters:@{ @"device_registration": @{ @"token": deviceToken } }
                 completion:nil
                    invalid:nil
                      error:nil];
}

@end
