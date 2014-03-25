#import "NCLoginViewController.h"

@interface NCLoginViewController ()

@end

@implementation NCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.logInButton.enabled = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.emailTextField) {
        self.logInButton.enabled = self.passwordTextField.text.length > 0 && newText.length > 0;
    } else {
        self.logInButton.enabled = self.emailTextField.text.length > 0 && newText.length > 0;
    }

    return YES;
}

@end
