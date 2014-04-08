#import <UIKit/UIKit.h>

@class NCCurrentUser;

@protocol NCSignupDelegate <NSObject>

- (void)userDidAuthenticate;
- (void)userDidSwitchToLogin;

@end

@interface NCSignupViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *switchToLoginButton;

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
                 delegate:(id)delegate;

@end

