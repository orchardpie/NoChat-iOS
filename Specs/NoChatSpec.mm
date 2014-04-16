#import "NoChat.h"
#import "NCWebService.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NoChatSpec)

describe(@"NoChat", ^{
    __block NoChat *noChat = nil;

    beforeEach(^{
        noChat = [[NoChat alloc] initWithDelegate:nil];
    });

    describe(@"-webService", ^{
        it(@"should not be nil", ^{
            noChat.webService should_not be_nil;
        });
    });
});

SPEC_END
