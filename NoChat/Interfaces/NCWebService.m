#import "NCWebService.h"

#if DEBUG
static NSString * const BASE_SCHEME = @"http";
static NSString * const BASE_HOST = @"localhost";
static const int BASE_PORT = 3000;
#else
static NSString * const BASE_SCHEME = @"https";
static NSString * const BASE_HOST = @"nochat.herokuapp.com";
static const int BASE_PORT = 0;
#endif

@interface NCWebService ()

@property (strong, nonatomic) NSString *authToken;

@end

@implementation NCWebService

- (instancetype)init
{
    return [super initWithBaseURL:self.baseURL];
}

- (void)setCredential:(NSURLCredential *)credential
{
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
                                                        forProtectionSpace:self.protectionSpace];
}

- (BOOL)hasCredential
{
    return !![[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:self.protectionSpace];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(WebServiceSuccess)success
                serverFailure:(WebServiceServerFailure)serverFailure
               networkFailure:(WebServiceNetworkFailure)networkFailure {
    [self.requestSerializer setValue:self.authToken forHTTPHeaderField:@"X-User-Token"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [self setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential) {
        if (!challenge.previousFailureCount) {
            return NSURLSessionAuthChallengePerformDefaultHandling;
        } else {
            return NSURLSessionAuthChallengeRejectProtectionSpace;
        }
    }];

    return [super GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        // Set authorization token from headers
        success(responseObject);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *failureResponse = (NSHTTPURLResponse *)task.response;

        if ([failureResponse statusCode] == 401) { return; }

        [failureResponse statusCode] ? serverFailure(@"failure from response body") : networkFailure(error);
    }];
}

#pragma mark - Private interface

- (NSURL *)baseURL
{
    NSString *hostAndPort = BASE_HOST;
    if (BASE_PORT) {
        hostAndPort = [NSString stringWithFormat:@"%@:%d", hostAndPort, BASE_PORT];
    }
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

@end
