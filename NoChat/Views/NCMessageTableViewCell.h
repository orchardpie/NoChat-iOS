#import <UIKit/UIKit.h>

@class NCMessage;

@interface NCMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeSavedLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (strong, nonatomic) NCMessage *message;

+ (NSString *)cellIdentifier;
+ (CGFloat)cellHeight;

@end
