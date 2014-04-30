#import "NCSignupViewController.h"
#import "NCAuthenticatable.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD.h"
#import "NoChat.h"
#import "NCAnalytics.h"

@interface NCSignupViewController ()

@property (strong, nonatomic) NCCurrentUser *currentUser;
@property (weak, nonatomic) id<NCSignupDelegate> delegate;

@end

@implementation NCSignupViewController

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
                 delegate:(id<NCSignupDelegate>)delegate
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.currentUser signUpWithEmail:self.emailTextField.text password:self.passwordTextField.text
                              success:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [noChat.analytics sendAction:@"Submit Signup" withCategory:@"Account"];
        if ([self.delegate respondsToSelector:@selector(userDidAuthenticate)]) {
            [self.delegate userDidAuthenticate];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [noChat.analytics sendAction:@"Error Signup" withCategory:@"Account"];
        [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                    message:error.localizedRecoverySuggestion
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.emailTextField && textField.text.length > 0) {
        [noChat.analytics sendAction:@"Enter Signup Email" withCategory:@"Account"];
    } else if (textField == self.passwordTextField && textField.text.length > 0) {
        [noChat.analytics sendAction:@"Enter Signup Password" withCategory:@"Account"];
    }
}


@end
