#import "NCSpecHelper.h"
#import "NCAppDelegate.h"
#import "NCAuthenticatable.h"
#import "AFSpecWorking/SpecHelpers.h"
#import "SingleTrack/SpecHelpers.h"
#import "NCCurrentUser.h"
#import "NCMessagesCollection.h"
#import "NCMessage.h"
#import "NCSignupViewController.h"
#import "NCLoginViewController.h"
#import "NCAuthenticatable.h"
#import "NCNoDataViewController.h"
#import "NCMessagesTableViewController.h"
#import "NoChat.h"
#import "NCWebService+Spec.h"
#import "UIAlertView+Spec.h"
#import "NSUserDefaults+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface NCCurrentUser (Spec)

@property (strong, nonatomic, readwrite) NCMessagesCollection *messages;

@end

void setCurrentUserArchive()
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NCCurrentUser *currentUser = [[NCCurrentUser alloc] init];
    [currentUser fetchWithSuccess:nil failure:nil];

    NSURLSessionDataTask *task = noChat.webService.tasks.firstObject;
    NSHTTPURLResponse *response = makeResponse(200);
    NSData *responseData = dataFromResponseFixtureWithFileName(@"get_fetch_user_response_200.json");
    [task completeWithResponse:response data:responseData error:nil];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:currentUser];

    [userDefaults setObject:data forKey:@"currentUser"];
}

SPEC_BEGIN(NCAppDelegateSpec)

