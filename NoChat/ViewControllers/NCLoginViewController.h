#import <UIKit/UIKit.h>

@class NCCurrentUser;

@protocol NCLoginDelegate <NSObject>

- (void)userDidAuthenticate;
- (void)userDidSwitchToSignup;

@end

@interface NCLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *switchToSignupButton;

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
                 delegate:(id)delegate;

@end
