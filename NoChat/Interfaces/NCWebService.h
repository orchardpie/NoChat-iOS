#import "AFHTTPSessionManager.h"

@interface NCWebService : AFHTTPSessionManager

typedef void(^WebServiceCompletion)(id responseBody);
typedef void(^WebServiceInvalid)(id responseBody);
typedef void(^WebServiceError)(NSError *error);

- (void)saveCredentialWithEmail:(NSString *)email
                       password:(NSString *)password;
- (BOOL)hasCredential;

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                   completion:(WebServiceCompletion)completion
                      invalid:(WebServiceInvalid)invalid
                        error:(WebServiceError)error;
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                    completion:(WebServiceCompletion)completion
                       invalid:(WebServiceInvalid)invalid
                         error:(WebServiceError)error;

@end
