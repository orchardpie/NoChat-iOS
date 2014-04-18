#import "NoChat.h"
#import "NCWebService.h"
#import "NCAppDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NoChatSpec)

describe(@"NoChat", ^{
    __block NoChat *noChat = nil;

    beforeEach(^{
        noChat = [[NoChat alloc] init];

        spy_on(noChat.webService);
    });

    describe(@"-invalidateCurrentUser", ^{
        subjectAction(^{ [noChat invalidateCurrentUser]; });

        it(@"should invalidate stored credentials", ^{
            noChat.webService should have_received("clearAllCredentials");
        });
    });
});

SPEC_END
