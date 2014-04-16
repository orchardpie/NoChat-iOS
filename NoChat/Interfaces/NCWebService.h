#import "AFHTTPSessionManager.h"

@interface NCWebService : AFHTTPSessionManager

typedef void(^WebServiceSuccess)(id responseBody);
typedef void(^WebServiceServerFailure)(NSString *failureMessage);
typedef void(^WebServiceNetworkFailure)(NSError *error);

- (void)saveCredentialWithEmail:(NSString *)email
                       password:(NSString *)password;
- (BOOL)hasCredential;
- (void)clearAllCredentials;

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(WebServiceSuccess)success
                serverFailure:(WebServiceServerFailure)serverFailure
               networkFailure:(WebServiceNetworkFailure)networkFailure;
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(WebServiceSuccess)success
                 serverFailure:(WebServiceServerFailure)serverFailure
                networkFailure:(WebServiceNetworkFailure)networkFailure;

@end
