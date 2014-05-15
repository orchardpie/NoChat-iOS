#import <UIKit/UIKit.h>
#import "NCEmailSelectTableViewController.h"

@protocol NCContactsTableViewControllerDelegate <NSObject>

- (void)didSelectContactWithEmail:(NSString *)email;
- (void)didCloseContactsModal;

@end

@interface NCContactsTableViewController : UITableViewController<NCEmailSelectTableViewControllerDelegate>

- (instancetype)initWithDelegate:(id<NCContactsTableViewControllerDelegate>)delegate;

@end
