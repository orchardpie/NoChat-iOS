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

        it(@"should set signup view as the root view controller", ^{
            delegate.window.rootViewController should be_instance_of([UINavigationController class]);
            UINavigationController *navController = (id)delegate.window.rootViewController;
            navController.topViewController should be_instance_of([NCSignupViewController class]);
        });
    });

    describe(@"-userDidSwitchToLogin", ^{
        beforeEach(^{
            [delegate userDidSwitchToLogin];
        });


    });

    describe(@"-userDidAuthenticate", ^{
        beforeEach(^{
            [delegate userDidAuthenticate];
        });

        it(@"should do something", PENDING);
    });
});

SPEC_END
