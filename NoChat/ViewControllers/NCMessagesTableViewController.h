#import <UIKit/UIKit.h>
#import "NCComposeMessageViewController.h"

@class NCMessagesCollection;

@interface NCMessagesTableViewController : UITableViewController<NCComposeMessageDelegate>

- (instancetype)initWithMessages:(NCMessagesCollection *)messages;
- (void)refreshMessages;

@end
