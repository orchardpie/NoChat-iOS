#import <UIKit/UIKit.h>

@class NCCurrentUser;

@interface NCLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
        loginSuccessBlock:(void(^)())loginSuccess;

@end
