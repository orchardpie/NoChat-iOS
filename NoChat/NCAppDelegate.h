#import <UIKit/UIKit.h>
#import "NCSignupViewController.h"
#import "NCLoginViewController.h"

@interface NCAppDelegate : UIResponder <UIApplicationDelegate, NCSignupDelegate, NCLoginDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)userDidFailAuthentication;

@end
