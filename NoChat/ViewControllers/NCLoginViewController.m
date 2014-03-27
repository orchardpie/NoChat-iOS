#import "NCLoginViewController.h"
#import "NCCurrentUser.h"

@interface NCLoginViewController ()

@property (strong, nonatomic) NCCurrentUser *currentUser;

@end

@implementation NCLoginViewController

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
{
    if(self = [super init]) {
        self.currentUser = currentUser;
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
    [self.currentUser saveCredentialsWithEmail:self.emailTextField.text andPassword:self.passwordTextField.text];
    [self.currentUser fetch:^(NCCurrentUser *currentUser, NSError *error) {
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        if (textField.text.length) {
            if (self.emailTextField.text.length) {
                [self.currentUser saveCredentialsWithEmail:self.emailTextField.text andPassword:self.passwordTextField.text];
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
