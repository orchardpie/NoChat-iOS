#import "NCComposeMessageViewController.h"
#import "NCMessagesCollection.h"
#import "MBProgressHUD.h"
#import "NoChat.h"
#import "NCAnalytics.h"
#import "NCAddressBook.h"
#import "NCContactsTableViewController.h"

@interface NCComposeMessageViewController ()

@property (weak, nonatomic) id<NCComposeMessageDelegate> delegate;
@property (strong, nonatomic) NCMessagesCollection *messagesCollection;

@end

@implementation NCComposeMessageViewController

- (instancetype)initWithMessagesCollection:(NCMessagesCollection *)messagesCollection
                                  delegate:(id)delegate
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.messagesCollection = messagesCollection;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sendButton.enabled = NO;
    [self setUpMessageBodyTextView];
}

#pragma mark - UITextField delegate implementation

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *otherText = self.messageBodyTextView.text;
    self.sendButton.enabled = otherText.length > 0 && newText.length > 0;

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        [self.messageBodyTextView becomeFirstResponder];
    }

    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [noChat.analytics sendAction:@"Enter Email" withCategory:@"Messages"];
    }
}

#pragma mark - UITextView delegate implementation

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSString *otherText = self.receiverTextField.text;
    self.sendButton.enabled = otherText.length > 0 && newText.length > 0;

    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length > 0) {
        [noChat.analytics sendAction:@"Enter Message" withCategory:@"Messages"];
    }
}

#pragma mark - Private interface

- (void)setUpMessageBodyTextView
{
    self.messageBodyTextView.layer.borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
    self.messageBodyTextView.layer.borderWidth = 0.5;
}

#pragma mark - Button actions

- (IBAction)close:(id)sender
{
    [noChat.analytics sendAction:@"Cancel Message" withCategory:@"Messages"];
    if ([self.delegate respondsToSelector:@selector(composeMessageVCCloseButtonTapped)]) {
        [self.delegate composeMessageVCCloseButtonTapped];
    }
}

- (IBAction)sendMessage:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view endEditing:YES];

    NSDictionary *parameters = @{ @"message" : @{
                                          @"receiver_email" : self.receiverTextField.text,
                                          @"body" : self.messageBodyTextView.text } };

    [self.messagesCollection createMessageWithParameters:parameters
                                      success:^(NCMessage *message) {
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [noChat.analytics sendAction:@"Send Message" withCategory:@"Messages"];
                                          [self.delegate userDidSendMessage:message];

                                      } failure:^(NSError *error) {
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                                      message:error.localizedRecoverySuggestion
                                                                     delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                            otherButtonTitles:nil] show];
                                      }];
}

- (IBAction)addContact:(id)sender {
    [noChat.addressBook checkAccess:^(BOOL hasAccess, NSError *error) {
        if (hasAccess) {
            NCContactsTableViewController *contactsTVC = [[NCContactsTableViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactsTVC];
            [self presentViewController:navigationController animated:YES completion:nil];
        } else {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Oh noes!"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]
                 show];
            }
        }
    }];
}

@end