describe(@"NCAppDelegate", ^{
    __block NCAppDelegate *delegate;
    __block UIApplication<CedarDouble> *application;

    beforeEach(^{
        delegate = [[NCAppDelegate alloc] init];

        application = fake_for([UIApplication class]);
        application stub_method("registerForRemoteNotificationTypes:");
        application stub_method("setApplicationIconBadgeNumber:");
    });

    describe(@"-application:didFinishLaunchingWithOptions", ^{
        subjectAction(^{
            [delegate application:application didFinishLaunchingWithOptions:nil];
        });

        sharedExamplesFor(@"an action that fetches current user info", ^(NSDictionary *sharedContext) {
            it(@"should fetch from root", ^{
                [[[noChat.webService.tasks.firstObject originalRequest] URL] path] should equal(@"/");
            });

            it(@"should not register for remote notifications", ^{
                application should_not have_received("registerForRemoteNotificationTypes:");
            });
        });

        it(@"should initialize a global NoChat object", ^{
            noChat should_not be_nil;
        });

        context(@"when the current user has credentials", ^{
            beforeEach(^{
                [NCWebService setHasCredentialTo:YES];
            });

            context(@"when the archive version matches the current version", ^{
                beforeEach(^{
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setInteger:ARCHIVE_VERSION forKey:@"archiveVersion"];
                });

                context(@"and there is a current user archive", ^{
                    beforeEach(^{
                        setCurrentUserArchive();
                    });

                    it(@"should create a current user with the archived data", ^{
                        delegate.currentUser.messages should_not be_empty;
                    });

                    it(@"should set messages table view controller as the root view controller", ^{
                        delegate.window.rootViewController should be_instance_of([UINavigationController class]);
                        UINavigationController *navController = (id)delegate.window.rootViewController;
                        navController.topViewController should be_instance_of([NCMessagesTableViewController class]);
                    });

                    it(@"should refresh messages", ^{
                        [noChat.webService.tasks.lastObject originalRequest].URL.path should equal(@"/messages");
                    });

                    it(@"should register for remote notifications", ^{
                        application should have_received("registerForRemoteNotificationTypes:")
                        .with(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert);
                    });
                });
                
                context(@"but there is not a current user archive", ^{
                    beforeEach(^{
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUser"];
                    });

                    itShouldBehaveLike(@"an action that fetches current user info");
                });
            });

            context(@"when the archive version does not match the current version", ^{
                beforeEach(^{
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setInteger:0 forKey:@"archiveVersion"];
                });

                context(@"and there is a current user archive", ^{
                    beforeEach(^{
                        setCurrentUserArchive();
                    });

                    itShouldBehaveLike(@"an action that fetches current user info");
                });

                context(@"but there is not a current user archive", ^{
                    beforeEach(^{
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUser"];
                    });

                    itShouldBehaveLike(@"an action that fetches current user info");
                });
            });
        });

        context(@"when the current user has no credentials", ^{
            beforeEach(^{
                [NCWebService setHasCredentialTo:NO];
            });

            it(@"should not register for remote notifications", ^{
                application should_not have_received("registerForRemoteNotificationTypes:");
            });

            it(@"should set signup view as the root view controller", ^{
                delegate.window.rootViewController should be_instance_of([UINavigationController class]);
                UINavigationController *navController = (id)delegate.window.rootViewController;
                navController.topViewController should be_instance_of([NCSignupViewController class]);
            });
        });
    });

    describe(@"on refresh of the current user", ^{
        __block NSURLSessionDataTask *task;
        __block NSError *error;

        subjectAction(^{ [task completeWithError:error]; });

        beforeEach(^{
            [NCWebService setHasCredentialTo:YES];
            [delegate application:application didFinishLaunchingWithOptions:nil];

            task = noChat.webService.tasks.lastObject;
            task should_not be_nil;
        });

        describe(@"on success response", ^{
            beforeEach(^{
                [task receiveResponse:makeResponse(200)];
                [task receiveData:dataFromResponseFixtureWithFileName(@"get_fetch_user_response_200.json")];
                error = nil;
            });

            it(@"should clear the badge count", ^{
                application should have_received("setApplicationIconBadgeNumber:").with(0);
            });

            it(@"should show the messages view", ^{
                delegate.window.rootViewController should be_instance_of([UINavigationController class]);
                UINavigationController *navController = (id)delegate.window.rootViewController;
                navController.topViewController should be_instance_of([NCMessagesTableViewController class]);
            });

            it(@"should not refresh the messages", ^{
                noChat.webService.tasks should be_empty;
            });

            it(@"should register for remote notifications", ^{
                application should have_received("registerForRemoteNotificationTypes:")
                .with(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert);
            });
        });

        describe(@"on failure response", ^{
            beforeEach(^{
                [task receiveResponse:makeResponse(500)];
                error = nil;
            });

            it(@"should display an error view", ^{
                delegate.window.rootViewController should be_instance_of([NCNoDataViewController class]);
            });

            it(@"should display an alert", ^{
                UIAlertView.currentAlertView should_not be_nil;
            });

            it(@"should not register for remote notifications", ^{
                application should_not have_received("registerForRemoteNotificationTypes:");
            });
        });

        describe(@"on network error", ^{
            beforeEach(^{
                error = [NSError errorWithDomain:@"Some error domain" code:4 userInfo:@{ NSLocalizedRecoverySuggestionErrorKey: @"Try again" }];
            });

            it(@"should display an error view", ^{
                delegate.window.rootViewController should be_instance_of([NCNoDataViewController class]);
            });

            it(@"should display the error in an alert view", ^{
                UIAlertView *alertView = UIAlertView.currentAlertView;
                alertView.title should equal(error.localizedDescription);
                alertView.message should equal(error.localizedRecoverySuggestion);
            });

            it(@"should not register for remote notifications", ^{
                application should_not have_received("registerForRemoteNotificationTypes:");
            });
        });
    });

    describe(@"-applicationDidEnterBackground:", ^{
        subjectAction(^{
            [delegate applicationDidEnterBackground:nil];
        });

        beforeEach(^{
            [delegate application:application didFinishLaunchingWithOptions:@{}];
            spy_on(delegate.currentUser);
        });

        it(@"should set the archive version", ^{
            [[NSUserDefaults standardUserDefaults] integerForKey:@"archiveVersion"] should equal(ARCHIVE_VERSION);
        });

        context(@"when the current user does not have messages", ^{
            beforeEach(^{
                delegate.currentUser.messages should be_nil;
            });

            it(@"should not archive the current user", ^{
                delegate.currentUser should_not have_received("encodeWithCoder:");
            });
        });

        context(@"when the current user has messages", ^{
            beforeEach(^{
                NSDictionary *messagesDict = @{ @"location": @"/messages"};
                delegate.currentUser.messages = [[NCMessagesCollection alloc] initWithMessagesDict:messagesDict];
            });

            it(@"should archive current user", ^{
                delegate.currentUser should have_received("encodeWithCoder:");
            });
        });
    });

    describe(@"application:didRegisterForRemoteNotificationsWithDeviceToken:", ^{
        NSData *deviceToken = [@"nicedevicetoken" dataUsingEncoding:NSUTF8StringEncoding];

        subjectAction(^{
            [delegate application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        });

        beforeEach(^{
            delegate.currentUser = nice_fake_for([NCCurrentUser class]);
        });

        it(@"should attempt to send a device token to the server", ^{
            delegate.currentUser should have_received("registerDeviceToken:").with(deviceToken);
        });
    });

    describe(@"-userDidSwitchToLogin", ^{
        subjectAction(^{
            [delegate userDidSwitchToLogin];
        });

        beforeEach(^{
            [delegate application:application didFinishLaunchingWithOptions:nil];
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
            [delegate application:application didFinishLaunchingWithOptions:nil];
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
            [delegate application:application didFinishLaunchingWithOptions:nil];
            NCLoginViewController *otherController = [[NCLoginViewController alloc] initWithCurrentUser:nil delegate:nil];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:otherController];
            delegate.window.rootViewController = navigationController;
        });

        it(@"should show the messages view", ^{
            UINavigationController *navigationController = (id)delegate.window.rootViewController;
            navigationController.topViewController should be_instance_of([NCMessagesTableViewController class]);
        });

        it(@"should register for remote notifications", ^{
            application should have_received("registerForRemoteNotificationTypes:")
            .with(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert);
        });
    });

    describe(@"-userDidFailAuthentication", ^{
        subjectAction(^{
            [delegate userDidFailAuthentication];
        });

        beforeEach(^{
            [delegate application:application didFinishLaunchingWithOptions:nil];
            spy_on([NSUserDefaults standardUserDefaults]);
        });

        it(@"should clear the current user archive", ^{
            [NSUserDefaults standardUserDefaults] should have_received("removeObjectForKey:").with(@"currentUser");
            [NSUserDefaults standardUserDefaults] should have_received("synchronize");
        });

        it(@"should not register for remote notifications", ^{
            application should_not have_received("registerForRemoteNotificationTypes:");
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
