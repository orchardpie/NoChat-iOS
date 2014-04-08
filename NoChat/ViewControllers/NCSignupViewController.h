#import <UIKit/UIKit.h>

@class NCCurrentUser;

@interface NCSignupViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
       signupSuccessBlock:(void(^)())signupSuccess;

@end

