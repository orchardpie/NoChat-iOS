#import <UIKit/UIKit.h>
#import "NCSignupViewController.h"
#import "NCLoginViewController.h"

@class NCCurrentUser;

@interface NCAppDelegate : UIResponder <UIApplicationDelegate, NCSignupDelegate, NCLoginDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NCCurrentUser *currentUser;

- (void)userDidFailAuthentication;

@end
