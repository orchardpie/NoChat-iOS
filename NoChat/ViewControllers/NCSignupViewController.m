#import "NCSignupViewController.h"
#import "NCCurrentUser.h"
#import "MBProgressHUD.h"

@interface NCSignupViewController ()

@property (strong, nonatomic) NCCurrentUser *currentUser;

@end

@implementation NCSignupViewController

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
       signupSuccessBlock:(SignupSuccessBlock)signupSuccess
{
    if(self = [super init]) {
        self.currentUser = currentUser;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.signUpButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpButtonTapped:(id)sender {
    [self.passwordTextField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.currentUser saveCredentialsWithEmail:self.emailTextField.text andPassword:self.passwordTextField.text];
    [self.currentUser create:^(NCCurrentUser *currentUser){
        // all gravy baby
    } serverFailure:^(NSString *failureMessage){
        // shameful failure
    } networkFailure:^(NSError *error){
        // the failure of others
    }];
}

@end
