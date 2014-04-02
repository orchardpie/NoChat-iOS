#import "NCLoginViewController.h"
#import "NCMessagesTableViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD.h"

@interface NCLoginViewController ()

@property (strong, nonatomic) NCCurrentUser *currentUser;
@property (strong, nonatomic) LoginSuccessBlock loginSuccess;

@end

@implementation NCLoginViewController

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
        loginSuccessBlock:(LoginSuccessBlock)loginSuccess
{
    if(self = [super init]) {
        self.currentUser = currentUser;
        self.loginSuccess = loginSuccess;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.logInButton.enabled = NO;
}

- (IBAction)logInButtonTapped:(id)sender
{
    [self.passwordTextField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.currentUser saveCredentialsWithEmail:self.emailTextField.text andPassword:self.passwordTextField.text];
    [self.currentUser fetch:^(NCCurrentUser *currentUser) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (self.loginSuccess) { self.loginSuccess(currentUser); }

    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:@"There was a problem logging in. Please make sure your e-mail and password are correct and try again."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

#pragma mark - UITextField delegate implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        if (textField.text.length) {
            if (self.emailTextField.text.length) {
                [self logInButtonTapped:nil];
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
    self.logInButton.enabled = otherText.length > 0 && newText.length > 0;

    return YES;
}

@end
