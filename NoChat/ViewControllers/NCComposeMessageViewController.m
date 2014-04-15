#import "NCComposeMessageViewController.h"
#import "NCMessage.h"
#import "MBProgressHUD.h"

@interface NCComposeMessageViewController ()

@property (weak, nonatomic) id<NCComposeMessageDelegate> delegate;
@property (strong, nonatomic) NCMessage *message;

@end

@implementation NCComposeMessageViewController

- (instancetype)initWithMessage:(NCMessage *)message delegate:(id)delegate
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.message = message;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype) init {
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpMessageBodyTextView];
}

# pragma mark - private

- (void)setUpMessageBodyTextView
{
    self.messageBodyTextView.layer.borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
    self.messageBodyTextView.layer.borderWidth = 0.5;
}

# pragma mark - button actions

- (IBAction)close:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(composeMessageVCCloseButtonTapped)]) {
        [self.delegate composeMessageVCCloseButtonTapped];
    }
}

- (IBAction)sendMessage:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view endEditing:YES];

    self.message.receiver_email = self.receiverTextField.text;
    self.message.body = self.messageBodyTextView.text;
    [self.message saveWithSuccess:^{
        if ([self.delegate respondsToSelector:@selector(userDidSendMessage:)]) {
            [self.delegate userDidSendMessage:self.message];
        }

        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } serverFailure:^(NSString *failureMessage) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Oops"
                                    message:failureMessage
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];

    } networkFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                    message:error.localizedRecoverySuggestion
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }];
}

@end
