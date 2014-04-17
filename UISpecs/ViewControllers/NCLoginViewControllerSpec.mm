#import "NCLoginViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD+Spec.h"
#import "UIAlertView+Spec.h"
#import "UIView+Spec.h"
#import "UIGestureRecognizer+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCLoginViewControllerSpec)

describe(@"NCLoginViewController", ^{
    __block NCLoginViewController *controller;
    __block id<CedarDouble> currentUser;
    __block id<CedarDouble> delegate;

    beforeEach(^{
        [UIGestureRecognizer whitelistClassForGestureSnooping:[NCLoginViewController class]];

        currentUser = nice_fake_for([NCCurrentUser class]);
        delegate = nice_fake_for(@protocol(NCLoginDelegate));

        controller = [[NCLoginViewController alloc] initWithCurrentUser:currentUser delegate:delegate];

        controller.view should_not be_nil;
    });

    describe(@"outlets", ^{
        describe(@"-emailTextField", ^{
            it(@"should be", ^{
                controller.emailTextField should_not be_nil;
            });

            it(@"should have delegate set to controller", ^{
                controller.emailTextField.delegate should equal(controller);
            });

            it(@"should bring up the e-mail keyboard", ^{
                controller.emailTextField.keyboardType should equal(UIKeyboardTypeEmailAddress);
            });

            it(@"should not capitalize", ^{
                controller.emailTextField.autocapitalizationType should equal(UITextAutocapitalizationTypeNone);
            });

            it(@"should not autocorrect", ^{
                controller.emailTextField.autocorrectionType should equal(UITextAutocorrectionTypeNo);
            });

            it(@"should set the Return key to 'Next'", ^{
                controller.emailTextField.returnKeyType should equal(UIReturnKeyNext);
            });
        });

        describe(@"-passwordTextField", ^{
            it(@"should be", ^{
                controller.passwordTextField should_not be_nil;
            });

            it(@"should have delegate set to controller", ^{
                controller.passwordTextField.delegate should equal(controller);
            });

            it(@"should bring up the password keyboard", ^{
                controller.passwordTextField.keyboardType should equal(UIKeyboardTypeDefault);
            });

            it(@"should not capitalize", ^{
                controller.passwordTextField.autocapitalizationType should equal(UITextAutocapitalizationTypeNone);
            });

            it(@"should not autocorrect", ^{
                controller.passwordTextField.autocorrectionType should equal(UITextAutocorrectionTypeNo);
            });

            it(@"should mask the values", ^{
                controller.passwordTextField.secureTextEntry should be_truthy;
            });
        });

        describe(@"-logInButton", ^{
            it(@"should be", ^{
                controller.logInButton should_not be_nil;
            });
        });
    });

    describe(@"-viewDidLoad", ^{
        it(@"should disable the log in button", ^{
            controller.logInButton.enabled should_not be_truthy;
        });
    });

    describe(@"gesture events", ^{
        describe(@"tap outside of a text field", ^{
            subjectAction(^{
                [controller.view tap];
            });

            beforeEach(^{
                spy_on(controller.view);
            });

            it(@"should dismiss the keyboard", ^{
                controller.view should have_received("endEditing:");
            });
        });
    });

    sharedExamplesFor(@"an action that attempts to save credentials and fetch current user info", ^(NSDictionary *sharedContext) {
        it(@"should show the progress indicator", ^{
            MBProgressHUD.currentHUD should_not be_nil;
        });

        it(@"should ask the CurrentUser to save the new credentials", ^{
            currentUser should have_received("saveCredentialWithEmail:password:").with(controller.emailTextField.text, controller.passwordTextField.text);
        });

        it(@"should ask the CurrentUser to fetch its info from the server", ^{
            currentUser should have_received("fetchWithSuccess:serverFailure:networkFailure:");
        });

        context(@"when the fetch is successful", ^{
            beforeEach(^{
                currentUser stub_method("fetchWithSuccess:serverFailure:networkFailure:").and_do(^(NSInvocation *invocation) {
                    void (^fetchBlock)();
                    [invocation getArgument:&fetchBlock atIndex:2];
                    fetchBlock();
                });
            });

            it(@"should tell the delegate that the user has authenticated", ^{
                delegate should have_received("userDidAuthenticate");
            });

            it(@"should dismiss the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });
        });

        sharedExamplesFor(@"an action which displays an alert message for an error", ^(NSDictionary *sharedContext) {
            it(@"should not tell the delegate that the user has authenticated", ^{
                delegate should_not have_received("userDidAuthenticate");
            });

            it(@"should dismiss the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });

            it(@"should show an error", ^{
                UIAlertView.currentAlertView should_not be_nil;
                UIAlertView.currentAlertView.title should_not be_nil;
                UIAlertView.currentAlertView.message should_not be_nil;
            });
        });

        context(@"when the fetch attempt yields a server failure", ^{
            beforeEach(^{
                currentUser stub_method("fetchWithSuccess:serverFailure:networkFailure:").and_do(^(NSInvocation *invocation) {
                    WebServiceInvalid fetchBlock;
                    [invocation getArgument:&fetchBlock atIndex:3];
                    NSString *failureMessage = @"shameful failure";
                    fetchBlock(failureMessage);
                });
            });

            itShouldBehaveLike(@"an action which displays an alert message for an error");
        });

        context(@"when the fetch attempt yields a server failure", ^{
            beforeEach(^{
                currentUser stub_method("fetchWithSuccess:serverFailure:networkFailure:").and_do(^(NSInvocation *invocation) {
                    WebServiceError fetchBlock;
                    [invocation getArgument:&fetchBlock atIndex:4];
                    NSError *error = [NSError errorWithDomain:@"TestErrorDomain" code:-1004 userInfo:@{ NSLocalizedDescriptionKey: @"Could not connect to server",
                                                                                                        NSLocalizedRecoverySuggestionErrorKey: @"Try harder" }];
                    fetchBlock(error);
                });
            });

            itShouldBehaveLike(@"an action which displays an alert message for an error");
        });
    });

    describe(@"UITextFieldDelegate", ^{
        __block UITextField *textField;

        describe(@"-textField:shouldChangeCharactersInRange:replacementString", ^{
            NSRange range = NSMakeRange(0, 0);
            __block NSString *replacementString;

            subjectAction(^{
                [controller textField:textField shouldChangeCharactersInRange:range replacementString:replacementString];
            });

            context(@"when the text field is the email text field", ^{
                beforeEach(^{
                    textField = controller.emailTextField;
                });

                context(@"when the text field is empty", ^{
                    beforeEach(^{
                        replacementString = @"";
                    });

                    it(@"should return YES", ^{
                        [controller textField:textField shouldChangeCharactersInRange:range replacementString:replacementString] should be_truthy;
                    });
                    it(@"should not enable the logInButton", ^{
                        controller.logInButton.enabled should_not be_truthy;
                    });
                });

                context(@"when the text field is not empty", ^{
                    beforeEach(^{
                        replacementString = @"foo@example.com";
                    });

                    context(@"when the password text field is empty", ^{
                        beforeEach(^{
                            controller.passwordTextField.text should be_empty;
                        });
                        it(@"should not enable the logInButton", ^{
                            controller.logInButton.enabled should_not be_truthy;
                        });
                    });
                    context(@"when the password text field is not empty", ^{
                        beforeEach(^{
                            controller.passwordTextField.text = @"partypassword";
                        });

                        it(@"should enable the logInButton", ^{
                            controller.logInButton.enabled should be_truthy;
                        });
                    });
                });
            });

            context(@"when the text field is the password text field", ^{
                beforeEach(^{
                    textField = controller.passwordTextField;
                });

                context(@"when the text field is empty", ^{
                    beforeEach(^{
                        replacementString = @"";
                    });

                    it(@"should return YES", ^{
                        [controller textField:textField shouldChangeCharactersInRange:range replacementString:replacementString] should be_truthy;
                    });

                    it(@"should not enable the logInButton", ^{
                        controller.logInButton.enabled should_not be_truthy;
                    });
                });

                context(@"when the text field will not be empty", ^{
                    beforeEach(^{
                        replacementString = @"password";
                    });

                    context(@"when the email text field is empty", ^{
                        beforeEach(^{
                            controller.emailTextField.text should be_empty;
                        });

                        it(@"should not enable the logInButton", ^{
                            controller.logInButton.enabled should_not be_truthy;
                        });
                    });
                    context(@"when the email text field is not empty", ^{
                        beforeEach(^{
                            controller.emailTextField.text = @"bar@example.com";
                        });

                        it(@"should enable the logInButton", ^{
                            controller.logInButton.enabled should be_truthy;
                        });
                    });
                });
            });
        });

        describe(@"-textFieldShouldReturn:", ^{
            __block BOOL returnValue;

            subjectAction(^{ returnValue = [controller textFieldShouldReturn:textField]; });

            context(@"when the text field is the email text field", ^{
                beforeEach(^{
                    textField = controller.emailTextField;
                    spy_on(controller.passwordTextField);
                });

                context(@"when the email text field is empty", ^{
                    beforeEach(^{
                        textField.text should be_empty;
                    });

                    it(@"should return NO", ^{
                        returnValue should_not be_truthy;
                    });

                    it(@"should not set the password field as first responder", ^{
                        controller.passwordTextField should_not have_received("becomeFirstResponder");
                    });
                });

                context(@"when the email text field is not empty", ^{
                    beforeEach(^{
                        textField.text = @"foo@example.com";
                    });

                    it(@"should return NO", ^{
                        returnValue should_not be_truthy;
                    });

                    it(@"should set the password field as first responder", ^{
                        controller.passwordTextField should have_received("becomeFirstResponder");
                    });
                });
            });

            context(@"when the text field is the password text field", ^{
                beforeEach(^{
                    textField = controller.passwordTextField;
                    spy_on(controller.passwordTextField);
                    spy_on(controller.emailTextField);
                });

                context(@"when the password text field is empty", ^{
                    beforeEach(^{
                        textField.text should be_empty;
                    });

                    it(@"should return NO", ^{
                        returnValue should_not be_truthy;
                    });

                    it(@"should not attempt to save credentials", ^{
                        currentUser should_not have_received("saveCredentialWithEmail:password");
                    });

                    it(@"should not resign first responder", ^{
                        controller.passwordTextField should_not have_received("resignFirstResponder");
                    });
                });

                context(@"when the password text field is not empty", ^{
                    beforeEach(^{
                        textField.text = @"something";
                        controller.emailTextField.text = @"sup@updog.com";
                    });

                    it(@"should return NO", ^{
                        returnValue should_not be_truthy;
                    });

                    context(@"when the email text field is not empty", ^{
                        beforeEach(^{
                            controller.emailTextField.text should_not be_empty;
                        });

                        itShouldBehaveLike(@"an action that attempts to save credentials and fetch current user info");

                        it(@"should resign first responder", ^{
                            controller.passwordTextField should have_received("resignFirstResponder");
                        });
                    });

                    context(@"when the email text field is empty", ^{
                        beforeEach(^{
                            controller.emailTextField.text = @"";
                        });

                        it(@"should set the email field as the first responder", ^{
                            controller.emailTextField should have_received("becomeFirstResponder");
                        });
                    });
                });
            });
        });
    });

    describe(@"-logInButtonTapped", ^{
        subjectAction(^{
            [controller.logInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        beforeEach(^{
            controller.emailTextField.text = @"kevinwo@orchardpie.com";
            controller.passwordTextField.text = @"ilikepie";
        });

        itShouldBehaveLike(@"an action that attempts to save credentials and fetch current user info");
    });

    describe(@"-switchToSignupButtonTapped", ^{
        subjectAction(^{
            [controller.switchToSignupButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should ask the app delegate to switch to the signup view", ^{
            delegate should have_received("userDidSwitchToSignup");
        });
    });
});

SPEC_END
