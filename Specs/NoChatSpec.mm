#import "NoChat.h"
#import "NCWebService.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NoChatSpec)

describe(@"NoChat", ^{
    __block NoChat *noChat = nil;

    beforeEach(^{
        noChat = [[NoChat alloc] init];
    });

    describe(@"-webService", ^{
        it(@"should not be nil", ^{
            noChat.webService should_not be_nil;
        });
    });

    describe(@"-analytics", ^{
        it(@"should not be nil", ^{
            noChat.analytics should_not be_nil;
        });
    });

    describe(@"-addressBook", ^{
        it(@"should not be nil", ^{
            noChat.addressBook should_not be_nil;
        });
    });
});

SPEC_END
