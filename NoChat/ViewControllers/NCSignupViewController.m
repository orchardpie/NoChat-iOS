#import "NCSignupViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD.h"
#import "NCDataValidator.h"
#import "NCPasswordValidator.h"

@interface NCSignupViewController ()

@property (strong, nonatomic) NCCurrentUser *currentUser;
@property (weak, nonatomic) id<NCSignupDelegate> delegate;

@end

@implementation NCSignupViewController

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
                 delegate:(id)delegate
{
    if(self = [super init]) {
        self.currentUser = currentUser;
        self.delegate = delegate;
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Sign Up";
    self.signUpButton.enabled = NO;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (IBAction)signUpButtonTapped:(id)sender {
    [self.passwordTextField resignFirstResponder];

    NCPasswordValidator *passwordValidator = [[NCPasswordValidator alloc] init];
    passwordValidator.minLength = 8;

    NSError *error = [NCDataValidator validateEmail:self.emailTextField.text
                                        andPassword:self.passwordTextField.text
                                  passwordValidator:passwordValidator];

    if (!error) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [self.currentUser signUpWithEmail:self.emailTextField.text password:self.passwordTextField.text
                                  success:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([self.delegate respondsToSelector:@selector(userDidAuthenticate)]) {
                [self.delegate userDidAuthenticate];
            }

        } serverFailure:^(NSString *failureMessage) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Oops"
                                        message:failureMessage
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];

        } networkFailure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                        message:error.localizedRecoverySuggestion
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
        }];
    } else {
        [self showValidationErrorWithErrorCode:error.code];
    }
}

- (void)showValidationErrorWithErrorCode:(NSInteger)errorCode
{
    NSString *errorTitle;

    switch (errorCode) {
        case kNCErrorCodeInvalidEmail:
            errorTitle = @"Please enter a valid e-mail";
            break;

        case kNCErrorCodePasswordTooShort:
            errorTitle = @"Please enter a password with at least 8 characters";
            break;

        default:
            break;
    }

    [[[UIAlertView alloc] initWithTitle:errorTitle
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (IBAction)switchToLoginButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userDidSwitchToLogin)]) {
        [self.delegate userDidSwitchToLogin];
    }
}

#pragma mark - UITextField delegate implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        if (textField.text.length) {
            if (self.emailTextField.text.length) {
                [self signUpButtonTapped:nil];
            } else {
                [self.emailTextField becomeFirstResponder];
            }
        }
    } else if (textField.text.length) {
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *otherText = (textField == self.emailTextField ? self.passwordTextField.text : self.emailTextField.text);
    self.signUpButton.enabled = otherText.length > 0 && newText.length > 0;

    return YES;
}


@end
