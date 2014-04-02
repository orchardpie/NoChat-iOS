#import <Foundation/Foundation.h>

@class NCCurrentUser;

typedef void(^UserFetchSuccessBlock)(NCCurrentUser *currentUser);
typedef void(^UserFetchFailureBlock)(NSError *error);

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *messages;

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password;

- (void)fetch:(UserFetchSuccessBlock)success failure:(UserFetchFailureBlock)failure;

@end
