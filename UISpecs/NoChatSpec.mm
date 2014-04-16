#import "NoChat.h"
#import "NCWebService.h"
#import "NCAppDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NoChatSpec)

describe(@"NoChat", ^{
    __block NoChat *noChat = nil;
    __block NCAppDelegate<CedarDouble> *delegate = nil;

    beforeEach(^{
        delegate = nice_fake_for([NCAppDelegate class]);
        noChat = [[NoChat alloc] initWithDelegate:delegate];

        spy_on(noChat.webService);
    });

    describe(@"-invalidateCurrentUser", ^{
        subjectAction(^{ [noChat invalidateCurrentUser]; });

        it(@"should invalidate stored credentials", ^{
            noChat.webService should have_received("clearAllCredentials");
        });

        it(@"should ask the app delegate to show the login screen", ^{
            delegate should have_received("userDidSwitchToLogin");
        });
    });
});

SPEC_END
