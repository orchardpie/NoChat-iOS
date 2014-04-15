#import "NCComposeMessageViewController.h"
#import "MBProgressHUD+Spec.h"
#import "UIAlertView+Spec.h"
#import "NCMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCComposeMessageViewControllerSpec)

describe(@"NCComposeMessageViewController", ^{
    __block NCComposeMessageViewController *controller;
    __block NCMessage *message;
    __block id<CedarDouble> delegate;

    beforeEach(^{
        message = [[NCMessage alloc] init];
        delegate = nice_fake_for(@protocol(NCComposeMessageDelegate));

        controller = [[NCComposeMessageViewController alloc] initWithMessage:message delegate:delegate];
        controller.view should_not be_nil;
    });

    describe(@"outlets", ^{
        describe(@"-receiverTextField", ^{
            it(@"should be", ^{
                controller.receiverTextField should_not be_nil;
            });

            it(@"should have delegate set to controller", ^{
                controller.receiverTextField.delegate should equal(controller);
            });

            it(@"should bring up the e-mail keyboard", ^{
                controller.receiverTextField.keyboardType should equal(UIKeyboardTypeEmailAddress);
            });

            it(@"should set the Return key to 'Next'", ^{
                controller.receiverTextField.returnKeyType should equal(UIReturnKeyNext);
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

        it(@"should set the send button's target to itself", ^{
            controller.sendButton.target should equal(controller);
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

    describe(@"send button action", ^{
        __block UIBarButtonItem *sendButton;

        subjectAction(^{
            [sendButton.target performSelector:sendButton.action withObject:sendButton];
        });

        beforeEach(^{
            sendButton = controller.sendButton;

            spy_on(message);
            spy_on(controller.view);

            controller.receiverTextField.text = @"comeon@fhqwgads.com";
            controller.messageBodyTextView.text = @"I see you tryin' to play like U NO ME";
        });

        it(@"should show the progress indicator", ^{
            MBProgressHUD.currentHUD should_not be_nil;
        });

        it(@"should dismiss the keyboard", ^{
            controller.view should have_received("endEditing:");
        });

        it(@"should set the message receiver e-mail", ^{
            message.receiver_email should equal(controller.receiverTextField.text);
        });

        it(@"should set the message body", ^{
            message.body should equal(controller.messageBodyTextView.text);
        });

        it(@"should ask the new message to save itself", ^{
            message should have_received("saveWithSuccess:serverFailure:networkFailure:");
        });

        context(@"when the save is successful", ^{
            beforeEach(^{
                message stub_method("saveWithSuccess:serverFailure:networkFailure:").and_do(^(NSInvocation *invocation) {
                    void (^successBlock)();
                    [invocation getArgument:&successBlock atIndex:2];
                    successBlock();
                });
            });

            it(@"should give the saved message back to the delegate", ^{
                delegate should have_received("userDidSendMessage:").with(message);
            });

            it(@"should clear the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });
        });

        sharedExamplesFor(@"an action that fails to save the message", ^(NSDictionary *sharedContext) {
            it(@"should not tell the delegate it sent the message", ^{
                delegate should_not have_received("userDidSendMessage:");
            });

            it(@"should show an error", ^{
                UIAlertView.currentAlertView should_not be_nil;
                UIAlertView.currentAlertView.title should_not be_nil;
                UIAlertView.currentAlertView.message should_not be_nil;
            });
        });

        context(@"when the save is unsuccessful because of a problem with the server", ^{
            beforeEach(^{
                message stub_method("saveWithSuccess:serverFailure:networkFailure:").and_do(^(NSInvocation *invocation) {
                    WebServiceServerFailure failureBlock;
                    [invocation getArgument:&failureBlock atIndex:3];
                    NSString *failureMessage = @"shameful failure";
                    failureBlock(failureMessage);
                });
            });

            itShouldBehaveLike(@"an action that fails to save the message");
        });

        context(@"when the save is unsuccessful because of a problem with the network", ^{
            beforeEach(^{
                message stub_method("saveWithSuccess:serverFailure:networkFailure:").and_do(^(NSInvocation *invocation) {
                    WebServiceNetworkFailure failureBlock;
                    [invocation getArgument:&failureBlock atIndex:4];
                    NSError *error = [NSError errorWithDomain:@"TestErrorDomain" code:-1004 userInfo:@{ NSLocalizedDescriptionKey: @"Could not connect to server",
                                                                                                        NSLocalizedRecoverySuggestionErrorKey: @"Try harder" }];                    failureBlock(error);
                });
            });

            itShouldBehaveLike(@"an action that fails to save the message");
        });
    });
});

SPEC_END
