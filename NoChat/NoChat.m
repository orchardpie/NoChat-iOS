#import "NoChat.h"
#import "NCWebService.h"

@interface NoChat ()

@property (strong, nonatomic, readwrite) NCWebService *webService;
@property (weak, nonatomic) id<NoChatDelegate> delegate;

@end

@implementation NoChat

- (instancetype)initWithDelegate:(id)delegate
{
    if (self = [super init]) {
        self.webService = [[NCWebService alloc] init];
        self.delegate = delegate;
    }
    return self;
}

- (void)invalidateCurrentUser
{
    [self.webService clearAllCredentials];
    [self.delegate userDidSwitchToLogin];
}

@end
