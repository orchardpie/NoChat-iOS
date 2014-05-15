#import <UIKit/UIKit.h>

@protocol NCEmailSelectTableViewControllerDelegate <NSObject>

- (void)didSelectEmail:(NSString *)email;

@end

@interface NCEmailSelectTableViewController : UITableViewController

- (instancetype)initWithEmails:(NSArray *)emails
              delegate:(id<NCEmailSelectTableViewControllerDelegate>)delegate;

@end
