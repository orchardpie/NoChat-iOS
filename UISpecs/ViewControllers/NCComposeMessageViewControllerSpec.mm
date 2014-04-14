#import "NCComposeMessageViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCComposeMessageViewControllerSpec)

describe(@"NCComposeMessageViewController", ^{
    __block NCComposeMessageViewController *controller;
    __block id<CedarDouble> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(NCComposeMessageDelegate));

        controller = [[NCComposeMessageViewController alloc] initWithMessage:nil delegate:delegate];
        controller.view should_not be_nil;
    });

    describe(@"outlets", ^{
        describe(@"-recipientTextField", ^{
            it(@"should be", ^{
                controller.recipientTextField should_not be_nil;
            });

            it(@"should have delegate set to controller", ^{
                controller.recipientTextField.delegate should equal(controller);
            });

            it(@"should bring up the e-mail keyboard", ^{
                controller.recipientTextField.keyboardType should equal(UIKeyboardTypeEmailAddress);
            });

            it(@"should set the Return key to 'Next'", ^{
                controller.recipientTextField.returnKeyType should equal(UIReturnKeyNext);
            });
        });

        describe(@"-messageBodyTextView", ^{
            it(@"should be", ^{
                controller.messageBodyTextView should_not be_nil;
            });
        });
    });

    describe(@"-viewDidLoad", ^{
        it(@"should set the close button's target to itself", ^{
            controller.closeButton.target should equal(controller);
        });
    });

    describe(@"close button action", ^{
        __block UIBarButtonItem *closeButton;

        subjectAction(^{
            [closeButton.target performSelector:closeButton.action withObject:closeButton];
        });

        beforeEach(^{
            closeButton = controller.closeButton;
        });

        it(@"should ask the delegate to dismiss the modal", ^{
            delegate should have_received("composeMessageVCCloseButtonTapped");
        });
    });
});

SPEC_END
