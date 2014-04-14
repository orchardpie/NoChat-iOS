#import <UIKit/UIKit.h>

@class NCMessage;

@protocol NCComposeMessageDelegate <NSObject>

- (void)composeMessageVCCloseButtonTapped;

@end

@interface NCComposeMessageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UITextField *recipientTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageBodyTextView;

- (instancetype)initWithMessage:(NCMessage *)message delegate:(id)delegate;

@end
