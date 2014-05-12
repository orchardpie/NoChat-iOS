#import "NoChat.h"
#import "NCWebService.h"
#import "NCAnalytics.h"
#import "NCAddressBook.h"

void NCParameterAssert(id parameter) {
    if (!parameter) { @throw @"NULL parameter!"; }
}

@interface NoChat ()

@property (strong, nonatomic, readwrite) NCWebService *webService;
@property (strong, nonatomic, readwrite) NCAnalytics *analytics;
@property (strong, nonatomic, readwrite) NCAddressBook *addressBook;

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
        self.addressBook = [[NCAddressBook alloc] init];
    }
    return self;
}

@end
