#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"
#import "NCMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCMessagesTableViewControllerSpec)

describe(@"NCMessagesTableViewController", ^{
    __block NCMessagesTableViewController *controller;
    __block UINavigationController *navigationController;

    beforeEach(^{
        controller = [[NCMessagesTableViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    });

    describe(@"-viewDidLoad", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        it(@"should set the compose button's target to itself", ^{
            controller.navigationItem.rightBarButtonItem.target should equal(controller);
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
