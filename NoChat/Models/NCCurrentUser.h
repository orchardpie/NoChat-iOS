#import <Foundation/Foundation.h>

@class NCCurrentUser;

typedef void(^UserFetchCompletion)(NCCurrentUser *currentUser, NSError *error);

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *messages;

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password;

- (void)fetch:(UserFetchCompletion)completion;

@end
