#import "NCNoDataViewController.h"
#import "NCCurrentUser.h"
#import "NCAuthenticatable.h"
#import "MBProgressHUD.h"

@interface NCNoDataViewController ()

@property (strong, nonatomic) NCCurrentUser *currentUser;
@property (weak, nonatomic) id<NCAuthenticatable> delegate;

@end

@implementation NCNoDataViewController

- (instancetype)initWithCurrentUser:(NCCurrentUser *)currentUser
                 delegate:(id<NCAuthenticatable>)delegate
{
    if (self = [super initWithNibName:@"NCNoDataViewController" bundle:nil]) {
        self.currentUser = currentUser;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (IBAction)didTapRetryButton:(id)sender {
    self.retryButton.enabled = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.currentUser fetchWithSuccess:^{
        [self.delegate userDidAuthenticate];
    } failure:^(NSError *error) {
        self.retryButton.enabled = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                    message:error.localizedRecoverySuggestion
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
}

@end
