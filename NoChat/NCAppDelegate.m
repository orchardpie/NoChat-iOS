#import "NoChat.h"

NoChat *noChat;

#import "NCAppDelegate.h"
#import "NCMessagesTableViewController.h"
#import "NCCurrentUser.h"

@implementation NCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.currentUser = [[NCCurrentUser alloc] init];

    UINavigationController *navigationController;

    if (noChat.webService.hasCredential) {
        NCMessagesTableViewController *messageTVC = [[NCMessagesTableViewController alloc] initWithMessages:self.currentUser.messages];
        navigationController = [[UINavigationController alloc] initWithRootViewController:messageTVC];
        [messageTVC refreshMessagesWithIndicator];
    } else {
        NCSignupViewController *signupVC = [[NCSignupViewController alloc] initWithCurrentUser:self.currentUser delegate:self];
        navigationController = [[UINavigationController alloc] initWithRootViewController:signupVC];
    }

    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
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
    NCMessagesTableViewController *messagesTVC = [[NCMessagesTableViewController alloc] initWithMessages:self.currentUser.messages];
    [self transitionToViewController:messagesTVC];
}

- (void)userDidFailAuthentication
{
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

#pragma mark - app delegate stuff

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [self.currentUser archive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
