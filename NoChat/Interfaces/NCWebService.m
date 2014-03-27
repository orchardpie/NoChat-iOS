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

@end
