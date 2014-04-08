#import <Foundation/Foundation.h>
#import "NCWebService.h"

@class NCCurrentUser;

typedef void(^UserFetchSuccess)(NCCurrentUser *currentUser);

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *messages;

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password;

- (void)fetch:(UserFetchSuccess)success
serverFailure:(WebServiceServerFailure)serverFailure
networkFailure:(WebServiceNetworkFailure)networkFailure;

- (void)create:(UserFetchSuccess)success
 serverFailure:(WebServiceServerFailure)serverFailure
networkFailure:(WebServiceNetworkFailure)networkFailure;

@end
