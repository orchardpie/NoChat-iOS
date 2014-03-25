#import "NCAppDelegate.h"
#import "NCMessagesTableViewController.h"
#import "NoChat.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCAppDelegateSpec)

describe(@"NCAppDelegate", ^{
    __block NCAppDelegate *delegate;

    beforeEach(^{
        delegate = [[NCAppDelegate alloc] init];
    });

    describe(@"application:didFinishLaunchingWithOptions", ^{
        beforeEach(^{
            [delegate application: nil didFinishLaunchingWithOptions: nil];
        });

        it(@"should initialize a global NoChat object", ^{
            noChat should_not be_nil;
        });

        it(@"should set a UINavigationController as the root view controller", ^{
            delegate.window.rootViewController should be_instance_of([UINavigationController class]);
        });

        it(@"should set a messages table view controller as the root view controller of the navigation controller", ^{
            UINavigationController *navigationController = (UINavigationController *)delegate.window.rootViewController;
            navigationController.topViewController should be_instance_of([NCMessagesTableViewController class]);
        });
    });
});

SPEC_END
