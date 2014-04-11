#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"

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

    describe(@"-composeMessage", ^{
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
});

SPEC_END
