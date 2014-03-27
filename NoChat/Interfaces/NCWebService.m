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

typedef void(^AFSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^AFFailureBlock)(NSURLSessionDataTask *task, NSError *error);

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
    return !!self.credential;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(AFSuccessBlock)success
                      failure:(AFFailureBlock)failure {
    [self.requestSerializer setValue:self.authToken forHTTPHeaderField:@"X-User-Token"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    __weak NCWebService *this = self;
    __block BOOL respondedToChallenge = NO;
    [self setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential) {
        if (!respondedToChallenge) {
            respondedToChallenge = YES;

            *credential = this.credential;
            return NSURLSessionAuthChallengeUseCredential;
        } else {
            return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }];

    return [super GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(task, responseObject);
    } failure:failure];

    return nil;
}

#pragma mark Private interface

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
                                                realm:nil
                                 authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
}

- (NSURLCredential *)credential
{
    return [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:self.protectionSpace];
}

@end
