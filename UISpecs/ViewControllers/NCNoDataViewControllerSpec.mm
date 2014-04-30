#import "NCNoDataViewController.h"
#import "NoChat.h"
#import "NCCurrentUser.h"
#import "NCAppDelegate.h"
#import "UIAlertView+Spec.h"
#import "MBProgressHUD+Spec.h"
#import "AFSpecWorking/SpecHelpers.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCNoDataViewControllerSpec)

describe(@"NCNoDataViewController", ^{
    __block NCNoDataViewController *controller;
    __block NCCurrentUser *currentUser;
    __block id<NCAuthenticatable> delegate;

    beforeEach(^{
        currentUser = [[NCCurrentUser alloc] init];
        delegate = nice_fake_for([NCAppDelegate class]);
        controller = [[NCNoDataViewController alloc] initWithCurrentUser:currentUser delegate:delegate];

        controller.view should_not be_nil;
    });

    describe(@"outlets", ^{
        describe(@"retryButton", ^{
            it(@"should exist", ^{
                controller.retryButton should_not be_nil;
            });
        });
    });

    describe(@"-didTapRetryButton:", ^{
        subjectAction(^{ [controller.retryButton sendActionsForControlEvents:UIControlEventTouchUpInside]; });

        beforeEach(^{
            spy_on(currentUser);
        });

        it(@"should refresh the current user", ^{
            currentUser should have_received("fetchWithSuccess:failure:");
        });

        it(@"should disable the retry button", ^{
            controller.retryButton.enabled should_not be_truthy;
        });

        it(@"should display a progress HUD", ^{
            MBProgressHUD.currentHUD should_not be_nil;
        });
    });

    describe(@"on response to the current user refresh", ^{
        __block NSURLSessionDataTask *task;
        __block NSError *error;

        subjectAction(^{ [task completeWithError:error]; });

        beforeEach(^{
            [controller.retryButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            task = noChat.webService.tasks.firstObject;
        });

        context(@"on success response", ^{
            beforeEach(^{
                [task receiveResponse:makeResponse(200)];
                [task receiveData:dataFromResponseFixtureWithFileName(@"get_fetch_user_response_200.json")];
                error = nil;
            });

            it(@"should call userDidAuthenticate on delegate", ^{
                delegate should have_received("userDidAuthenticate");
            });
        });

        describe(@"on failure response", ^{
            beforeEach(^{
                [task receiveResponse:makeResponse(500)];
                error = nil;
            });

            it(@"should not display an alert", ^{
                UIAlertView.currentAlertView should_not be_nil;
            });

            it(@"should enable the retry button", ^{
                controller.retryButton.enabled should be_truthy;
            });

            it(@"should hide the progress HUD", ^{
                MBProgressHUD.currentHUD should be_nil;
            });
        });

        describe(@"on network error", ^{
            beforeEach(^{
                error = [NSError errorWithDomain:@"Some error domain" code:4 userInfo:@{ NSLocalizedRecoverySuggestionErrorKey: @"Try again" }];
            });

            it(@"should display the error in an alert view", ^{
                UIAlertView *alertView = UIAlertView.currentAlertView;
                alertView.title should equal(error.localizedDescription);
                alertView.message should equal(error.localizedRecoverySuggestion);
            });

            it(@"should enable the retry button", ^{
                controller.retryButton.enabled should be_truthy;
            });

            it(@"should hide the progress HUD", ^{
                MBProgressHUD.currentHUD should be_nil;
            });
        });
    });
});

SPEC_END
