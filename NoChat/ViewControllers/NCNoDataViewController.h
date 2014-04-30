#import <UIKit/UIKit.h>

@class NCCurrentUser;
@protocol NCAuthenticatable;

@interface NCNoDataViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *retryButton;

- (id)initWithCurrentUser:(NCCurrentUser *)currentUser delegate:(id<NCAuthenticatable>)delegate;

@end
