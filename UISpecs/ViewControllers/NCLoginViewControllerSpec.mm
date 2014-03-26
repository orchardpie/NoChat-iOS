#import "NCLoginViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCLoginViewControllerSpec)

describe(@"NCLoginViewController", ^{
    __block NCLoginViewController *controller;

    beforeEach(^{
        controller = [[NCLoginViewController alloc] init];
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
                });

                context(@"when the password text field is not empty", ^{
                    beforeEach(^{
                        textField.text = @"something";
                    });

                    it(@"should return YES", ^{
                        returnValue should be_truthy;
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
    });
});

SPEC_END
