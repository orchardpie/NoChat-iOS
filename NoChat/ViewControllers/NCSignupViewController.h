#import <UIKit/UIKit.h>

@class NCCurrentUser;

typedef void(^SignupSuccessBlock)(void);

@interface NCSignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser
       signupSuccessBlock:(SignupSuccessBlock)signupSuccess;

@end

