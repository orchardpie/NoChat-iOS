#import <Foundation/Foundation.h>
#import "NCWebService.h"

@class NCMessagesCollection;

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NCMessagesCollection *messages;

- (BOOL)saveCredentialWithEmail:(NSString *)email password:(NSString *)password;

- (void)fetchWithSuccess:(void(^)())success
                 failure:(void(^)(NSError *error))failure;

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void(^)())success
                failure:(void(^)(NSError *error))failure;

- (void)archive;

@end
