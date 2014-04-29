#import "NCAppDelegate.h"
#import "NCSignupViewController.h"
#import "NCLoginViewController.h"
#import "NCMessagesTableViewController.h"
#import "NoChat.h"
#import "NCWebService+Spec.h"
#import "UIAlertView+Spec.h"

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
            [delegate application:nil didFinishLaunchingWithOptions:nil];
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

    describe(@"-applicationDidEnterBackground:", ^{
        subjectAction(^{
            [delegate applicationDidEnterBackground:nil];
        });

        beforeEach(^{
            [delegate application:nil didFinishLaunchingWithOptions:@{}];
            spy_on(delegate.currentUser);
        });

        it(@"should archive current user", ^{
            delegate.currentUser should have_received("archive");
        });
    });

    describe(@"-userDidSwitchToLogin", ^{
        subjectAction(^{
            [delegate userDidSwitchToLogin];
        });

        beforeEach(^{
            [delegate application:nil didFinishLaunchingWithOptions:nil];
            UIViewController *otherController = [[NCSignupViewController alloc] initWithCurrentUser:delegate.currentUser delegate:nil];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:otherController];
            delegate.window.rootViewController = navigationController;
        });

        it(@"should show the login screen", ^{
            UINavigationController *navigationController = (id)delegate.window.rootViewController;
            navigationController.topViewController should be_instance_of([NCLoginViewController class]);
        });
    });

    describe(@"-userDidSwitchToSignup", ^{
        subjectAction(^{
            [delegate userDidSwitchToSignup];
        });

        beforeEach(^{
            [delegate application:nil didFinishLaunchingWithOptions:nil];
            UIViewController *otherController = [[NCLoginViewController alloc] initWithCurrentUser:delegate.currentUser delegate:nil];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:otherController];
            delegate.window.rootViewController = navigationController;
        });

        it(@"should show the signup screen", ^{
            UINavigationController *navigationController = (id)delegate.window.rootViewController;
            navigationController.topViewController should be_instance_of([NCSignupViewController class]);
        });
    });

    describe(@"-userDidAuthenticate", ^{
        subjectAction(^{
            [delegate userDidAuthenticate];
        });

        beforeEach(^{
            [delegate application:nil didFinishLaunchingWithOptions:nil];
            NCLoginViewController *otherController = [[NCLoginViewController alloc] initWithCurrentUser:nil delegate:nil];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:otherController];
            delegate.window.rootViewController = navigationController;
        });

        it(@"should show the messages view", ^{
            UINavigationController *navigationController = (id)delegate.window.rootViewController;
            navigationController.topViewController should be_instance_of([NCMessagesTableViewController class]);
        });
    });

    describe(@"-userDidFailAuthentication", ^{
        subjectAction(^{
            [delegate userDidFailAuthentication];
        });

        beforeEach(^{
            [delegate application:nil didFinishLaunchingWithOptions:nil];
        });

        context(@"when the user is on the login screen", ^{
            __block NCLoginViewController *loginVC;

            beforeEach(^{
                loginVC = [[NCLoginViewController alloc] initWithCurrentUser:nil
                                                                    delegate:delegate];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
                delegate.window.rootViewController = navigationController;
                spy_on(loginVC);
            });

            it(@"should alert the user that their credentials are bad", ^{
                loginVC should have_received("badCredentialAlert");
            });
        });

        context(@"when the user is anywhere else in the app", ^{
            beforeEach(^{
                NCMessagesTableViewController *messagesVC = [[NCMessagesTableViewController alloc] initWithMessages:nil];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:messagesVC];
                delegate.window.rootViewController = navigationController;
            });

            it(@"should show the login screen", ^{
                UINavigationController *navigationController = (id)delegate.window.rootViewController;
                navigationController.topViewController should be_instance_of([NCLoginViewController class]);
            });
        });
    });
});

SPEC_END
