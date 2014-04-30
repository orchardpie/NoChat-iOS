#import "NoChat.h"
#import "NCWebService.h"
#import "NCAnalytics.h"

void NCParameterAssert(id parameter) {
    if (!parameter) { @throw @"NULL parameter!"; }
}

@interface NoChat ()

@property (strong, nonatomic, readwrite) NCWebService *webService;
@property (strong, nonatomic, readwrite) NCAnalytics *analytics;

@end

@interface NoChat (QuietCompiler)

- (void)userDidSwitchToLogin;

@end

@implementation NoChat

- (instancetype)init
{
    if (self = [super init]) {
        self.webService = [[NCWebService alloc] init];
        self.analytics = [[NCAnalytics alloc] init];
    }
    return self;
}

- (void)invalidateCurrentUser
{
    [self.webService clearAllCredentials];
    [self userDidSwitchToLogin];
}

@end
