#import "NCLoginViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD+Spec.h"
#import "UIAlertView+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCLoginViewControllerSpec)

describe(@"NCLoginViewController", ^{
    __block NCLoginViewController *controller;
    __block id<CedarDouble> currentUser;
    __block LoginSuccessBlock loginSuccessBlock;
    __block bool loginSuccessBlockWasCalled;

    beforeEach(^{
        currentUser = nice_fake_for([NCCurrentUser class]);

        controller = [[NCLoginViewController alloc] initWithCurrentUser: currentUser loginSuccessBlock:loginSuccessBlock];
        controller.view should_not be_nil;
    });

    describe(@"outlets", ^{
        describe(@"-emailTextField", ^{
            it(@"should be", ^{
                controller.emailTextField should_not be_nil;
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

    sharedExamplesFor(@"an action that attempts to save credentials and fetch current user info", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            loginSuccessBlockWasCalled = NO;
            loginSuccessBlock = ^(NCCurrentUser *currentUser){
                loginSuccessBlockWasCalled = YES;
            };
        });

        it(@"should dismiss the keyboard", PENDING);

        it(@"should show the progress indicator", ^{
            MBProgressHUD.currentHUD should_not be_nil;
        });

        it(@"should ask the CurrentUser to save credentials", ^{
            currentUser should have_received("saveCredentialsWithEmail:andPassword:").with(controller.emailTextField.text).and_with(controller.passwordTextField.text);
        });

        it(@"should ask the CurrentUser to fetch its info from the server", ^{
            currentUser should have_received("fetch:failure:");
        });

        context(@"when the fetch is successful", ^{
            beforeEach(^{
                currentUser stub_method("fetch:failure:").and_do(^(NSInvocation *invocation) {
                    UserFetchSuccessBlock fetchBlock;
                    [invocation getArgument:&fetchBlock atIndex:2];

                    NCCurrentUser *someCurrentUser = [[NCCurrentUser alloc] init];
                    fetchBlock(someCurrentUser);
                });
            });

            it(@"should call the login success block", ^{
                loginSuccessBlockWasCalled should be_truthy;
            });

            it(@"should dismiss the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });
        });

        context(@"when the fetch is unsuccessful", ^{
            beforeEach(^{
                currentUser stub_method("fetch:failure:").and_do(^(NSInvocation *invocation) {
                    UserFetchFailureBlock fetchBlock;
                    [invocation getArgument:&fetchBlock atIndex:3];

                    NSError *error = [[NSError alloc] init];
                    fetchBlock(error);
                });
            });

            it(@"should not call the login success block", ^{
                loginSuccessBlockWasCalled should_not be_truthy;
            });

            it(@"should dismiss the progress indicator", ^{
                MBProgressHUD.currentHUD should be_nil;
            });

            context(@"with a 401 unauthorized", ^{
                it(@"should clear credentials", PENDING);
            });

            context(@"with any error besides a 401", ^{
                it(@"should show an error", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });
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
                        controller.logInButton.enabled should_not be_truthy;
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

                context(@"when the text field will be empty", ^{
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
                        currentUser should_not have_received("saveCredentialsWithEmail:andPassword");
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

                    itShouldBehaveLike(@"an action that attempts to save credentials and fetch current user info");

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
});

SPEC_END
