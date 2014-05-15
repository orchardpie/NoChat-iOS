#import <UIKit/UIKit.h>

@protocol NCContactsTableViewControllerDelegate <NSObject>

- (void)didSelectContactWithEmail:(NSString *)email;
- (void)didCloseContactsModal;

@end

@interface NCContactsTableViewController : UITableViewController

- (instancetype)initWithDelegate:(id<NCContactsTableViewControllerDelegate>)delegate;

@end
