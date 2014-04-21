#import "NoChat+App.h"
#import "NCAppDelegate.h"

@implementation NoChat (App)

- (void)userDidSwitchToLogin
{
    NCAppDelegate *appDelegate = (NCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate userDidSwitchToLogin];
}

- (void)userDidFailAuthentication
{
    NCAppDelegate *appDelegate = (NCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate userDidFailAuthentication];
}

@end
