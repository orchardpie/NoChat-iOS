#import <Foundation/Foundation.h>
#import "NCWebService.h"

@class NCCurrentUser;

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *messages;

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password;

- (void)fetchWithSuccess:(void(^)())success
           serverFailure:(WebServiceServerFailure)serverFailure
          networkFailure:(WebServiceNetworkFailure)networkFailure;

- (void)signUpWithSuccess:(void(^)())success
            serverFailure:(WebServiceServerFailure)serverFailure
           networkFailure:(WebServiceNetworkFailure)networkFailure;

@end
