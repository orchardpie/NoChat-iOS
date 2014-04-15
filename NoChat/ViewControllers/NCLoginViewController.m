#import "NCLoginViewController.h"
#import "NCMessagesTableViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD.h"

@interface NCLoginViewController ()

@property (strong, nonatomic) NCCurrentUser *currentUser;
@property (weak, nonatomic) id<NCLoginDelegate> delegate;

@end

@implementation NCLoginViewController

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

    self.title = @"Log In";
    self.logInButton.enabled = NO;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (IBAction)logInButtonTapped:(id)sender
{
    [self.passwordTextField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.currentUser saveCredentialWithEmail:self.emailTextField.text password:self.passwordTextField.text];
    [self.currentUser fetchWithSuccess:^{
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
}

- (IBAction)switchToSignupButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userDidSwitchToSignup)]) {
        [self.delegate userDidSwitchToSignup];
    }
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
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *otherText = (textField == self.emailTextField ? self.passwordTextField.text : self.emailTextField.text);
    self.logInButton.enabled = otherText.length > 0 && newText.length > 0;

    return YES;
}

@end
