#import "NCAppDelegate.h"
#import "NCSignupViewController.h"
#import "NCMessagesTableViewController.h"
#import "NoChat.h"
#import "NCWebService+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCAppDelegateSpec)

describe(@"NCAppDelegate", ^{
    __block NCAppDelegate *delegate;

    beforeEach(^{
        delegate = [[NCAppDelegate alloc] init];
    });

    describe(@"application:didFinishLaunchingWithOptions", ^{
        subjectAction(^{
            [delegate application: nil didFinishLaunchingWithOptions: nil];
        });

        it(@"should initialize a global NoChat object", ^{
            noChat should_not be_nil;
        });

        context(@"when the current user has credentials", ^{
            beforeEach(^{
                [NCWebService setHasCredentialTo:YES];
            });

            it(@"should set messages table view controller as the root view controller", ^{
                delegate.window.rootViewController should be_instance_of([UINavigationController class]);
                UINavigationController *navController = (id)delegate.window.rootViewController;
                navController.topViewController should be_instance_of([NCMessagesTableViewController class]);
            });
        });

        context(@"when the current user has no credentials", ^{
            beforeEach(^{
                [NCWebService setHasCredentialTo:NO];
            });

            it(@"should set signup view as the root view controller", ^{
                delegate.window.rootViewController should be_instance_of([UINavigationController class]);
                UINavigationController *navController = (id)delegate.window.rootViewController;
                navController.topViewController should be_instance_of([NCSignupViewController class]);
            });
        });
    });

    describe(@"-userDidSwitchToLogin", ^{
        subjectAction(^{
            [delegate userDidSwitchToLogin];
        });

        it(@"should show the login view", PENDING);
    });

    describe(@"-userDidSwitchToSignup", ^{
        subjectAction(^{
            [delegate userDidSwitchToSignup];
        });

        it(@"should show the signup view", PENDING);
    });

    describe(@"-userDidAuthenticate", ^{
        beforeEach(^{
            [delegate userDidAuthenticate];
        });

        it(@"should do something", PENDING);
    });
});

SPEC_END
