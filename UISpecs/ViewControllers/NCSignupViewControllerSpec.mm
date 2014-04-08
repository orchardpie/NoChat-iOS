#import "NCSignupViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD+Spec.h"
#import "UIAlertView+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCSignupViewControllerSpec)

describe(@"NCSignupViewController", ^{
    __block NCSignupViewController *controller;
    __block id<CedarDouble> currentUser;
    __block SignupSuccessBlock signupSuccessBlock;
    __block bool signupSuccessBlockWasCalled;

    beforeEach(^{
        currentUser = nice_fake_for([NCCurrentUser class]);
        controller = [[NCSignupViewController alloc] initWithCurrentUser:currentUser signupSuccessBlock:^{}];
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

    sharedExamplesFor(@"an action that attempts to save credentials and create current user", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            signupSuccessBlockWasCalled = NO;
            signupSuccessBlock = ^{
                signupSuccessBlockWasCalled = YES;
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
            currentUser should have_received("create:serverFailure:networkFailure:");
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
});

SPEC_END
