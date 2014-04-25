#import "NCComposeMessageViewController.h"
#import "MBProgressHUD+Spec.h"
#import "UIAlertView+Spec.h"
#import "NCMessage.h"
#import "NoChat.h"
#import "NCWebService.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

// Ignore "Unknown selector may cause a leak" warning.  We use performSelector: to
// invoke IBActions, which we know return void.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

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

        it(@"should disable the send button", ^{
            controller.sendButton.enabled should_not be_truthy;
        });
    });

    describe(@"enabling the send button", ^{
        NSRange range = NSMakeRange(0, 0);
        __block NSString *replacementString;

        context(@"when email text field changes", ^{
            __block UITextField *textField;

            subjectAction(^{
                [controller textField:textField shouldChangeCharactersInRange:range replacementString:replacementString];
            });

            beforeEach(^{
                textField = controller.receiverTextField;
            });

            context(@"when the text field is empty", ^{
                beforeEach(^{
                    replacementString = @"";
                });

                it(@"should return YES", ^{
                    [controller textField:textField shouldChangeCharactersInRange:range replacementString:replacementString] should be_truthy;
                });
                it(@"should not enable the sendButton", ^{
                    controller.sendButton.enabled should_not be_truthy;
                });
            });

            context(@"when the text field is not empty", ^{
                beforeEach(^{
                    replacementString = @"foo@example.com";
                });

                context(@"when the message body text view is empty", ^{
                    beforeEach(^{
                        controller.messageBodyTextView.text should be_empty;
                    });
                    it(@"should not enable the sendButton", ^{
                        controller.sendButton.enabled should_not be_truthy;
                    });
                });
                context(@"when the message body text view is not empty", ^{
                    beforeEach(^{
                        controller.messageBodyTextView.text = @"I like turtles.";
                    });

                    it(@"should enable the sendButton", ^{
                        controller.sendButton.enabled should be_truthy;
                    });
                });
            });
        });

        describe(@"when the message body changes", ^{
            __block UITextView *textView;

            subjectAction(^{
                [controller textView:textView shouldChangeTextInRange:range replacementText:replacementString];
            });

            beforeEach(^{
                textView = controller.messageBodyTextView;
            });

            context(@"when the text field is empty", ^{
                beforeEach(^{
                    replacementString = @"";
                });

                it(@"should return YES", ^{
                    [controller textView:textView shouldChangeTextInRange:range replacementText:replacementString] should be_truthy;
                });

                it(@"should not enable the sendButton", ^{
                    controller.sendButton.enabled should_not be_truthy;
                });
            });

            context(@"when the text view will not be empty", ^{
                beforeEach(^{
                    replacementString = @"I hate turtles.";
                });

                context(@"when the receiver text field is empty", ^{
                    beforeEach(^{
                        controller.receiverTextField.text should be_empty;
                    });

                    it(@"should not enable the sendButton", ^{
                        controller.sendButton.enabled should_not be_truthy;
                    });
                });
                context(@"when the receiver text field is not empty", ^{
                    beforeEach(^{
                        controller.receiverTextField.text = @"bar@example.com";
                    });

                    it(@"should enable the sendButton", ^{
                        controller.sendButton.enabled should be_truthy;
                    });
                });
            });
        });
    });

    describe(@"-textFieldShouldReturn:", ^{
        __block BOOL returnValue;

        subjectAction(^{ returnValue = [controller textFieldShouldReturn:controller.receiverTextField]; });

        beforeEach(^{
            spy_on(controller.messageBodyTextView);
        });

        context(@"when the receiver email text field is empty", ^{
            beforeEach(^{
                controller.receiverTextField.text should be_empty;
            });

            it(@"should return NO", ^{
                returnValue should_not be_truthy;
            });

            it(@"should not set the message body as first responder", ^{
                controller.messageBodyTextView should_not have_received("becomeFirstResponder");
            });
        });

        context(@"when the receiver email text field is not empty", ^{
            beforeEach(^{
                controller.receiverTextField.text = @"fhqwhgads@example.com";
            });

            it(@"should return NO", ^{
                returnValue should_not be_truthy;
            });

            it(@"should set the message body as first responder", ^{
                controller.messageBodyTextView should have_received("becomeFirstResponder");
            });
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

            spy_on(noChat.webService);
            noChat.webService stub_method("POST:parameters:completion:invalid:error:");

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
            message.receiverEmail should equal(controller.receiverTextField.text);
        });

        it(@"should set the message body", ^{
            message.body should equal(controller.messageBodyTextView.text);
        });

        it(@"should ask the new message to save itself", ^{
            message should have_received("saveWithSuccess:failure:");
        });

        context(@"when the save is successful", ^{
            beforeEach(^{
                message stub_method("saveWithSuccess:failure:").and_do(^(NSInvocation *invocation) {
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

        context(@"when the save is unsuccessful", ^{
            beforeEach(^{
                message stub_method("saveWithSuccess:failure:").and_do(^(NSInvocation *invocation) {
                    WebServiceError failureBlock;
                    [invocation getArgument:&failureBlock atIndex:3];
                    NSError<CedarDouble> *error = nice_fake_for([NSError class]);
                    error stub_method("localizedDescription").and_return(@"Something went wrong");
                    error stub_method("localizedRecoverySuggestion").and_return(@"try turning it on and off again");
                    failureBlock(error);
                });
            });

            it(@"should not tell the delegate it sent the message", ^{
                delegate should_not have_received("userDidSendMessage:");
            });

            it(@"should show an error", ^{
                UIAlertView.currentAlertView should_not be_nil;
                UIAlertView.currentAlertView.title should_not be_nil;
                UIAlertView.currentAlertView.message should_not be_nil;
            });
        });
    });
});

SPEC_END

#pragma clang diagnostic pop
