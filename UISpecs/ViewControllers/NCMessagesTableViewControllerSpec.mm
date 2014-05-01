#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"
#import "NCMessage.h"
#import "NCMessagesCollection.h"
#import "NCMessageTableViewCell.h"
#import "NoChat.h"
#import "NCAnalytics.h"
#import "UIAlertView+Spec.h"

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
        NSDictionary *messagesDict = @{ @"location": @"/messages",
                                        @"data": @[] };
        messages = [[NCMessagesCollection alloc] initWithMessagesDict:messagesDict];
        spy_on(messages);

        controller = [[NCMessagesTableViewController alloc] initWithMessages:messages];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

        controller.view should_not be_nil;
    });

    describe(@"-viewDidLoad", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        it(@"should set the compose button's target to itself", ^{
            controller.navigationItem.rightBarButtonItem.target should equal(controller);
        });

        it(@"should enable pull-to-refresh", ^{
            controller.refreshControl should_not be_nil;
        });
    });

    describe(@"-refreshMessagesWithIndicator:", ^{
        subjectAction(^{ [controller refreshMessagesWithIndicator]; });

        it(@"should ask the messages collection to fetch itself", ^{
            messages should have_received("fetchWithSuccess:failure:");
        });

        it(@"should show the refresh indicator", ^{
            controller.refreshControl.isRefreshing should be_truthy;
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

            it(@"should hide the refresh indicator", ^{
                controller.refreshControl.isRefreshing should_not be_truthy;
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

            it(@"should hide the refresh indicator", ^{
                controller.refreshControl.isRefreshing should_not be_truthy;
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

    describe(@"-composeMessage button action", ^{
        __block UIBarButtonItem *composeButton;

        subjectAction(^{
            [composeButton.target performSelector:composeButton.action withObject:composeButton];
        });

        beforeEach(^{
            controller.view should_not be_nil;
            composeButton = controller.navigationItem.rightBarButtonItem;
        });

        it(@"should send data to analytics", ^{
            noChat.analytics should have_received("sendAction:withCategory:").with(@"Create Message", @"Messages");
        });

        it(@"should push to a NCComposeMessageViewController", ^{
            controller.presentedViewController should be_instance_of([NCComposeMessageViewController class]);
        });
    });

    describe(@"-refreshControl action", ^{
        subjectAction(^{
            [controller.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
        });

        it(@"should ask the messages collection to fetch itself", ^{
            messages should have_received("fetchWithSuccess:failure:");
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
