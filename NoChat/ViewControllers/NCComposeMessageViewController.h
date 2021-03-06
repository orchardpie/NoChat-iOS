#import <UIKit/UIKit.h>
#import "NCContactsTableViewController.h"

@class NCMessage;
@class NCMessagesCollection;

@protocol NCComposeMessageDelegate <NSObject>

- (void)composeMessageVCCloseButtonTapped;
- (void)userDidSendMessage:(NCMessage*)message;

@end

@interface NCComposeMessageViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, NCContactsTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *receiverTextField;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
@property (weak, nonatomic) IBOutlet UITextView *messageBodyTextView;

- (instancetype)initWithMessagesCollection:(NCMessagesCollection *)messagesCollection
                                  delegate:(id)delegate;

@end
