#import "NCWebService.h"

#if DEBUG
static NSString * const BASE_SCHEME = @"http";
static NSString * const BASE_HOST = @"localhost";
static const int BASE_PORT = 3000;
#else
static NSString * const BASE_SCHEME = @"https";
static NSString * const BASE_HOST = @"nochat-dev.herokuapp.com";
static const int BASE_PORT = 443;
#endif

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

- (void)clearAllCredentials
{
    NSURLCredentialStorage *credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
    NSDictionary *credentials = [credentialStorage credentialsForProtectionSpace:self.protectionSpace];

    for (NSString *key in credentials.allKeys) {
        [credentialStorage removeCredential:credentials[key] forProtectionSpace:self.protectionSpace];
    }
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
                      success:(WebServiceSuccess)success
                serverFailure:(WebServiceServerFailure)serverFailure
               networkFailure:(WebServiceNetworkFailure)networkFailure {

    return [super GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self setAuthTokenIfInsideResponse:task.response];
        success(responseObject);
    } failure:[self requestFailureWithServerFailure:serverFailure andNetworkFailure:networkFailure]];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(WebServiceSuccess)success
                 serverFailure:(WebServiceServerFailure)serverFailure
                networkFailure:(WebServiceNetworkFailure)networkFailure {

    return [super POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self setAuthTokenIfInsideResponse:task.response];
        success(responseObject);
    } failure:[self requestFailureWithServerFailure:serverFailure andNetworkFailure:networkFailure]];
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

- (AFFailureBlock)requestFailureWithServerFailure:(WebServiceServerFailure)serverFailure
                                andNetworkFailure:(WebServiceNetworkFailure)networkFailure
{
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *failureResponse = (NSHTTPURLResponse *)task.response;

        if (failureResponse) {
            if (serverFailure) { serverFailure(@"There was a problem with the NoChat server. Please try again later."); }
        } else {
            if (networkFailure) { networkFailure(error); }
        }
    };
}

@end
