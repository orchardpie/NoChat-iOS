#import "NCComposeMessageViewController.h"
#import "MBProgressHUD+Spec.h"
#import "UIAlertView+Spec.h"
#import "NCMessage.h"
#import "NCMessagesCollection.h"
#import "NoChat.h"
#import "NCWebService.h"
#import "NCContactsTableViewController.h"
#import "NCAddressBook+Spec.h"
#import "UIAlertView+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

// Ignore "Unknown selector may cause a leak" warning.  We use performSelector: to
// invoke IBActions, which we know return void.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

SPEC_BEGIN(NCComposeMessageViewControllerSpec)

describe(@"NCComposeMessageViewController", ^{
    __block NCComposeMessageViewController *controller;
    __block NCMessagesCollection *messagesCollection;
    __block id<NCComposeMessageDelegate> delegate;

    beforeEach(^{
        messagesCollection = nice_fake_for([NCMessagesCollection class]);
        delegate = nice_fake_for(@protocol(NCComposeMessageDelegate));

        controller = [[NCComposeMessageViewController alloc] initWithMessagesCollection:messagesCollection delegate:delegate];
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

            it(@"should disable autocorrect", ^{
                controller.receiverTextField.autocorrectionType should equal(UITextAutocorrectionTypeNo);
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

    describe(@"-textFieldDidEndEditing", ^{
        __block UITextField *textField;

        subjectAction(^{ [controller textFieldDidEndEditing:textField]; });

        beforeEach(^{
            textField = controller.receiverTextField;
        });

        context(@"and the user has entered an email", ^{
            beforeEach(^{
                textField.text = @"wibble";
            });

            it(@"should send data to analytics", ^{
                noChat.analytics should have_received("sendAction:withCategory:").with(@"Enter Email", @"Messages");
            });
        });

        context(@"but the user has not entered an email", ^{
            beforeEach(^{
                textField.text = @"";
            });

            it(@"should not notify GA", ^{
                noChat.analytics should_not have_received("sendAction:withCategory:");
            });
        });
    });

    describe(@"-textViewDidEndEditing", ^{
        __block UITextView *textView;

        subjectAction(^{ [controller textViewDidEndEditing:textView]; });

        beforeEach(^{
            textView = controller.messageBodyTextView;
        });

        context(@"and the user has entered an email", ^{
            beforeEach(^{
                textView.text = @"wibble";
            });

            it(@"should send data to analytics", ^{
                noChat.analytics should have_received("sendAction:withCategory:").with(@"Enter Message", @"Messages");
            });
        });
        context(@"but the user has not entered an email", ^{
            beforeEach(^{
                textView.text = @"";
            });

            it(@"should not notify GA", ^{
                noChat.analytics should_not have_received("sendAction:withCategory:");
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

        it(@"should send data to analytics", ^{
            noChat.analytics should have_received("sendAction:withCategory:").with(@"Cancel Message", @"Messages");
        });
    });

    describe(@"send button action", ^{
        __block UIBarButtonItem *sendButton;
        NSString *email = @"comeon@fhqwgads.com",
        *body = @"I see you tryin' to play like U NO ME";

        subjectAction(^{
            [sendButton.target performSelector:sendButton.action withObject:sendButton];
        });

        beforeEach(^{
            sendButton = controller.sendButton;

            spy_on(controller.view);
            spy_on(noChat.webService);

            controller.receiverTextField.text = email;
            controller.messageBodyTextView.text = body;
        });

        it(@"should show the progress indicator", ^{
            MBProgressHUD.currentHUD should_not be_nil;
        });

        it(@"should dismiss the keyboard", ^{
            controller.view should have_received("endEditing:");
        });

        it(@"should create a new message with the specified parameters", ^{
            messagesCollection should have_received("createMessageWithParameters:success:failure:")
            .with(@{ @"message": @{ @"receiver_email": email, @"body": body } }, Arguments::anything, Arguments::anything);
        });

        context(@"when the save is successful", ^{
            __block NCMessage *message;

            beforeEach(^{
                message = fake_for([NCMessage class]);

                messagesCollection stub_method("createMessageWithParameters:success:failure:").and_do(^(NSInvocation *invocation) {
                    void (^successBlock)(NCMessage *);
                    [invocation getArgument:&successBlock atIndex:3];
                    successBlock(message);
                });
            });

            it(@"should give the saved message back to the delegate", ^{
                delegate should have_received("userDidSendMessage:").with(message);
            });

            it(@"should clear the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });

            it(@"should send data to analytics", ^{
                noChat.analytics should have_received("sendAction:withCategory:").with(@"Send Message", @"Messages");
            });
        });

        context(@"when the save is unsuccessful", ^{
            beforeEach(^{
                messagesCollection stub_method("createMessageWithParameters:success:failure:").and_do(^(NSInvocation *invocation) {
                    WebServiceError failureBlock;
                    [invocation getArgument:&failureBlock atIndex:4];
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

    describe(@"add contact action", ^{
        __block BOOL hasAccess;
        __block NSError *error;

        subjectAction(^{
            [noChat.addressBook respondWithAccess:hasAccess error:error];
        });

        beforeEach(^{
            [controller.addContactButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        context(@"when the user allows access to the address book", ^{
            beforeEach(^{
                hasAccess = YES;
                error = nil;
            });

            it(@"should not display an alert", ^{
                UIAlertView.currentAlertView should be_nil;
            });

            it(@"should display a modal view controller", ^{
                controller.presentedViewController should be_instance_of([UINavigationController class]);
                UINavigationController *navigationController = (id)controller.presentedViewController;
                navigationController.topViewController should be_instance_of([NCContactsTableViewController class]);
            });
        });

        context(@"when the user denies access to the address book", ^{
            __block NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            beforeEach(^{
                hasAccess = NO;
                error = nil;
            });

            context(@"when contacts access has already been requested", ^{
                beforeEach(^{
                    [userDefaults setBool:YES forKey:@"contactsAccessRequested"];
                    [userDefaults synchronize];
                });

                afterEach(^{
                    [userDefaults removeObjectForKey:@"contactsAccessRequested"];
                    [userDefaults synchronize];
                });

                it(@"should display an alert", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });
            });

            context(@"when contacts access has not yet been requested", ^{
                it(@"should display an alert", ^{
                    UIAlertView.currentAlertView should be_nil;
                });
            });

            it(@"should not display a modal view controller", ^{
                controller.presentedViewController should be_nil;
            });
        });

        context(@"when the user has previously denied access to the addres book", ^{
            beforeEach(^{
                hasAccess = NO;
                error = [NSError errorWithDomain:@"wibble" code:3 userInfo:@{}];
            });

            it(@"should display an alert", ^{
                UIAlertView.currentAlertView should_not be_nil;
            });

            it(@"should not display a modal view controller", ^{
                controller.presentedViewController should be_nil;
            });
        });
    });

    describe(@"-didSelectContactWithEmail:", ^{
        __block NSString *email = @"cooldude@coolisland.com";

        subjectAction(^{
            [controller didSelectContactWithEmail:email];
        });

        beforeEach(^{
            spy_on(controller.messageBodyTextView);
            [controller presentViewController:[[UITableViewController alloc] init] animated:NO completion:nil];
        });

        it(@"should set the receiver email field text", ^{
            controller.receiverTextField.text should equal(email);
        });

        it(@"should set focus to the body text view", ^{
            controller.messageBodyTextView should have_received("becomeFirstResponder");
        });

        it(@"should dismiss the contacts table view controller", ^{
            controller.presentedViewController should be_nil;
        });
    });

    describe(@"-didCloseContactsModal:", ^{
        subjectAction(^{
            [controller didCloseContactsModal];
        });

        beforeEach(^{
            [controller presentViewController:[[UITableViewController alloc] init] animated:NO completion:nil];
        });

        it(@"should dismiss the contacts table view controller", ^{
            controller.presentedViewController should be_nil;
        });
    });
});

SPEC_END

#pragma clang diagnostic pop
