#import <Foundation/Foundation.h>

@class NCCurrentUser;

typedef void(^UserLoginCompletion)(NCCurrentUser *user, NSError *error);

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NSString *name;

+ (void)logInWithEmail:(NSString *)email andPassword:(NSString *)password completion:(UserLoginCompletion)completion;
- (instancetype)initWithDictionary:(NSDictionary *)userDict;
- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password;

@end
