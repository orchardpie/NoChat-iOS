#if TARGET_OS_IPHONE
#import <Cedar-iOS/Cedar-iOS.h>
#else
#import <Cedar/SpecHelper.h>
#endif
#import "NoChat.h"

using namespace Cedar::Doubles;

NoChat *noChat;

NSHTTPURLResponse *makeResponse(int statusCode)
{
    NSDictionary *headerFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
    NSURL *url = [NSURL URLWithString:@"/"];

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                              statusCode:statusCode
                                                             HTTPVersion:@"1.0"
                                                            headerFields:headerFields];
    return response;
}

NSData *dataFromResponseFixtureWithFileName(NSString *fileName) {
    NSString *userFixturePath = [NSString stringWithFormat:@"%@/%@", FIXTURES_DIR, fileName];
    return [NSData dataWithContentsOfFile:userFixturePath options:0 error:nil];
}

id validJSONFromResponseFixtureWithFileName(NSString *fileName) {
    NSData *data = dataFromResponseFixtureWithFileName(fileName);
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@interface NCSpecHelper : NSObject; @end

@implementation NCSpecHelper

+ (void)beforeEach {
    noChat = [[NoChat alloc] init];
    spy_on(noChat);
}

@end
