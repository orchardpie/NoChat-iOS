#import "NCSignupViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD.h"

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
}

- (IBAction)signUpButtonTapped:(id)sender {
    [self.passwordTextField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.currentUser saveCredentialsWithEmail:self.emailTextField.text andPassword:self.passwordTextField.text];
    [self.currentUser signUpWithSuccess:^{
        // all gravy baby
    } serverFailure:^(NSString *failureMessage) {
        // shameful failure
    } networkFailure:^(NSError *error) {
        // the failure of others
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


@end
