#import <Foundation/Foundation.h>
#import "NCWebService.h"

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *messages;

- (BOOL)saveCredentialWithEmail:(NSString *)email password:(NSString *)password;

- (void)fetchWithSuccess:(void(^)())success
           serverFailure:(WebServiceInvalid)serverFailure
          networkFailure:(WebServiceError)networkFailure;

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void(^)())success
          serverFailure:(WebServiceInvalid)serverFailure
         networkFailure:(WebServiceError)networkFailure;

@end
