#import "NCSignupViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD+Spec.h"
#import "UIAlertView+Spec.h"
#import "UIView+Spec.h"
#import "UIGestureRecognizer+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCSignupViewControllerSpec)

describe(@"NCSignupViewController", ^{
    __block NCSignupViewController *controller;
    __block id<CedarDouble> currentUser;
    __block id<CedarDouble> delegate;

    beforeEach(^{
        [UIGestureRecognizer whitelistClassForGestureSnooping:[NCSignupViewController class]];

        currentUser = nice_fake_for([NCCurrentUser class]);
        delegate = nice_fake_for(@protocol(NCSignupDelegate));

        controller = [[NCSignupViewController alloc] initWithCurrentUser:currentUser delegate:delegate];

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

        describe(@"-signUpButton", ^{
            it(@"should be", ^{
                controller.signUpButton should_not be_nil;
            });
        });
    });

    describe(@"-viewDidLoad", ^{
        it(@"should disable the sign up button", ^{
            controller.signUpButton.enabled should_not be_truthy;
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

    sharedExamplesFor(@"an action that attempts to save credentials and create current user", ^(NSDictionary *sharedContext) {
        it(@"should show the progress indicator", ^{
            MBProgressHUD.currentHUD should_not be_nil;
        });

        it(@"should ask the CurrentUser to save itself to the server", ^{
            currentUser should have_received("signUpWithEmail:password:success:failure:").with(controller.emailTextField.text, controller.passwordTextField.text, Arguments::any([NSObject class]), Arguments::any([NSObject class]));
        });

        context(@"when the fetch is successful", ^{
            beforeEach(^{
                currentUser stub_method("signUpWithEmail:password:success:failure:").and_do(^(NSInvocation *invocation) {
                    void (^signUpBlock)();
                    [invocation getArgument:&signUpBlock atIndex:4];
                    signUpBlock();
                });
            });

            it(@"should tell the delegate that the user has authenticated", ^{
                delegate should have_received("userDidAuthenticate");
            });

            it(@"should dismiss the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });
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

                context(@"when the text field will be empty", ^{
                    beforeEach(^{
                        replacementString = @"";
                    });

                    it(@"should return YES", ^{
                        [controller textField:textField shouldChangeCharactersInRange:range replacementString:replacementString] should be_truthy;
                    });
                    it(@"should not enable the logInButton", ^{
                        controller.signUpButton.enabled should_not be_truthy;
                    });
                });

                context(@"when the text field will not be empty", ^{
                    beforeEach(^{
                        replacementString = @"foo@example.com";
                    });

                    context(@"when the password text field is empty", ^{
                        beforeEach(^{
                            controller.passwordTextField.text should be_empty;
                        });
                        it(@"should not enable the logInButton", ^{
                            controller.signUpButton.enabled should_not be_truthy;
                        });
                    });
                    context(@"when the password text field is not empty", ^{
                        beforeEach(^{
                            controller.passwordTextField.text = @"partypassword";
                        });

                        it(@"should enable the logInButton", ^{
                            controller.signUpButton.enabled should be_truthy;
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
                        controller.signUpButton.enabled should_not be_truthy;
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
                            controller.signUpButton.enabled should_not be_truthy;
                        });
                    });
                    context(@"when the email text field is not empty", ^{
                        beforeEach(^{
                            controller.emailTextField.text = @"bar@example.com";
                        });

                        it(@"should enable the logInButton", ^{
                            controller.signUpButton.enabled should be_truthy;
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

                    it(@"should return YES", ^{
                        returnValue should be_truthy;
                    });

                    it(@"should not set the password field as first responder", ^{
                        controller.passwordTextField should_not have_received("becomeFirstResponder");
                    });
                });

                context(@"when the email text field is not empty", ^{
                    beforeEach(^{
                        textField.text = @"foo@example.com";
                    });

                    it(@"should return YES", ^{
                        returnValue should be_truthy;
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

                    it(@"should return YES", ^{
                        returnValue should be_truthy;
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

                    it(@"should return YES", ^{
                        returnValue should be_truthy;
                    });

                    context(@"when the email text field is not empty", ^{
                        beforeEach(^{
                            controller.emailTextField.text should_not be_empty;
                        });

                        itShouldBehaveLike(@"an action that attempts to save credentials and create current user");

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

    describe(@"-signUpButtonTapped", ^{
        subjectAction(^{
            [controller.signUpButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        beforeEach(^{
            controller.emailTextField.text = @"kevinwo@orchardpie.com";
            controller.passwordTextField.text = @"ilikepie";
        });

        itShouldBehaveLike(@"an action that attempts to save credentials and create current user");
    });

    describe(@"-switchToLoginButtonTapped", ^{
        subjectAction(^{
            [controller.switchToLoginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should ask the app delegate to switch to the login view", ^{
            delegate should have_received("userDidSwitchToLogin");
        });
    });
});

SPEC_END
