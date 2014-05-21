#import "NCWebService.h"
#import "NoChat+App.h"

#if DEBUG
static NSString * const BASE_SCHEME = @"http";
static NSString * const BASE_HOST = @"localhost";
static const int BASE_PORT = 3000;
#else
static NSString * const BASE_SCHEME = @"https";
static NSString * const BASE_HOST = @"nochat-dev.herokuapp.com";
static const int BASE_PORT = 443;
#endif

typedef void(^AFSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^AFFailureBlock)(NSURLSessionDataTask *task, NSError *error);

@interface NCWebService ()

@end

@implementation NCWebService

- (instancetype)init
{
    if (self = [super initWithBaseURL:self.baseURL sessionConfiguration:self.sessionConfiguration]) {
        __weak __typeof(self)weakSelf = self;
        self.responseSerializer.acceptableStatusCodes = nil;
        [self setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential) {
            if (!challenge.previousFailureCount) {
                return NSURLSessionAuthChallengePerformDefaultHandling;
            } else {
                NSURLCredentialStorage * credentialStore = NSURLCredentialStorage.sharedCredentialStorage;
                [credentialStore removeCredential:challenge.proposedCredential forProtectionSpace:weakSelf.protectionSpace];
                return NSURLSessionAuthChallengeRejectProtectionSpace;
            }
        }];
    }
    return self;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept": @"application/json" }];

    return sessionConfiguration;
}

- (void)saveCredentialWithEmail:(NSString *)email
                       password:(NSString *)password
{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:email
                                                             password:password
                                                          persistence:NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
                                                        forProtectionSpace:self.protectionSpace];
}

- (BOOL)hasCredential
{
    return !![[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:self.protectionSpace];
}

- (void)setAuthTokenIfInsideResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
    NSString *authToken = httpURLResponse.allHeaderFields[@"X-User-Token"];

    if (authToken && authToken.length > 0) {
        [self.requestSerializer setValue:authToken forHTTPHeaderField:@"X-User-Token"];
    }
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                   completion:(WebServiceCompletion)completion
                      invalid:(WebServiceInvalid)invalid
                        error:(WebServiceError)error {

    return [super GET:URLString parameters:parameters success:[self successWithCompletion:completion invalid:invalid error:error]
                                                      failure:[self failureWithErrorCompletion:error]];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                    completion:(WebServiceCompletion)completion
                       invalid:(WebServiceInvalid)invalid
                         error:(WebServiceError)error {

    return [super POST:URLString parameters:parameters success:[self successWithCompletion:completion invalid:invalid error:error]
                                                       failure:[self failureWithErrorCompletion:error]];
}

#pragma mark - Private interface

- (NSURL *)baseURL
{
    NSString *hostAndPort = [NSString stringWithFormat:@"%@:%d", BASE_HOST, BASE_PORT];
    return [[NSURL alloc] initWithScheme:BASE_SCHEME host:hostAndPort path:@"/"];
}

- (NSURLProtectionSpace *)protectionSpace
{
    return [[NSURLProtectionSpace alloc] initWithHost:BASE_HOST
                                                 port:BASE_PORT
                                             protocol:BASE_SCHEME
                                                realm:@"Application"
                                 authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
}

- (AFSuccessBlock)successWithCompletion:(WebServiceCompletion)completion
                                invalid:(WebServiceInvalid)invalid
                                  error:(WebServiceError)error
{
    return ^(NSURLSessionDataTask *task, id responseObject) {
        [self setAuthTokenIfInsideResponse:task.response];

        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        switch (response.statusCode) {
            case 200 ... 299:
                if (completion) { completion(responseObject); }
                break;
            case 422:
                if (invalid) { invalid(responseObject); }
                break;
            case 401:
                [noChat userDidFailAuthentication];
                break;
            default: {
                NSError *anError = [NSError errorWithDomain:@"com.nochat.mobile"
                                                       code:0
                                                   userInfo:@{ NSLocalizedRecoverySuggestionErrorKey: @"A thousand apologies, but an error occurred" }];
                if (error) { error(anError); }
            }
                break;
        }
    };
}

- (AFFailureBlock)failureWithErrorCompletion:(WebServiceError)completion
{
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) { completion(error); }
    };
}

@end
