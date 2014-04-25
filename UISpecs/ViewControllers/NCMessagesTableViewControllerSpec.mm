#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"
#import "NCMessage.h"
#import "NCMessagesCollection.h"
#import "NCMessageTableViewCell.h"
#import "NoChat.h"
#import "UIAlertView+Spec.h"
#import "MBProgressHUD+Spec.h"


// Ignore "Unknown selector may cause a leak" warning.  We use performSelector: to
// invoke IBActions, which we know return void.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCMessagesTableViewControllerSpec)

describe(@"NCMessagesTableViewController", ^{
    __block NCMessagesTableViewController *controller;
    __block UINavigationController *navigationController;
    __block NCMessagesCollection *messages;

    beforeEach(^{
        messages = [[NCMessagesCollection alloc] initWithLocation:@"/messages" messages:@[]];
        spy_on(messages);

        controller = [[NCMessagesTableViewController alloc] initWithMessages:messages];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

        controller.view should_not be_nil;
    });

    describe(@"-viewDidLoad", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        it(@"should set the logout button's target to itself", ^{
            controller.navigationItem.leftBarButtonItem.target should equal(controller);
        });

        it(@"should set the compose button's target to itself", ^{
            controller.navigationItem.rightBarButtonItem.target should equal(controller);
        });
    });

    describe(@"-refreshMessages", ^{
        subjectAction(^{ [controller refreshMessages]; });

        it(@"should ask the messages collection to fetch itself", ^{
            messages should have_received("fetchWithSuccess:failure:");
        });

        it(@"should show a progress indicator", ^{
            MBProgressHUD.currentHUD should_not be_nil;
        });

        context(@"when the fetch is successful", ^{
            beforeEach(^{
                messages stub_method("fetchWithSuccess:failure:").and_do(^(NSInvocation *invocation) {
                    void (^fetchBlock)();
                    [invocation getArgument:&fetchBlock atIndex:2];
                    fetchBlock();
                });
                spy_on(controller.tableView);
            });

            it(@"should refresh the tableview", ^{
                controller.tableView should have_received("reloadData");
            });

            it(@"should hide the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });

        });

        context(@"when the fetch is unsuccessful", ^{
            beforeEach(^{
                messages stub_method("fetchWithSuccess:failure:").and_do(^(NSInvocation *invocation) {
                    WebServiceInvalid fetchBlock;
                    [invocation getArgument:&fetchBlock atIndex:3];
                    NSError *error = [NSError errorWithDomain:@"TestErrorDomain" code:-1004 userInfo:@{ NSLocalizedDescriptionKey: @"Could not connect to server",
                                                                                                        NSLocalizedRecoverySuggestionErrorKey: @"Try harder" }];
                    fetchBlock(error);
                });
            });

            it(@"should show an error", ^{
                UIAlertView.currentAlertView should_not be_nil;
                UIAlertView.currentAlertView.title should_not be_nil;
                UIAlertView.currentAlertView.message should_not be_nil;
            });

            it(@"should hide the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });
        });
    });

    describe(@"-tableView:tableView:cellForRowAtIndexPath:", ^{
        subjectAction(^{
            NCMessageTableViewCell *cell = (NCMessageTableViewCell *)[controller.tableView cellForRowAtIndexPath:nil];

            it(@"should set the time saved label", ^{
                cell.timeSavedLabel.text should_not be_nil;
            });

            it(@"should set the created at label", ^{
                cell.createdAtLabel.text should_not be_nil;
            });
        });
    });

    describe(@"-logout button action", ^{
        __block UIBarButtonItem *logoutButton;

        subjectAction(^{
            [logoutButton.target performSelector:logoutButton.action withObject:logoutButton];
        });

        beforeEach(^{
            controller.view should_not be_nil;

            logoutButton = controller.navigationItem.leftBarButtonItem;
        });

        it(@"should log out the current user", ^{
            noChat should have_received("invalidateCurrentUser");
        });
    });

    describe(@"-composeMessage button action", ^{
        __block UIBarButtonItem *composeButton;

        subjectAction(^{
            [composeButton.target performSelector:composeButton.action withObject:composeButton];
        });

        beforeEach(^{
            controller.view should_not be_nil;
            composeButton = controller.navigationItem.rightBarButtonItem;
        });


        it(@"should push to a NCComposeMessageViewController", ^{
            controller.presentedViewController should be_instance_of([NCComposeMessageViewController class]);
        });
    });

    describe(@"ComposeMessageViewControllerDelegate methods", ^{
        describe(@"composeMessageVCCloseButtonTapped", ^{
            subjectAction(^{
                [controller composeMessageVCCloseButtonTapped];
            });

            beforeEach(^{
                [controller presentViewController:[[UIViewController alloc] init] animated:NO completion:nil];
            });

            it(@"should dismiss the compose message modal", ^{
                controller.presentedViewController should be_nil;
            });
        });

        describe(@"userDidSendMessage", ^{
            __block NCMessage *message;

            subjectAction(^{
                [controller userDidSendMessage:message];
            });

            beforeEach(^{
                message = [[NCMessage alloc] init];
                [controller presentViewController:[[UIViewController alloc] init] animated:NO completion:nil];
            });

            it(@"should dismiss the compose message modal", ^{
                controller.presentedViewController should be_nil;
            });
        });
    });
});

SPEC_END

#pragma clang diagnostic pop
