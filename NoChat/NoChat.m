#import "NoChat.h"
#import "NCWebService.h"


void NCParameterAssert(id parameter) {
    if (!parameter) { @throw @"NULL parameter!"; }
}

@interface NoChat ()

@property (strong, nonatomic, readwrite) NCWebService *webService;

@end

@interface NoChat (QuietCompiler)

- (void)userDidSwitchToLogin;

@end

@implementation NoChat

- (instancetype)init
{
    if (self = [super init]) {
        self.webService = [[NCWebService alloc] init];
    }
    return self;
}

- (void)invalidateCurrentUser
{
    [self.webService clearAllCredentials];
    [self userDidSwitchToLogin];
}

@end
