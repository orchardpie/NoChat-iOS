#import "NoChat.h"
#import "NCWebService.h"

@interface NoChat ()

@property (strong, nonatomic, readwrite) NCWebService *webService;

@end

@implementation NoChat

- (instancetype)init
{
    if (self = [super init]) {
        self.webService = [[NCWebService alloc] init];
    }
    return self;
}

@end
