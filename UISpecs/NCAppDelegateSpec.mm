#import "NCAppDelegate.h"
#import "NCSignupViewController.h"
#import "NCMessagesTableViewController.h"
#import "NoChat.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCAppDelegateSpec)

describe(@"NCAppDelegate", ^{
    __block NCAppDelegate *delegate;

    beforeEach(^{
        delegate = [[NCAppDelegate alloc] init];
    });

    describe(@"application:didFinishLaunchingWithOptions", ^{
        beforeEach(^{
            [delegate application: nil didFinishLaunchingWithOptions: nil];
        });

        it(@"should initialize a global NoChat object", ^{
            noChat should_not be_nil;
        });

        it(@"should set login view as the root view controller", ^{
            delegate.window.rootViewController should be_instance_of([NCSignupViewController class]);
        });
    });
});

SPEC_END
