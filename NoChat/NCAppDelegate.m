#import "NoChat.h"

NoChat *noChat;

#import "NCAppDelegate.h"
#import "NCMessagesTableViewController.h"
#import "NCNoDataViewcontroller.h"
#import "NCCurrentUser.h"
#import "NCAuthenticatable.h"
#import "NoChat.h"
#import "NCAnalytics.h"

@interface NCAppDelegate ()

@property (copy, nonatomic) void (^notificationRegistrationBlock)();

@end

@implementation NCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.notificationRegistrationBlock = ^{
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
    };

    if (noChat.webService.hasCredential) {
        [self getCurrentUserAndDisplayMessages];
    } else {
        self.currentUser = [[NCCurrentUser alloc] init];

        NCSignupViewController *signupVC = [[NCSignupViewController alloc] initWithCurrentUser:self.currentUser delegate:self];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:signupVC];
        self.window.rootViewController = navigationController;
    }

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.currentUser.messages) {
        NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:self.currentUser];
        [NSUserDefaults.standardUserDefaults setObject:archive forKey:@"currentUser"];
    }
}

#pragma mark - Push notification delegate implementation

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.currentUser registerDeviceToken:deviceToken];
}


#pragma mark - Signup and login delegate implementation

- (void)userDidSwitchToLogin
{
    NCLoginViewController *loginVC = [[NCLoginViewController alloc] initWithCurrentUser:self.currentUser
                                                                               delegate:self];
    [self transitionToViewController:loginVC];
}

- (void)userDidSwitchToSignup
{
    NCSignupViewController *loginVC = [[NCSignupViewController alloc] initWithCurrentUser:self.currentUser
                                                                               delegate:self];
    [self transitionToViewController:loginVC];
}

- (void)userDidAuthenticate
{
    self.notificationRegistrationBlock();
    [self showMessagesViewControllerWithTransition:YES refresh:NO];
}

- (void)userDidFailAuthentication
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;

    if ([navigationController.topViewController isKindOfClass:[NCLoginViewController class]]) {
        NCLoginViewController *loginVC = (id)navigationController.topViewController;
        [loginVC badCredentialAlert];
    } else {
        [self userDidSwitchToLogin];
    }
}

- (void)transitionToViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [UIView setAnimationsEnabled:NO];
                        self.window.rootViewController = navigationController;
                        [UIView setAnimationsEnabled:YES];
                    }
                    completion:nil];
}

#pragma mark Private interface

- (void)getCurrentUserAndDisplayMessages
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];
    if (data) {
        self.currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.notificationRegistrationBlock();
        [self showMessagesViewControllerWithTransition:NO refresh:YES];
    } else {
        self.currentUser = [[NCCurrentUser alloc] init];
        [self.currentUser fetchWithSuccess:^{
            self.notificationRegistrationBlock();
            [self showMessagesViewControllerWithTransition:NO refresh:NO];
        } failure:^(NSError *error) {
            self.window.rootViewController = [[NCNoDataViewController alloc] initWithCurrentUser:self.currentUser delegate:self];
            [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                        message:error.localizedRecoverySuggestion
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    }
}

- (void)showMessagesViewControllerWithTransition:(BOOL)transition refresh:(BOOL)refresh {
    NCMessagesTableViewController *messagesTVC = [[NCMessagesTableViewController alloc] initWithMessages:self.currentUser.messages];
    [self transitionToViewController:messagesTVC];

    if (refresh) {
        [messagesTVC refreshMessagesWithIndicator];
    }
}

@end
